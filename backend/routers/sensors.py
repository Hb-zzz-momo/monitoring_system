from fastapi import APIRouter, Depends

import database as db
from models import SensorIngestPayload, SensorIngestResponse
from replay_engine import sensor_replay_engine
from realtime_hub import realtime_hub
from security import get_current_user, require_admin

router = APIRouter(prefix="/sensors", tags=["sensors"])


@router.post("/ingest", response_model=SensorIngestResponse)
async def ingest_sensor_data(body: SensorIngestPayload, _current_user: dict = Depends(get_current_user)):
    payload = body.model_dump()
    latest_metrics = db.ingest_sensor_reading(payload)
    device_id = payload["deviceId"]
    latest_events, _, _ = db.list_realtime_events_for_device(device_id=device_id, limit=10)
    trend, _, _ = db.list_metric_history_for_device(device_id=device_id, metric="temperature", points=20)

    await realtime_hub.broadcast(
        {
            "type": "sensor_update",
            "deviceId": device_id,
            "metrics": latest_metrics.model_dump(),
            "events": [item.model_dump() for item in latest_events],
            "trend": trend,
        },
        device_id=device_id,
        channel="metrics",
    )

    return SensorIngestResponse(
        success=True,
        message="传感器数据已入库并完成实时推送",
        metrics=latest_metrics,
    )


@router.get("/replay/status")
def get_replay_status(_current_user: dict = Depends(get_current_user)):
    return sensor_replay_engine.status()


@router.post("/replay/start")
def start_replay(intervalSeconds: float = 1.5, _admin_user: dict = Depends(require_admin)):
    started = sensor_replay_engine.start(interval_seconds=intervalSeconds)
    return {
        "success": started,
        "message": "回放已启动" if started else "回放已在运行或缺少可回放数据",
        "status": sensor_replay_engine.status(),
    }


@router.post("/replay/stop")
async def stop_replay(_admin_user: dict = Depends(require_admin)):
    stopped = await sensor_replay_engine.stop()
    return {
        "success": stopped,
        "message": "回放已停止" if stopped else "回放当前未运行",
        "status": sensor_replay_engine.status(),
    }
