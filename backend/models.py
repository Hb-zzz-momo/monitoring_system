from typing import Optional, List
from pydantic import BaseModel, Field


# ── Auth ──────────────────────────────────────────────────────────────────────

class LoginRequest(BaseModel):
    username: str
    password: str


class LoginResponse(BaseModel):
    token: str
    username: str
    role: str
    displayName: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None


class RegisterRequest(BaseModel):
    username: str = Field(min_length=3, max_length=50)
    password: str = Field(min_length=6, max_length=128)
    displayName: Optional[str] = Field(default=None, max_length=100)
    email: Optional[str] = Field(default=None, max_length=255)
    phone: Optional[str] = Field(default=None, max_length=30)


class RegisterResponse(BaseModel):
    token: str
    username: str
    role: str
    displayName: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None


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


class WorkOrderAttachment(BaseModel):
    fileName: str
    fileUrl: str
    fileSize: int
    uploadedTime: str


# ── Metrics ───────────────────────────────────────────────────────────────────

class DeviceMetrics(BaseModel):
    temperature: float
    voltage: float
    current: float
    power: float
    energy: float
    delay: int
    isConnected: bool


class MetricPoint(BaseModel):
    x: float
    y: float


class DeviceMetricsResponse(BaseModel):
    deviceId: str
    metrics: DeviceMetrics
    isSimulated: bool
    dataSource: str
    timestamp: str


class MetricHistoryResponse(BaseModel):
    deviceId: str
    metric: str
    points: List[MetricPoint]
    isSimulated: bool
    dataSource: str


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


class DeviceHealthResponse(BaseModel):
    deviceId: str
    health: HealthData
    isSimulated: bool
    dataSource: str
    timestamp: str


# ── Sensor Ingest ─────────────────────────────────────────────────────────────

class SensorIngestPayload(BaseModel):
    deviceId: str
    timestamp: Optional[str] = None
    temperature: float
    voltage: float
    current: float
    power: float
    energy: float
    delay: int = 0
    isConnected: bool = True


class SensorIngestResponse(BaseModel):
    success: bool
    message: str
    metrics: DeviceMetrics


# ── AI Training ───────────────────────────────────────────────────────────────

class TrainingSample(BaseModel):
    id: int
    source: str
    input: str
    expectedOutput: str
    createdAt: str


class ManualTrainingSampleCreate(BaseModel):
    input: str
    expectedOutput: str
    source: str = "manual"


class TrainingCollectResponse(BaseModel):
    success: bool
    added: int


class TrainingJob(BaseModel):
    id: str
    status: str
    totalSamples: int
    processedSamples: int
    modelName: Optional[str] = None
    message: Optional[str] = None
    createdAt: str


class TrainingJobStartResponse(BaseModel):
    success: bool
    job: TrainingJob


class AiRecommendationEvidence(BaseModel):
    type: str
    title: str
    value: str


class AiRecommendationResponse(BaseModel):
    deviceId: str
    summary: str
    suggestion: str
    confidence: float
    evidence: List[AiRecommendationEvidence]
    createdWorkOrderId: Optional[str] = None
