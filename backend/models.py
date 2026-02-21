from typing import Optional, List
from pydantic import BaseModel


# ── Auth ──────────────────────────────────────────────────────────────────────

class LoginRequest(BaseModel):
    username: str
    password: str


class LoginResponse(BaseModel):
    token: str
    username: str
    role: str


# ── Device ────────────────────────────────────────────────────────────────────

class Device(BaseModel):
    id: str
    name: str
    isOnline: bool
    lastUpdate: str
    temperature: float
    power: float
    healthIndex: float
    rul: int


class DeviceUpdate(BaseModel):
    name: Optional[str] = None
    isOnline: Optional[bool] = None
    temperature: Optional[float] = None
    power: Optional[float] = None
    healthIndex: Optional[float] = None
    rul: Optional[int] = None


# ── Alarm ─────────────────────────────────────────────────────────────────────

class Alarm(BaseModel):
    id: str
    title: str
    level: str          # 'danger' | 'warning' | 'info'
    device: str
    component: str
    time: str
    currentValue: float
    threshold: float
    status: str         # '进行中' | '已处理'
    description: str


class AlarmUpdate(BaseModel):
    status: Optional[str] = None


# ── Work Order ────────────────────────────────────────────────────────────────

class WorkOrder(BaseModel):
    id: str
    device: str
    component: str
    status: str         # '待处理' | '处理中' | '已完成'
    title: str
    assignee: str
    createdTime: str
    updatedTime: str
    description: str


class WorkOrderUpdate(BaseModel):
    status: Optional[str] = None
    assignee: Optional[str] = None
    description: Optional[str] = None


# ── Metrics ───────────────────────────────────────────────────────────────────

class DeviceMetrics(BaseModel):
    temperature: float
    voltage: float
    current: float
    power: float
    energy: float
    delay: int
    isConnected: bool


# ── Realtime Event ────────────────────────────────────────────────────────────

class RealtimeEvent(BaseModel):
    type: str
    icon: str
    text: str
    time: str


# ── Component ─────────────────────────────────────────────────────────────────

class ComponentMetric(BaseModel):
    name: str
    value: float
    unit: str


class Component(BaseModel):
    id: str
    name: str
    healthIndex: float
    rul: int
    rulRange: str
    suggestions: List[str]
    metrics: List[ComponentMetric]


# ── Health / Life ─────────────────────────────────────────────────────────────

class ComponentHealth(BaseModel):
    name: str
    hi: float
    rul: int
    status: str


class HealthPrediction(BaseModel):
    date: str
    hi: float


class HealthData(BaseModel):
    overallHI: float
    overallRUL: int
    rulRange: str
    trend: str
    components: List[ComponentHealth]
    predictions: List[HealthPrediction]
    suggestions: List[str]
