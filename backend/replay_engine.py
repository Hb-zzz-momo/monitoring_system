from __future__ import annotations

import asyncio
import os
from datetime import datetime, timezone
from typing import Any

import database as db
from realtime_hub import realtime_hub


class SensorReplayEngine:
    def __init__(self) -> None:
        self._task: asyncio.Task[None] | None = None
        self._running = False
        self._interval_seconds = 1.5
        self._series: dict[str, list[dict[str, Any]]] = {}
        self._index: dict[str, int] = {}

    def is_running(self) -> bool:
        return self._running and self._task is not None and not self._task.done()

    def status(self) -> dict[str, Any]:
        return {
            "running": self.is_running(),
            "intervalSeconds": self._interval_seconds,
            "devices": sorted(self._series.keys()),
            "pointsPerDevice": {k: len(v) for k, v in self._series.items()},
        }

    def start(self, interval_seconds: float = 1.5) -> bool:
        if self.is_running():
            return False

        self._series = db.list_sensor_replay_series()
        if not self._series:
            return False

        self._interval_seconds = max(0.3, float(interval_seconds))
        self._index = {device_id: 0 for device_id in self._series.keys()}
        self._running = True
        self._task = asyncio.create_task(self._loop())
        return True

    async def stop(self) -> bool:
        if not self._task:
            self._running = False
            return False

        self._running = False
        self._task.cancel()
        try:
            await self._task
        except asyncio.CancelledError:
            pass
        finally:
            self._task = None
        return True

    async def _loop(self) -> None:
        try:
            while self._running:
                for device_id, samples in self._series.items():
                    if not samples:
                        continue

                    idx = self._index.get(device_id, 0)
                    if idx >= len(samples):
                        idx = 0

                    sample = samples[idx]
                    self._index[device_id] = (idx + 1) % len(samples)

                    payload = {
                        "deviceId": device_id,
                        "timestamp": datetime.now(timezone.utc).isoformat(timespec="seconds"),
                        "temperature": sample["temperature"],
                        "voltage": sample["voltage"],
                        "current": sample["current"],
                        "power": sample["power"],
                        "energy": sample["energy"],
                        "delay": sample["delay"],
                        "isConnected": bool(sample["isConnected"]),
                    }

                    latest_metrics = db.ingest_sensor_reading(payload, add_training_sample=False)
                    latest_events, _, _ = db.list_realtime_events_for_device(device_id=device_id, limit=10)
                    trend, _, _ = db.list_metric_history_for_device(
                        device_id=device_id,
                        metric="temperature",
                        points=20,
                    )

                    await realtime_hub.broadcast(
                        {
                            "type": "sensor_replay",
                            "deviceId": device_id,
                            "metrics": latest_metrics.model_dump(),
                            "events": [item.model_dump() for item in latest_events],
                            "trend": trend,
                        },
                        device_id=device_id,
                        channel="metrics",
                    )

                await asyncio.sleep(self._interval_seconds)
        except asyncio.CancelledError:
            raise
        finally:
            self._running = False
            self._task = None

    async def auto_start_if_enabled(self) -> None:
        enabled = os.getenv("SENSOR_REPLAY_AUTO_START", "1").strip().lower()
        if enabled not in {"1", "true", "yes", "on"}:
            return
        self.start(interval_seconds=float(os.getenv("SENSOR_REPLAY_INTERVAL", "1.5")))


sensor_replay_engine = SensorReplayEngine()
