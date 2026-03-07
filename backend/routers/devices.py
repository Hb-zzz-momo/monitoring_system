from fastapi import APIRouter, Depends, HTTPException
from models import Device, DeviceUpdate
import database as db
from security import get_current_user, require_admin

router = APIRouter(prefix="/devices", tags=["devices"])


@router.get("", response_model=list[Device])
def list_devices(_current_user: dict = Depends(get_current_user)):
    return db.list_devices()


@router.get("/{device_id}", response_model=Device)
def get_device(device_id: str, _current_user: dict = Depends(get_current_user)):
    device = db.get_device(device_id)
    if device:
        return device
    raise HTTPException(status_code=404, detail="设备不存在")


@router.put("/{device_id}", response_model=Device)
def update_device(
    device_id: str,
    body: DeviceUpdate,
    _admin_user: dict = Depends(require_admin),
):
    updated = db.update_device(device_id, body.model_dump(exclude_none=True))
    if updated:
        return updated
    raise HTTPException(status_code=404, detail="设备不存在")
