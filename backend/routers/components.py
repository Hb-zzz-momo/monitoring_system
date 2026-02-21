from fastapi import APIRouter, HTTPException
from models import Component
import database as db

router = APIRouter(prefix="/components", tags=["components"])


@router.get("", response_model=list[Component])
def list_components():
    return db.components


@router.get("/{component_id}", response_model=Component)
def get_component(component_id: str):
    for c in db.components:
        if c.id == component_id:
            return c
    raise HTTPException(status_code=404, detail="部件不存在")
