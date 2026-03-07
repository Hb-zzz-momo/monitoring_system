# 设备监测系统 – 后端服务

基于 **FastAPI** 构建的 REST API 后端，为 Flutter 前端提供数据服务。

## 技术栈

| 组件 | 版本 |
|------|------|
| Python | ≥ 3.10 |
| FastAPI | 0.115 |
| Uvicorn | 0.32 |
| Pydantic | 2.x |

## 快速启动

```bash
# 1. 进入后端目录
cd backend

# 2. （推荐）创建虚拟环境
python3 -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate

# 3. 安装依赖
pip install -r requirements.txt

# 4. 启动服务（默认端口 8000）
uvicorn main:app --reload
```

服务启动后访问：
- API 根路径：<http://localhost:8000/>
- 交互式文档：<http://localhost:8000/docs>
- ReDoc 文档： <http://localhost:8000/redoc>

## 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `JWT_SECRET_KEY` | `change-me-in-production-…` | JWT 签名密钥，**生产环境必须修改** |
| `CORS_ORIGINS` | `http://localhost:3000,http://localhost:8080` | 允许的跨域来源（逗号分隔） |
| `LOCAL_TRAIN_COMMAND` | 空 | 本地训练命令（为空时自动尝试项目根目录 `train_local_model.bat`） |
| `LOCAL_DEPLOY_COMMAND` | 空 | 训练成功后自动执行的部署命令（为空时自动尝试项目根目录 `serve_trained_model.bat`） |
| `LOCAL_DEPLOY_HEALTH_URL` | `http://127.0.0.1:8008/v1/models` | 自动部署后健康检查地址（返回 2xx 视为成功） |

示例（Linux/macOS）：
```bash
export JWT_SECRET_KEY="$(openssl rand -hex 32)"
export CORS_ORIGINS="https://your-frontend.example.com"
uvicorn main:app
```

## API 端点一览

### 认证

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/auth/login` | 登录，返回 token |

演示账号：
- 用户名 `demo` / 密码 `demo123`（操作员）
- 用户名 `admin` / 密码 `admin123`（管理员）

鉴权规则：
- 除 `/auth/login` 外，所有接口都需要 `Authorization: Bearer <token>`。
- 写操作（`PUT`/创建工单/训练管理）默认要求 `admin` 角色。

### 设备

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/devices` | 获取全部设备列表 |
| GET | `/devices/{id}` | 获取单台设备详情 |
| PUT | `/devices/{id}` | 更新设备字段 |

### 告警

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/alarms` | 获取全部告警 |
| GET | `/alarms/{id}` | 获取单条告警 |
| PUT | `/alarms/{id}` | 更新告警状态 |

### 工单

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/work-orders` | 获取全部工单 |
| GET | `/work-orders/{id}` | 获取单条工单 |
| PUT | `/work-orders/{id}` | 更新工单状态/负责人 |

### 监测指标

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/metrics` | 实时设备指标（温度/电压/电流/功率等） |
| GET | `/metrics/events` | 最新实时事件列表 |
| GET | `/metrics/health` | 健康寿命数据 |
| GET | `/metrics/devices/{id}` | 单设备实时指标（含 `isSimulated` / `dataSource`） |
| GET | `/metrics/devices/{id}/history` | 单设备历史曲线（含 `isSimulated` / `dataSource`） |
| GET | `/metrics/devices/{id}/events` | 单设备事件流（含 `isSimulated` / `dataSource`） |
| GET | `/metrics/devices/{id}/health` | 单设备健康寿命（含 `isSimulated` / `dataSource`） |
| WS  | `/metrics/stream?token=...&device_id=...` | 鉴权实时推送流（支持设备过滤） |

说明：当设备尚未接入真实传感器数据时，接口会返回回退数据，并通过 `isSimulated=true` 与 `dataSource=fallback-*` 显式标注。

### 传感器接入

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/sensors/ingest` | 统一传感器数据入口（入库 + 训练样本沉淀 + 实时广播） |

示例请求：

```json
{
	"deviceId": "1",
	"temperature": 43.6,
	"voltage": 221.2,
	"current": 14.8,
	"power": 3.28,
	"energy": 126.4,
	"delay": 8,
	"isConnected": true
}
```

### 本地训练

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/ai/training/samples/collect/device` | 从设备数据生成训练样本 |
| POST | `/ai/training/samples/collect/alarm` | 从告警数据生成训练样本 |
| POST | `/ai/training/samples` | 手动新增训练样本 |
| GET  | `/ai/training/samples` | 查询训练样本 |
| DELETE | `/ai/training/samples/{sample_id}` | 删除指定训练样本 |
| POST | `/ai/training/export` | 导出 `local_ai/data/train.jsonl` |
| POST | `/ai/training/jobs/start` | 启动本地训练任务 |
| GET  | `/ai/training/jobs` | 查询训练任务状态 |

### AI 建议与回写

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/ai/recommendations/devices/{id}` | 生成设备证据化建议（返回证据、置信度） |
| POST | `/ai/recommendations/devices/{id}?create_work_order=true` | 生成建议并自动回写工单（仅管理员） |

### 部件

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/components` | 获取全部部件 |
| GET | `/components/{id}` | 获取单个部件详情 |

## 前端对接

Flutter 前端通过 `lib/services/api_service.dart` 调用后端。
默认连接地址为 `http://localhost:8000`，可在该文件顶部的 `_kBaseUrl` 常量中修改。

## 数据存储

当前版本使用 **SQLite 持久化存储**（`database.py` + `monitoring.db`）。
首次启动会自动建表并写入初始演示数据，后续重启服务数据不会丢失。
表结构定义见 `schema.sql`。

## 目录结构

```
backend/
├── main.py            # FastAPI 应用入口、CORS 配置、路由注册
├── models.py          # Pydantic 数据模型
├── database.py        # SQLite 数据访问层（自动建表/初始化数据）
├── schema.sql         # 持久化数据库表结构
├── requirements.txt   # Python 依赖
├── routers/
│   ├── auth.py        # 认证路由
│   ├── devices.py     # 设备路由
│   ├── alarms.py      # 告警路由
│   ├── work_orders.py # 工单路由
│   ├── metrics.py     # 指标路由
│   ├── components.py  # 部件路由
│   ├── sensors.py     # 传感器接入路由
│   ├── training.py    # 本地训练路由
│   └── ai_recommendations.py # AI 建议与工单回写路由
├── security.py        # JWT 鉴权与 RBAC 依赖
├── realtime_hub.py    # WebSocket 实时广播中心
└── README.md          # 本文件
```
