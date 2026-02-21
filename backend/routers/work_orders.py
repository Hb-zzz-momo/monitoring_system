from fastapi import APIRouter, HTTPException
from models import WorkOrder, WorkOrderUpdate
import database as db

router = APIRouter(prefix="/work-orders", tags=["work-orders"])


@router.get("", response_model=list[WorkOrder])
def list_work_orders():
    return db.work_orders


@router.get("/{order_id}", response_model=WorkOrder)
def get_work_order(order_id: str):
    for w in db.work_orders:
        if w.id == order_id:
            return w
    raise HTTPException(status_code=404, detail="工单不存在")


@router.put("/{order_id}", response_model=WorkOrder)
def update_work_order(order_id: str, body: WorkOrderUpdate):
    for i, w in enumerate(db.work_orders):
        if w.id == order_id:
            updated = w.model_copy(update=body.model_dump(exclude_none=True))
            db.work_orders[i] = updated
            return updated
    raise HTTPException(status_code=404, detail="工单不存在")
