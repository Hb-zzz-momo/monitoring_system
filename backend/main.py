"""设备监测系统后端 – FastAPI 应用入口"""

import os
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from replay_engine import sensor_replay_engine
from routers import auth, devices, alarms, work_orders, metrics, components, ai_proxy, sensors, training, ai_recommendations

app = FastAPI(
    title="设备监测系统 API",
    description="为 Flutter 前端提供 REST API 服务",
    version="1.0.0",
)

# Allowed origins are read from the CORS_ORIGINS environment variable
# (comma-separated).  Default to localhost ports used during development.
# Set CORS_ORIGINS='*' only if you specifically need unrestricted access.
_raw_origins = os.getenv("CORS_ORIGINS", "http://localhost:3000,http://localhost:8080")
_allowed_origins = [o.strip() for o in _raw_origins.split(",") if o.strip()]

app.add_middleware(
    CORSMiddleware,
    allow_origins=_allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(devices.router)
app.include_router(alarms.router)
app.include_router(work_orders.router)
app.include_router(metrics.router)
app.include_router(components.router)
app.include_router(ai_proxy.router)
app.include_router(sensors.router)
app.include_router(training.router)
app.include_router(ai_recommendations.router)

_uploads_dir = Path(__file__).resolve().parent / "uploads"
_uploads_dir.mkdir(parents=True, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=str(_uploads_dir)), name="uploads")


@app.get("/", tags=["root"])
def root():
    return {"message": "设备监测系统 API 正常运行", "docs": "/docs"}


@app.on_event("startup")
async def _startup() -> None:
    await sensor_replay_engine.auto_start_if_enabled()


@app.on_event("shutdown")
async def _shutdown() -> None:
    await sensor_replay_engine.stop()
