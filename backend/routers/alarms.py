from fastapi import APIRouter, Depends, HTTPException
from models import Alarm, AlarmUpdate, WorkOrder
import database as db
from security import get_current_user, require_admin

router = APIRouter(prefix="/alarms", tags=["alarms"])


@router.get("", response_model=list[Alarm])
def list_alarms(_current_user: dict = Depends(get_current_user)):
    return db.list_alarms()


@router.get("/{alarm_id}", response_model=Alarm)
def get_alarm(alarm_id: str, _current_user: dict = Depends(get_current_user)):
    alarm = db.get_alarm(alarm_id)
    if alarm:
        return alarm
    raise HTTPException(status_code=404, detail="告警不存在")


@router.put("/{alarm_id}", response_model=Alarm)
def update_alarm(
    alarm_id: str,
    body: AlarmUpdate,
    _admin_user: dict = Depends(require_admin),
):
    updated = db.update_alarm(alarm_id, body.model_dump(exclude_none=True))
    if updated:
        return updated
    raise HTTPException(status_code=404, detail="告警不存在")


@router.post("/{alarm_id}/work-order", response_model=WorkOrder)
def create_work_order_from_alarm(
    alarm_id: str,
    _current_user: dict = Depends(get_current_user),
):
    work_order = db.create_work_order_from_alarm(alarm_id)
    if work_order:
        return work_order
    raise HTTPException(status_code=404, detail="告警不存在")
