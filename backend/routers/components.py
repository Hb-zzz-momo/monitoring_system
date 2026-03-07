from fastapi import APIRouter, Depends, HTTPException
from models import Component
import database as db
from security import get_current_user

router = APIRouter(prefix="/components", tags=["components"])


@router.get("", response_model=list[Component])
def list_components(_current_user: dict = Depends(get_current_user)):
    return db.list_components()


@router.get("/{component_id}", response_model=Component)
def get_component(component_id: str, _current_user: dict = Depends(get_current_user)):
    component = db.get_component(component_id)
    if component:
        return component
    raise HTTPException(status_code=404, detail="部件不存在")
