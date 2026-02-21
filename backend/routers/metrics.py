from fastapi import APIRouter
from models import DeviceMetrics, RealtimeEvent, HealthData
import database as db

router = APIRouter(prefix="/metrics", tags=["metrics"])


@router.get("", response_model=DeviceMetrics)
def get_metrics():
    return db.device_metrics


@router.get("/events", response_model=list[RealtimeEvent])
def get_events():
    return db.realtime_events


@router.get("/health", response_model=HealthData)
def get_health():
    return db.health_data
