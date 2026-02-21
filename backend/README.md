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

### 部件

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/components` | 获取全部部件 |
| GET | `/components/{id}` | 获取单个部件详情 |

## 前端对接

Flutter 前端通过 `lib/services/api_service.dart` 调用后端。
默认连接地址为 `http://localhost:8000`，可在该文件顶部的 `_kBaseUrl` 常量中修改。

## 数据存储

当前版本使用**内存数据库**（`database.py`），初始数据与 Flutter 端 mock_data.dart 保持一致。
重启服务后数据会重置。如需持久化，可将 `database.py` 中的列表替换为 SQLite / PostgreSQL 连接。

## 目录结构

```
backend/
├── main.py            # FastAPI 应用入口、CORS 配置、路由注册
├── models.py          # Pydantic 数据模型
├── database.py        # 内存数据存储（初始数据）
├── requirements.txt   # Python 依赖
├── routers/
│   ├── auth.py        # 认证路由
│   ├── devices.py     # 设备路由
│   ├── alarms.py      # 告警路由
│   ├── work_orders.py # 工单路由
│   ├── metrics.py     # 指标路由
│   └── components.py  # 部件路由
└── README.md          # 本文件
```
