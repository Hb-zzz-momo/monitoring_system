from fastapi import APIRouter, Depends, HTTPException
from models import WorkOrder, WorkOrderUpdate
import database as db
from security import get_current_user, require_admin

router = APIRouter(prefix="/work-orders", tags=["work-orders"])


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
    _admin_user: dict = Depends(require_admin),
):
    updated = db.update_work_order(order_id, body.model_dump(exclude_none=True))
    if updated:
        return updated
    raise HTTPException(status_code=404, detail="工单不存在")
