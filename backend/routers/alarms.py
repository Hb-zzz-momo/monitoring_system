from fastapi import APIRouter, HTTPException
from models import Alarm, AlarmUpdate
import database as db

router = APIRouter(prefix="/alarms", tags=["alarms"])


@router.get("", response_model=list[Alarm])
def list_alarms():
    return db.alarms


@router.get("/{alarm_id}", response_model=Alarm)
def get_alarm(alarm_id: str):
    for a in db.alarms:
        if a.id == alarm_id:
            return a
    raise HTTPException(status_code=404, detail="告警不存在")


@router.put("/{alarm_id}", response_model=Alarm)
def update_alarm(alarm_id: str, body: AlarmUpdate):
    for i, a in enumerate(db.alarms):
        if a.id == alarm_id:
            updated = a.model_copy(update=body.model_dump(exclude_none=True))
            db.alarms[i] = updated
            return updated
    raise HTTPException(status_code=404, detail="告警不存在")
