from datetime import datetime
from pathlib import Path
import re

from fastapi import APIRouter, Depends, HTTPException, File, UploadFile
from models import WorkOrder, WorkOrderUpdate, WorkOrderAttachment
import database as db
from security import get_current_user

router = APIRouter(prefix="/work-orders", tags=["work-orders"])
_attachments_root = Path(__file__).resolve().parents[1] / "uploads" / "work_orders"


def _sanitize_filename(name: str) -> str:
    cleaned = re.sub(r"[^A-Za-z0-9._-]", "_", name).strip("._")
    return cleaned or "attachment.bin"


def _serialize_attachment(path: Path, order_id: str) -> WorkOrderAttachment:
    uploaded_time = datetime.fromtimestamp(path.stat().st_mtime).strftime("%Y-%m-%d %H:%M")
    return WorkOrderAttachment(
        fileName=path.name,
        fileUrl=f"/uploads/work_orders/{order_id}/{path.name}",
        fileSize=path.stat().st_size,
        uploadedTime=uploaded_time,
    )


@router.get("", response_model=list[WorkOrder])
def list_work_orders(_current_user: dict = Depends(get_current_user)):
    return db.list_work_orders()


@router.get("/{order_id}", response_model=WorkOrder)
def get_work_order(order_id: str, _current_user: dict = Depends(get_current_user)):
    work_order = db.get_work_order(order_id)
    if work_order:
        return work_order
    raise HTTPException(status_code=404, detail="工单不存在")


@router.put("/{order_id}", response_model=WorkOrder)
def update_work_order(
    order_id: str,
    body: WorkOrderUpdate,
    _current_user: dict = Depends(get_current_user),
):
    updated = db.update_work_order(order_id, body.model_dump(exclude_none=True))
    if updated:
        return updated
    raise HTTPException(status_code=404, detail="工单不存在")


@router.get("/{order_id}/attachments", response_model=list[WorkOrderAttachment])
def list_work_order_attachments(
    order_id: str,
    _current_user: dict = Depends(get_current_user),
):
    work_order = db.get_work_order(order_id)
    if not work_order:
        raise HTTPException(status_code=404, detail="工单不存在")

    order_dir = _attachments_root / order_id
    if not order_dir.exists():
        return []

    files = [
        path
        for path in order_dir.iterdir()
        if path.is_file()
    ]
    files.sort(key=lambda p: p.stat().st_mtime, reverse=True)
    return [_serialize_attachment(path, order_id) for path in files]


@router.post("/{order_id}/attachments", response_model=WorkOrderAttachment)
async def upload_work_order_attachment(
    order_id: str,
    file: UploadFile = File(...),
    _current_user: dict = Depends(get_current_user),
):
    work_order = db.get_work_order(order_id)
    if not work_order:
        raise HTTPException(status_code=404, detail="工单不存在")

    if not file.filename:
        raise HTTPException(status_code=400, detail="缺少文件名")

    original_name = _sanitize_filename(file.filename)
    stamp = datetime.now().strftime("%Y%m%d%H%M%S")
    stored_name = f"{stamp}_{original_name}"

    order_dir = _attachments_root / order_id
    order_dir.mkdir(parents=True, exist_ok=True)

    content = await file.read()
    if not content:
        raise HTTPException(status_code=400, detail="空文件无法上传")

    saved_path = order_dir / stored_name
    saved_path.write_bytes(content)
    return _serialize_attachment(saved_path, order_id)
