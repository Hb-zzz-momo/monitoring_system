# 数据库表映射（与现有接口对应）

本文件对应 `backend/schema.sql` 与 `backend/database.py`，用于说明当前已落地的持久化数据库结构。

## 认证

- API: `/auth/login`
- 表: `users`
- 字段映射:
  - `username` -> `users.username`
  - `password(明文输入)` -> 与 `users.password_hash` 做 bcrypt 校验
  - `role` -> `users.role`

## 设备

- API: `/devices`, `/devices/{id}`
- 表: `devices`
- 模型字段映射:
  - `id` -> `devices.id`
  - `name` -> `devices.name`
  - `isOnline` -> `devices.is_online`
  - `lastUpdate` -> `devices.last_update`
  - `temperature` -> `devices.temperature`
  - `power` -> `devices.power`
  - `healthIndex` -> `devices.health_index`
  - `rul` -> `devices.rul`

## 告警

- API: `/alarms`, `/alarms/{id}`
- 表: `alarms`
- 模型字段映射:
  - `id` -> `alarms.id`
  - `title` -> `alarms.title`
  - `level` -> `alarms.level`
  - `device` -> `alarms.device`
  - `component` -> `alarms.component`
  - `time` -> `alarms.alarm_time`
  - `currentValue` -> `alarms.current_value`
  - `threshold` -> `alarms.threshold`
  - `status` -> `alarms.status`
  - `description` -> `alarms.description`

## 工单

- API: `/work-orders`, `/work-orders/{id}`
- 表: `work_orders`
- 模型字段映射:
  - `id` -> `work_orders.id`
  - `device` -> `work_orders.device`
  - `component` -> `work_orders.component`
  - `status` -> `work_orders.status`
  - `title` -> `work_orders.title`
  - `assignee` -> `work_orders.assignee`
  - `createdTime` -> `work_orders.created_time`
  - `updatedTime` -> `work_orders.updated_time`
  - `description` -> `work_orders.description`

## 指标与事件

- API: `/metrics`
  - 表: `metric_snapshots`
  - 返回策略: 取 `collected_at` 最新一条
- API: `/metrics/events`
  - 表: `realtime_events`
- API: `/metrics/health`
  - 主表: `health_snapshots`
  - 子表: `health_components`, `health_predictions`, `health_suggestions`

## 部件

- API: `/components`, `/components/{id}`
- 主表: `components`
- 子表:
  - `component_metrics`
  - `component_suggestions`
