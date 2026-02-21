"""In-memory data store initialised from the same data as the Flutter mock."""

from models import (
    Device, Alarm, WorkOrder, DeviceMetrics, RealtimeEvent,
    Component, ComponentMetric, HealthData, ComponentHealth, HealthPrediction,
)

# ── Devices ───────────────────────────────────────────────────────────────────

devices: list[Device] = [
    Device(id="1", name="主控设备-01", isOnline=True,  lastUpdate="2分钟前",  temperature=42.3, power=3.2, healthIndex=0.72, rul=180),
    Device(id="2", name="监测设备-02", isOnline=True,  lastUpdate="5分钟前",  temperature=38.7, power=2.8, healthIndex=0.85, rul=320),
    Device(id="3", name="备用设备-03", isOnline=False, lastUpdate="2小时前", temperature=25.0, power=0.0, healthIndex=0.95, rul=500),
    Device(id="4", name="测试设备-04", isOnline=True,  lastUpdate="刚刚",    temperature=45.2, power=4.1, healthIndex=0.58, rul=90),
]

# ── Alarms ────────────────────────────────────────────────────────────────────

alarms: list[Alarm] = [
    Alarm(id="1", title="部件过温告警",  level="danger",  device="主控设备-01", component="主轴承",   time="10分钟前", currentValue=78.5, threshold=75.0, status="进行中", description="主轴承温度超过阈值"),
    Alarm(id="2", title="电压异常预警",  level="warning", device="监测设备-02", component="电源模块", time="1小时前",  currentValue=235.0, threshold=240.0, status="进行中", description="电压接近上限"),
    Alarm(id="3", title="连接异常",      level="warning", device="备用设备-03", component="通讯模块", time="2小时前",  currentValue=0,    threshold=0,     status="已处理", description="设备离线"),
]

# ── Work Orders ───────────────────────────────────────────────────────────────

work_orders: list[WorkOrder] = [
    WorkOrder(id="WO-2024-001", device="主控设备-01", component="主轴承",   status="处理中", title="更换主轴承",      assignee="张工", createdTime="2小时前", updatedTime="30分钟前", description="主轴承温度持续偏高，需要检查并更换"),
    WorkOrder(id="WO-2024-002", device="监测设备-02", component="电源模块", status="待处理", title="检查电压稳定性",  assignee="李工", createdTime="1小时前", updatedTime="1小时前",  description="电压波动异常，需要检查电源模块"),
    WorkOrder(id="WO-2024-003", device="备用设备-03", component="通讯模块", status="已完成", title="恢复设备连接",    assignee="王工", createdTime="5小时前", updatedTime="3小时前",  description="设备通讯异常，已重新配置网络"),
]

# ── Device Metrics ────────────────────────────────────────────────────────────

device_metrics = DeviceMetrics(
    temperature=42.3,
    voltage=220.5,
    current=15.2,
    power=3.35,
    energy=125.8,
    delay=12,
    isConnected=True,
)

# ── Realtime Events ───────────────────────────────────────────────────────────

realtime_events: list[RealtimeEvent] = [
    RealtimeEvent(type="alarm",     icon="warning", text="主轴承温度告警",       time="10分钟前"),
    RealtimeEvent(type="status",    icon="info",    text="设备启动完成",          time="1小时前"),
    RealtimeEvent(type="workorder", icon="work",    text="工单WO-2024-001已创建", time="2小时前"),
]

# ── Components ────────────────────────────────────────────────────────────────

components: list[Component] = [
    Component(
        id="1", name="主轴承", healthIndex=0.72, rul=180, rulRange="150-210",
        suggestions=["建议在未来30天内安排维护", "监控温度变化趋势", "准备备件"],
        metrics=[
            ComponentMetric(name="温度", value=78.5, unit="℃"),
            ComponentMetric(name="振动", value=2.3,  unit="mm/s"),
            ComponentMetric(name="压力", value=1.2,  unit="MPa"),
        ],
    ),
    Component(
        id="2", name="电机", healthIndex=0.85, rul=320, rulRange="280-350",
        suggestions=["状态良好", "保持定期巡检"],
        metrics=[
            ComponentMetric(name="温度", value=65.2, unit="℃"),
            ComponentMetric(name="电流", value=15.2, unit="A"),
        ],
    ),
    Component(
        id="3", name="IGBT模块", healthIndex=0.91, rul=450, rulRange="400-500",
        suggestions=["运行状态优秀", "按计划巡检即可"],
        metrics=[
            ComponentMetric(name="结温",     value=85.3,  unit="℃"),
            ComponentMetric(name="栅极电压", value=15.0,  unit="V"),
            ComponentMetric(name="集电极电流", value=120.0, unit="A"),
        ],
    ),
]

# ── Health Data ───────────────────────────────────────────────────────────────

health_data = HealthData(
    overallHI=0.78,
    overallRUL=180,
    rulRange="150-210",
    trend="declining",
    components=[
        ComponentHealth(name="主轴承",   hi=0.72, rul=180, status="warning"),
        ComponentHealth(name="电机绕组", hi=0.85, rul=320, status="good"),
        ComponentHealth(name="IGBT模块", hi=0.91, rul=450, status="good"),
        ComponentHealth(name="散热系统", hi=0.65, rul=120, status="warning"),
        ComponentHealth(name="电容组",   hi=0.95, rul=600, status="good"),
    ],
    predictions=[
        HealthPrediction(date="2024-03", hi=0.75),
        HealthPrediction(date="2024-06", hi=0.70),
        HealthPrediction(date="2024-09", hi=0.63),
        HealthPrediction(date="2024-12", hi=0.55),
        HealthPrediction(date="2025-03", hi=0.45),
    ],
    suggestions=[
        "建议在30天内检查主轴承",
        "散热系统需要清洁维护",
        "按计划更换润滑油",
        "准备轴承备件",
    ],
)
