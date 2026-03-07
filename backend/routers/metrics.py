import json
from datetime import datetime, timezone

from fastapi import APIRouter
from fastapi import Depends, HTTPException, Query
from fastapi import WebSocket, WebSocketDisconnect
from models import (
    DeviceHealthResponse,
    DeviceMetrics,
    DeviceMetricsResponse,
    HealthData,
    MetricHistoryResponse,
    MetricPoint,
    RealtimeEvent,
)
import database as db
from realtime_hub import realtime_hub
from security import authenticate_websocket, get_current_user

router = APIRouter(prefix="/metrics", tags=["metrics"])


def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


@router.get("", response_model=DeviceMetrics)
def get_metrics(_current_user: dict = Depends(get_current_user)):
    return db.get_latest_metrics()


@router.get("/events", response_model=list[RealtimeEvent])
def get_events(_current_user: dict = Depends(get_current_user)):
    return db.list_realtime_events()


@router.get("/health", response_model=HealthData)
def get_health(_current_user: dict = Depends(get_current_user)):
    return db.get_latest_health()


@router.get("/history", response_model=list[MetricPoint])
def get_metric_history(
    metric: str = Query(default="temperature"),
    points: int = Query(default=60, ge=1, le=300),
    _current_user: dict = Depends(get_current_user),
):
    try:
        return db.list_metric_history(metric=metric, points=points)
    except ValueError:
        raise HTTPException(status_code=400, detail="不支持的指标")


@router.get("/devices/{device_id}", response_model=DeviceMetricsResponse)
def get_device_metrics(
    device_id: str,
    _current_user: dict = Depends(get_current_user),
):
    metrics, is_simulated, data_source = db.get_latest_metrics_for_device(device_id)
    return DeviceMetricsResponse(
        deviceId=device_id,
        metrics=metrics,
        isSimulated=is_simulated,
        dataSource=data_source,
        timestamp=_now_iso(),
    )


@router.get("/devices/{device_id}/history", response_model=MetricHistoryResponse)
def get_device_metric_history(
    device_id: str,
    metric: str = Query(default="temperature"),
    points: int = Query(default=60, ge=1, le=300),
    _current_user: dict = Depends(get_current_user),
):
    try:
        trend, is_simulated, data_source = db.list_metric_history_for_device(
            device_id=device_id,
            metric=metric,
            points=points,
        )
    except ValueError:
        raise HTTPException(status_code=400, detail="不支持的指标")

    return MetricHistoryResponse(
        deviceId=device_id,
        metric=metric,
        points=[MetricPoint(**item) for item in trend],
        isSimulated=is_simulated,
        dataSource=data_source,
    )


@router.get("/devices/{device_id}/events")
def get_device_events(
    device_id: str,
    limit: int = Query(default=20, ge=1, le=100),
    _current_user: dict = Depends(get_current_user),
):
    events, is_simulated, data_source = db.list_realtime_events_for_device(device_id=device_id, limit=limit)
    return {
        "deviceId": device_id,
        "events": [item.model_dump() for item in events],
        "isSimulated": is_simulated,
        "dataSource": data_source,
    }


@router.get("/devices/{device_id}/health", response_model=DeviceHealthResponse)
def get_device_health(
    device_id: str,
    _current_user: dict = Depends(get_current_user),
):
    health, is_simulated, data_source = db.get_latest_health_for_device(device_id)
    return DeviceHealthResponse(
        deviceId=device_id,
        health=health,
        isSimulated=is_simulated,
        dataSource=data_source,
        timestamp=_now_iso(),
    )


@router.websocket("/stream")
async def stream_metrics(websocket: WebSocket):
    try:
        authenticate_websocket(websocket)
    except HTTPException:
        await websocket.close(code=1008)
        return

    device_id = websocket.query_params.get("device_id")
    channels_text = websocket.query_params.get("channels", "metrics,events,history")
    channels = {item.strip() for item in channels_text.split(",") if item.strip()}

    await realtime_hub.connect(
        websocket,
        {"device_id": device_id, "channels": channels},
    )
    try:
        if device_id:
            metrics, _, _ = db.get_latest_metrics_for_device(device_id)
            events, _, _ = db.list_realtime_events_for_device(device_id=device_id, limit=10)
            trend, _, _ = db.list_metric_history_for_device(device_id=device_id, metric="temperature", points=20)
        else:
            metrics = db.get_latest_metrics()
            events = db.list_realtime_events()[:10]
            trend = db.list_metric_history(metric="temperature", points=20)

        await websocket.send_json(
            {
                "type": "bootstrap",
                "deviceId": device_id,
                "metrics": metrics.model_dump(),
                "events": [item.model_dump() for item in events],
                "trend": trend,
            }
        )
        while True:
            message_text = await websocket.receive_text()
            if not message_text:
                continue
            try:
                message = json.loads(message_text)
            except json.JSONDecodeError:
                continue

            if message.get("type") == "subscribe":
                next_device_id = message.get("deviceId") or device_id
                next_channels = message.get("channels") or list(channels)
                realtime_hub.update_subscription(
                    websocket,
                    {
                        "device_id": next_device_id,
                        "channels": {str(item) for item in next_channels},
                    },
                )
    except WebSocketDisconnect:
        realtime_hub.disconnect(websocket)
    except Exception:
        realtime_hub.disconnect(websocket)
