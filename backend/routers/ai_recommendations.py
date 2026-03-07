from fastapi import APIRouter, Depends, HTTPException, Query

import database as db
from models import AiRecommendationEvidence, AiRecommendationResponse
from security import get_current_user, require_admin

router = APIRouter(prefix="/ai/recommendations", tags=["ai-recommendations"])


@router.post("/devices/{device_id}", response_model=AiRecommendationResponse)
def recommend_for_device(
    device_id: str,
    create_work_order: bool = Query(default=False),
    _current_user: dict = Depends(get_current_user),
):
    device = db.get_device(device_id)
    if not device:
        raise HTTPException(status_code=404, detail="设备不存在")

    metrics, metrics_simulated, metrics_source = db.get_latest_metrics_for_device(device_id)
    health, health_simulated, health_source = db.get_latest_health_for_device(device_id)

    high_alarm_count = sum(1 for alarm in db.list_alarms() if alarm.level == "danger" and alarm.status == "进行中")

    evidence = [
        AiRecommendationEvidence(type="metric", title="温度", value=f"{metrics.temperature:.1f}°C"),
        AiRecommendationEvidence(type="metric", title="功率", value=f"{metrics.power:.2f}kW"),
        AiRecommendationEvidence(type="health", title="整体HI", value=f"{health.overallHI:.2f}"),
        AiRecommendationEvidence(type="health", title="整体RUL", value=f"{health.overallRUL}天"),
        AiRecommendationEvidence(type="meta", title="指标来源", value=metrics_source),
        AiRecommendationEvidence(type="meta", title="健康来源", value=health_source),
        AiRecommendationEvidence(type="alarm", title="高危未处理告警", value=str(high_alarm_count)),
    ]

    risk_score = 0.0
    risk_score += min(1.0, max(0.0, (metrics.temperature - 40.0) / 40.0)) * 0.45
    risk_score += min(1.0, max(0.0, metrics.power / 8.0)) * 0.2
    risk_score += (1.0 - health.overallHI) * 0.3
    risk_score += (0.05 if high_alarm_count > 0 else 0.0)
    risk_score += (0.05 if metrics_simulated or health_simulated else 0.0)
    confidence = max(0.5, min(0.96, 1.0 - risk_score * 0.35))

    if metrics.temperature >= 75 or health.overallHI < 0.6:
        summary = f"设备 {device.name} 风险较高，建议立即执行降载与现场检查。"
        suggestion = "优先检查散热系统、轴承振动与供电稳定性，必要时停机并生成抢修工单。"
    elif metrics.temperature >= 60 or health.overallHI < 0.8:
        summary = f"设备 {device.name} 存在中等风险，建议提升巡检频次。"
        suggestion = "未来24小时内进行专项点检，复核温升趋势并准备关键备件。"
    else:
        summary = f"设备 {device.name} 运行状态总体稳定。"
        suggestion = "保持计划性巡检，持续跟踪温度与功率趋势，暂不建议额外停机动作。"

    created_work_order_id = None
    if create_work_order:
        require_admin(_current_user)
        work_order = db.create_work_order(
            device=device.name,
            component="整机",
            title=f"AI建议巡检: {device.name}",
            description=f"{summary}\n建议: {suggestion}",
            assignee="待分配",
        )
        created_work_order_id = work_order.id

    return AiRecommendationResponse(
        deviceId=device_id,
        summary=summary,
        suggestion=suggestion,
        confidence=confidence,
        evidence=evidence,
        createdWorkOrderId=created_work_order_id,
    )
