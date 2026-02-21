from fastapi import APIRouter, HTTPException
from models import Device, DeviceUpdate
import database as db

router = APIRouter(prefix="/devices", tags=["devices"])


@router.get("", response_model=list[Device])
def list_devices():
    return db.devices


@router.get("/{device_id}", response_model=Device)
def get_device(device_id: str):
    for d in db.devices:
        if d.id == device_id:
            return d
    raise HTTPException(status_code=404, detail="设备不存在")


@router.put("/{device_id}", response_model=Device)
def update_device(device_id: str, body: DeviceUpdate):
    for i, d in enumerate(db.devices):
        if d.id == device_id:
            updated = d.model_copy(update=body.model_dump(exclude_none=True))
            db.devices[i] = updated
            return updated
    raise HTTPException(status_code=404, detail="设备不存在")
