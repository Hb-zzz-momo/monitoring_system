"""SQLite persistent data store initialised from the original mock dataset."""

from __future__ import annotations

import json
import sqlite3
from datetime import datetime, timezone
import math
from contextlib import contextmanager
from pathlib import Path
from typing import Any, Iterator, Optional
from uuid import uuid4

from models import (
    Alarm,
    Component,
    ComponentHealth,
    ComponentMetric,
    Device,
    DeviceMetrics,
    HealthData,
    HealthPrediction,
    RealtimeEvent,
    TrainingJob,
    TrainingSample,
    WorkOrder,
)

_DB_PATH = Path(__file__).resolve().parent / "monitoring.db"


def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def _normalize_timestamp(value: Optional[str]) -> str:
    if not value:
        return _now_iso()

    text = value.strip()
    if not text:
        return _now_iso()

    if text.endswith("Z"):
        text = text[:-1] + "+00:00"

    try:
        dt = datetime.fromisoformat(text)
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        return dt.isoformat(timespec="seconds")
    except ValueError:
        pass

    for fmt in ("%Y-%m-%d %H:%M:%S", "%Y-%m-%d %H:%M"):
        try:
            dt = datetime.strptime(text, fmt).replace(tzinfo=timezone.utc)
            return dt.isoformat(timespec="seconds")
        except ValueError:
            continue

    return _now_iso()


def _ensure_schema_migrations(conn: sqlite3.Connection) -> None:
    realtime_columns = {
        row["name"] for row in conn.execute("PRAGMA table_info(realtime_events)").fetchall()
    }
    if "device_id" not in realtime_columns:
        conn.execute("ALTER TABLE realtime_events ADD COLUMN device_id TEXT")

    health_columns = {
        row["name"] for row in conn.execute("PRAGMA table_info(health_snapshots)").fetchall()
    }
    if "device_id" not in health_columns:
        conn.execute("ALTER TABLE health_snapshots ADD COLUMN device_id TEXT")


def _connect() -> sqlite3.Connection:
    conn = sqlite3.connect(_DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


@contextmanager
def _get_conn() -> Iterator[sqlite3.Connection]:
    conn = _connect()
    try:
        yield conn
        conn.commit()
    finally:
        conn.close()


def init_db() -> None:
    with _get_conn() as conn:
        conn.executescript(
            """
            CREATE TABLE IF NOT EXISTS users (
                username TEXT PRIMARY KEY,
                password_hash TEXT NOT NULL,
                role TEXT NOT NULL CHECK (role IN ('operator', 'admin')),
                is_active INTEGER NOT NULL DEFAULT 1,
                created_at TEXT NOT NULL DEFAULT (datetime('now')),
                updated_at TEXT NOT NULL DEFAULT (datetime('now'))
            );

            CREATE TABLE IF NOT EXISTS devices (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                is_online INTEGER NOT NULL,
                last_update TEXT NOT NULL,
                temperature REAL NOT NULL,
                power REAL NOT NULL,
                health_index REAL NOT NULL,
                rul INTEGER NOT NULL,
                created_at TEXT NOT NULL DEFAULT (datetime('now')),
                updated_at TEXT NOT NULL DEFAULT (datetime('now'))
            );

            CREATE TABLE IF NOT EXISTS alarms (
                id TEXT PRIMARY KEY,
                title TEXT NOT NULL,
                level TEXT NOT NULL CHECK (level IN ('danger', 'warning', 'info')),
                device TEXT NOT NULL,
                component TEXT NOT NULL,
                alarm_time TEXT NOT NULL,
                current_value REAL NOT NULL,
                threshold REAL NOT NULL,
                status TEXT NOT NULL CHECK (status IN ('进行中', '已处理')),
                description TEXT NOT NULL,
                created_at TEXT NOT NULL DEFAULT (datetime('now')),
                updated_at TEXT NOT NULL DEFAULT (datetime('now'))
            );

            CREATE TABLE IF NOT EXISTS work_orders (
                id TEXT PRIMARY KEY,
                device TEXT NOT NULL,
                component TEXT NOT NULL,
                status TEXT NOT NULL CHECK (status IN ('待处理', '处理中', '已完成')),
                title TEXT NOT NULL,
                assignee TEXT NOT NULL,
                created_time TEXT NOT NULL,
                updated_time TEXT NOT NULL,
                description TEXT NOT NULL,
                created_at TEXT NOT NULL DEFAULT (datetime('now')),
                updated_at TEXT NOT NULL DEFAULT (datetime('now'))
            );

            CREATE TABLE IF NOT EXISTS components (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                health_index REAL NOT NULL,
                rul INTEGER NOT NULL,
                rul_range TEXT NOT NULL,
                created_at TEXT NOT NULL DEFAULT (datetime('now')),
                updated_at TEXT NOT NULL DEFAULT (datetime('now'))
            );

            CREATE TABLE IF NOT EXISTS component_metrics (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                component_id TEXT NOT NULL,
                metric_name TEXT NOT NULL,
                metric_value REAL NOT NULL,
                metric_unit TEXT NOT NULL,
                seq INTEGER NOT NULL DEFAULT 0,
                created_at TEXT NOT NULL DEFAULT (datetime('now')),
                FOREIGN KEY (component_id) REFERENCES components(id) ON DELETE CASCADE ON UPDATE CASCADE
            );

            CREATE TABLE IF NOT EXISTS component_suggestions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                component_id TEXT NOT NULL,
                suggestion TEXT NOT NULL,
                seq INTEGER NOT NULL DEFAULT 0,
                created_at TEXT NOT NULL DEFAULT (datetime('now')),
                FOREIGN KEY (component_id) REFERENCES components(id) ON DELETE CASCADE ON UPDATE CASCADE
            );

            CREATE TABLE IF NOT EXISTS metric_snapshots (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                temperature REAL NOT NULL,
                voltage REAL NOT NULL,
                current REAL NOT NULL,
                power REAL NOT NULL,
                energy REAL NOT NULL,
                delay INTEGER NOT NULL,
                is_connected INTEGER NOT NULL,
                collected_at TEXT NOT NULL DEFAULT (datetime('now'))
            );

            CREATE TABLE IF NOT EXISTS realtime_events (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                event_type TEXT NOT NULL,
                icon TEXT NOT NULL,
                text TEXT NOT NULL,
                event_time TEXT NOT NULL,
                created_at TEXT NOT NULL DEFAULT (datetime('now'))
            );

            CREATE TABLE IF NOT EXISTS sensor_readings (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                device_id TEXT NOT NULL,
                reading_time TEXT NOT NULL,
                temperature REAL NOT NULL,
                voltage REAL NOT NULL,
                current REAL NOT NULL,
                power REAL NOT NULL,
                energy REAL NOT NULL,
                delay INTEGER NOT NULL,
                is_connected INTEGER NOT NULL,
                raw_payload TEXT,
                created_at TEXT NOT NULL DEFAULT (datetime('now'))
            );

            CREATE TABLE IF NOT EXISTS training_samples (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                source TEXT NOT NULL,
                input_text TEXT NOT NULL,
                expected_output TEXT NOT NULL,
                created_at TEXT NOT NULL DEFAULT (datetime('now'))
            );

            CREATE TABLE IF NOT EXISTS training_jobs (
                id TEXT PRIMARY KEY,
                status TEXT NOT NULL,
                total_samples INTEGER NOT NULL,
                processed_samples INTEGER NOT NULL DEFAULT 0,
                model_name TEXT,
                message TEXT,
                created_at TEXT NOT NULL DEFAULT (datetime('now')),
                updated_at TEXT NOT NULL DEFAULT (datetime('now'))
            );

            CREATE TABLE IF NOT EXISTS health_snapshots (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                overall_hi REAL NOT NULL,
                overall_rul INTEGER NOT NULL,
                rul_range TEXT NOT NULL,
                trend TEXT NOT NULL,
                collected_at TEXT NOT NULL DEFAULT (datetime('now'))
            );

            CREATE TABLE IF NOT EXISTS health_components (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                snapshot_id INTEGER NOT NULL,
                component_name TEXT NOT NULL,
                hi REAL NOT NULL,
                rul INTEGER NOT NULL,
                status TEXT NOT NULL,
                seq INTEGER NOT NULL DEFAULT 0,
                FOREIGN KEY (snapshot_id) REFERENCES health_snapshots(id) ON DELETE CASCADE ON UPDATE CASCADE
            );

            CREATE TABLE IF NOT EXISTS health_predictions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                snapshot_id INTEGER NOT NULL,
                prediction_date TEXT NOT NULL,
                hi REAL NOT NULL,
                seq INTEGER NOT NULL DEFAULT 0,
                FOREIGN KEY (snapshot_id) REFERENCES health_snapshots(id) ON DELETE CASCADE ON UPDATE CASCADE
            );

            CREATE TABLE IF NOT EXISTS health_suggestions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                snapshot_id INTEGER NOT NULL,
                suggestion TEXT NOT NULL,
                seq INTEGER NOT NULL DEFAULT 0,
                FOREIGN KEY (snapshot_id) REFERENCES health_snapshots(id) ON DELETE CASCADE ON UPDATE CASCADE
            );

            CREATE INDEX IF NOT EXISTS idx_alarms_status ON alarms(status);
            CREATE INDEX IF NOT EXISTS idx_work_orders_status ON work_orders(status);
            CREATE INDEX IF NOT EXISTS idx_metric_snapshots_collected_at ON metric_snapshots(collected_at);
            CREATE INDEX IF NOT EXISTS idx_realtime_events_created_at ON realtime_events(created_at);
            CREATE INDEX IF NOT EXISTS idx_sensor_readings_device_time ON sensor_readings(device_id, reading_time DESC);
            CREATE INDEX IF NOT EXISTS idx_training_samples_source ON training_samples(source);
            CREATE INDEX IF NOT EXISTS idx_training_jobs_created_at ON training_jobs(created_at DESC);
            """
        )
        _ensure_schema_migrations(conn)
        _seed_if_needed(conn)


def _seed_if_needed(conn: sqlite3.Connection) -> None:
    users_count = conn.execute("SELECT COUNT(1) AS cnt FROM users").fetchone()["cnt"]
    if users_count == 0:
        conn.executemany(
            "INSERT INTO users (username, password_hash, role) VALUES (?, ?, ?)",
            [
                ("demo", "demo123", "operator"),
                ("admin", "admin123", "admin"),
            ],
        )

    devices_count = conn.execute("SELECT COUNT(1) AS cnt FROM devices").fetchone()["cnt"]
    if devices_count == 0:
        conn.executemany(
            """
            INSERT INTO devices (id, name, is_online, last_update, temperature, power, health_index, rul)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            [
                ("1", "主控设备-01", 1, "2分钟前", 42.3, 3.2, 0.72, 180),
                ("2", "监测设备-02", 1, "5分钟前", 38.7, 2.8, 0.85, 320),
                ("3", "备用设备-03", 0, "2小时前", 25.0, 0.0, 0.95, 500),
                ("4", "测试设备-04", 1, "刚刚", 45.2, 4.1, 0.58, 90),
            ],
        )

    alarms_count = conn.execute("SELECT COUNT(1) AS cnt FROM alarms").fetchone()["cnt"]
    if alarms_count == 0:
        conn.executemany(
            """
            INSERT INTO alarms (id, title, level, device, component, alarm_time, current_value, threshold, status, description)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            [
                ("1", "部件过温告警", "danger", "主控设备-01", "主轴承", "10分钟前", 78.5, 75.0, "进行中", "主轴承温度超过阈值"),
                ("2", "电压异常预警", "warning", "监测设备-02", "电源模块", "1小时前", 235.0, 240.0, "进行中", "电压接近上限"),
                ("3", "连接异常", "warning", "备用设备-03", "通讯模块", "2小时前", 0.0, 0.0, "已处理", "设备离线"),
            ],
        )

    work_orders_count = conn.execute("SELECT COUNT(1) AS cnt FROM work_orders").fetchone()["cnt"]
    if work_orders_count == 0:
        conn.executemany(
            """
            INSERT INTO work_orders (id, device, component, status, title, assignee, created_time, updated_time, description)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            [
                ("WO-2024-001", "主控设备-01", "主轴承", "处理中", "更换主轴承", "张工", "2小时前", "30分钟前", "主轴承温度持续偏高，需要检查并更换"),
                ("WO-2024-002", "监测设备-02", "电源模块", "待处理", "检查电压稳定性", "李工", "1小时前", "1小时前", "电压波动异常，需要检查电源模块"),
                ("WO-2024-003", "备用设备-03", "通讯模块", "已完成", "恢复设备连接", "王工", "5小时前", "3小时前", "设备通讯异常，已重新配置网络"),
            ],
        )

    metric_count = conn.execute("SELECT COUNT(1) AS cnt FROM metric_snapshots").fetchone()["cnt"]
    if metric_count == 0:
        conn.execute(
            """
            INSERT INTO metric_snapshots (temperature, voltage, current, power, energy, delay, is_connected)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            (42.3, 220.5, 15.2, 3.35, 125.8, 12, 1),
        )

    event_count = conn.execute("SELECT COUNT(1) AS cnt FROM realtime_events").fetchone()["cnt"]
    if event_count == 0:
        conn.executemany(
            "INSERT INTO realtime_events (event_type, icon, text, event_time) VALUES (?, ?, ?, ?)",
            [
                ("alarm", "warning", "主轴承温度告警", "10分钟前"),
                ("status", "info", "设备启动完成", "1小时前"),
                ("workorder", "work", "工单WO-2024-001已创建", "2小时前"),
            ],
        )

    components_count = conn.execute("SELECT COUNT(1) AS cnt FROM components").fetchone()["cnt"]
    if components_count == 0:
        conn.executemany(
            "INSERT INTO components (id, name, health_index, rul, rul_range) VALUES (?, ?, ?, ?, ?)",
            [
                ("1", "主轴承", 0.72, 180, "150-210"),
                ("2", "电机", 0.85, 320, "280-350"),
                ("3", "IGBT模块", 0.91, 450, "400-500"),
            ],
        )
        conn.executemany(
            """
            INSERT INTO component_suggestions (component_id, suggestion, seq)
            VALUES (?, ?, ?)
            """,
            [
                ("1", "建议在未来30天内安排维护", 0),
                ("1", "监控温度变化趋势", 1),
                ("1", "准备备件", 2),
                ("2", "状态良好", 0),
                ("2", "保持定期巡检", 1),
                ("3", "运行状态优秀", 0),
                ("3", "按计划巡检即可", 1),
            ],
        )
        conn.executemany(
            """
            INSERT INTO component_metrics (component_id, metric_name, metric_value, metric_unit, seq)
            VALUES (?, ?, ?, ?, ?)
            """,
            [
                ("1", "温度", 78.5, "℃", 0),
                ("1", "振动", 2.3, "mm/s", 1),
                ("1", "压力", 1.2, "MPa", 2),
                ("2", "温度", 65.2, "℃", 0),
                ("2", "电流", 15.2, "A", 1),
                ("3", "结温", 85.3, "℃", 0),
                ("3", "栅极电压", 15.0, "V", 1),
                ("3", "集电极电流", 120.0, "A", 2),
            ],
        )

    health_count = conn.execute("SELECT COUNT(1) AS cnt FROM health_snapshots").fetchone()["cnt"]
    if health_count == 0:
        cursor = conn.execute(
            "INSERT INTO health_snapshots (overall_hi, overall_rul, rul_range, trend) VALUES (?, ?, ?, ?)",
            (0.78, 180, "150-210", "declining"),
        )
        snapshot_id = cursor.lastrowid
        conn.executemany(
            """
            INSERT INTO health_components (snapshot_id, component_name, hi, rul, status, seq)
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            [
                (snapshot_id, "主轴承", 0.72, 180, "warning", 0),
                (snapshot_id, "电机绕组", 0.85, 320, "good", 1),
                (snapshot_id, "IGBT模块", 0.91, 450, "good", 2),
                (snapshot_id, "散热系统", 0.65, 120, "warning", 3),
                (snapshot_id, "电容组", 0.95, 600, "good", 4),
            ],
        )
        conn.executemany(
            "INSERT INTO health_predictions (snapshot_id, prediction_date, hi, seq) VALUES (?, ?, ?, ?)",
            [
                (snapshot_id, "2024-03", 0.75, 0),
                (snapshot_id, "2024-06", 0.70, 1),
                (snapshot_id, "2024-09", 0.63, 2),
                (snapshot_id, "2024-12", 0.55, 3),
                (snapshot_id, "2025-03", 0.45, 4),
            ],
        )
        conn.executemany(
            "INSERT INTO health_suggestions (snapshot_id, suggestion, seq) VALUES (?, ?, ?)",
            [
                (snapshot_id, "建议在30天内检查主轴承", 0),
                (snapshot_id, "散热系统需要清洁维护", 1),
                (snapshot_id, "按计划更换润滑油", 2),
                (snapshot_id, "准备轴承备件", 3),
            ],
        )


def _row_to_device(row: sqlite3.Row) -> Device:
    return Device(
        id=row["id"],
        name=row["name"],
        isOnline=bool(row["is_online"]),
        lastUpdate=row["last_update"],
        temperature=row["temperature"],
        power=row["power"],
        healthIndex=row["health_index"],
        rul=row["rul"],
    )


def list_devices() -> list[Device]:
    with _get_conn() as conn:
        rows = conn.execute("SELECT * FROM devices ORDER BY id").fetchall()
        return [_row_to_device(row) for row in rows]


def get_device(device_id: str) -> Optional[Device]:
    with _get_conn() as conn:
        row = conn.execute("SELECT * FROM devices WHERE id = ?", (device_id,)).fetchone()
        return _row_to_device(row) if row else None


def update_device(device_id: str, updates: dict[str, Any]) -> Optional[Device]:
    field_map = {
        "name": "name",
        "isOnline": "is_online",
        "temperature": "temperature",
        "power": "power",
        "healthIndex": "health_index",
        "rul": "rul",
    }

    set_parts: list[str] = []
    values: list[Any] = []
    for key, value in updates.items():
        column = field_map.get(key)
        if column is None:
            continue
        if column == "is_online":
            value = int(bool(value))
        set_parts.append(f"{column} = ?")
        values.append(value)

    if not set_parts:
        return get_device(device_id)

    values.append(device_id)
    with _get_conn() as conn:
        cursor = conn.execute(
            f"UPDATE devices SET {', '.join(set_parts)}, updated_at = datetime('now') WHERE id = ?",
            values,
        )
        if cursor.rowcount == 0:
            return None
        row = conn.execute("SELECT * FROM devices WHERE id = ?", (device_id,)).fetchone()
        return _row_to_device(row)


def _row_to_alarm(row: sqlite3.Row) -> Alarm:
    return Alarm(
        id=row["id"],
        title=row["title"],
        level=row["level"],
        device=row["device"],
        component=row["component"],
        time=row["alarm_time"],
        currentValue=row["current_value"],
        threshold=row["threshold"],
        status=row["status"],
        description=row["description"],
    )


def list_alarms() -> list[Alarm]:
    with _get_conn() as conn:
        rows = conn.execute("SELECT * FROM alarms ORDER BY id").fetchall()
        return [_row_to_alarm(row) for row in rows]


def get_alarm(alarm_id: str) -> Optional[Alarm]:
    with _get_conn() as conn:
        row = conn.execute("SELECT * FROM alarms WHERE id = ?", (alarm_id,)).fetchone()
        return _row_to_alarm(row) if row else None


def update_alarm(alarm_id: str, updates: dict[str, Any]) -> Optional[Alarm]:
    if "status" not in updates:
        return get_alarm(alarm_id)

    with _get_conn() as conn:
        cursor = conn.execute(
            "UPDATE alarms SET status = ?, updated_at = datetime('now') WHERE id = ?",
            (updates["status"], alarm_id),
        )
        if cursor.rowcount == 0:
            return None
        row = conn.execute("SELECT * FROM alarms WHERE id = ?", (alarm_id,)).fetchone()
        return _row_to_alarm(row)


def _row_to_work_order(row: sqlite3.Row) -> WorkOrder:
    return WorkOrder(
        id=row["id"],
        device=row["device"],
        component=row["component"],
        status=row["status"],
        title=row["title"],
        assignee=row["assignee"],
        createdTime=row["created_time"],
        updatedTime=row["updated_time"],
        description=row["description"],
    )


def list_work_orders() -> list[WorkOrder]:
    with _get_conn() as conn:
        rows = conn.execute("SELECT * FROM work_orders ORDER BY id").fetchall()
        return [_row_to_work_order(row) for row in rows]


def get_work_order(order_id: str) -> Optional[WorkOrder]:
    with _get_conn() as conn:
        row = conn.execute("SELECT * FROM work_orders WHERE id = ?", (order_id,)).fetchone()
        return _row_to_work_order(row) if row else None


def update_work_order(order_id: str, updates: dict[str, Any]) -> Optional[WorkOrder]:
    field_map = {
        "status": "status",
        "assignee": "assignee",
        "description": "description",
    }
    set_parts: list[str] = []
    values: list[Any] = []

    for key, value in updates.items():
        column = field_map.get(key)
        if column is None:
            continue
        set_parts.append(f"{column} = ?")
        values.append(value)

    if not set_parts:
        return get_work_order(order_id)

    values.append(order_id)
    with _get_conn() as conn:
        cursor = conn.execute(
            f"UPDATE work_orders SET {', '.join(set_parts)}, updated_at = datetime('now') WHERE id = ?",
            values,
        )
        if cursor.rowcount == 0:
            return None
        row = conn.execute("SELECT * FROM work_orders WHERE id = ?", (order_id,)).fetchone()
        return _row_to_work_order(row)


def create_work_order_from_alarm(alarm_id: str) -> Optional[WorkOrder]:
    with _get_conn() as conn:
        alarm_row = conn.execute("SELECT * FROM alarms WHERE id = ?", (alarm_id,)).fetchone()
        if not alarm_row:
            return None

        year = datetime.now().year
        prefix = f"WO-{year}-"
        latest_row = conn.execute(
            "SELECT id FROM work_orders WHERE id LIKE ? ORDER BY id DESC LIMIT 1",
            (f"{prefix}%",),
        ).fetchone()

        if latest_row:
            try:
                latest_number = int(str(latest_row["id"]).split("-")[-1])
            except ValueError:
                latest_number = 0
        else:
            latest_number = 0

        new_id = f"{prefix}{latest_number + 1:03d}"
        now_text = datetime.now().strftime("%Y-%m-%d %H:%M")
        title = f"处理告警: {alarm_row['title']}"
        description = f"由告警自动生成工单。告警描述: {alarm_row['description']}"

        conn.execute(
            """
            INSERT INTO work_orders (id, device, component, status, title, assignee, created_time, updated_time, description)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                new_id,
                alarm_row["device"],
                alarm_row["component"],
                "待处理",
                title,
                "待分配",
                now_text,
                now_text,
                description,
            ),
        )

        row = conn.execute("SELECT * FROM work_orders WHERE id = ?", (new_id,)).fetchone()
        return _row_to_work_order(row)


def create_work_order(
    *,
    device: str,
    component: str,
    title: str,
    description: str,
    assignee: str = "待分配",
) -> WorkOrder:
    with _get_conn() as conn:
        year = datetime.now().year
        prefix = f"WO-{year}-"
        latest_row = conn.execute(
            "SELECT id FROM work_orders WHERE id LIKE ? ORDER BY id DESC LIMIT 1",
            (f"{prefix}%",),
        ).fetchone()

        if latest_row:
            try:
                latest_number = int(str(latest_row["id"]).split("-")[-1])
            except ValueError:
                latest_number = 0
        else:
            latest_number = 0

        new_id = f"{prefix}{latest_number + 1:03d}"
        now_text = _now_iso()

        conn.execute(
            """
            INSERT INTO work_orders (id, device, component, status, title, assignee, created_time, updated_time, description)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                new_id,
                device,
                component,
                "待处理",
                title,
                assignee,
                now_text,
                now_text,
                description,
            ),
        )

        row = conn.execute("SELECT * FROM work_orders WHERE id = ?", (new_id,)).fetchone()
        return _row_to_work_order(row)


def get_latest_metrics() -> DeviceMetrics:
    with _get_conn() as conn:
        row = conn.execute(
            "SELECT * FROM metric_snapshots ORDER BY collected_at DESC, id DESC LIMIT 1"
        ).fetchone()
        return DeviceMetrics(
            temperature=row["temperature"],
            voltage=row["voltage"],
            current=row["current"],
            power=row["power"],
            energy=row["energy"],
            delay=row["delay"],
            isConnected=bool(row["is_connected"]),
        )


def get_latest_metrics_for_device(device_id: str) -> tuple[DeviceMetrics, bool, str]:
    with _get_conn() as conn:
        row = conn.execute(
            """
            SELECT temperature, voltage, current, power, energy, delay, is_connected
            FROM sensor_readings
            WHERE device_id = ?
            ORDER BY reading_time DESC, id DESC
            LIMIT 1
            """,
            (device_id,),
        ).fetchone()

        if row:
            return (
                DeviceMetrics(
                    temperature=row["temperature"],
                    voltage=row["voltage"],
                    current=row["current"],
                    power=row["power"],
                    energy=row["energy"],
                    delay=row["delay"],
                    isConnected=bool(row["is_connected"]),
                ),
                False,
                "sensor",
            )

        device_row = conn.execute(
            "SELECT temperature, power, is_online FROM devices WHERE id = ?",
            (device_id,),
        ).fetchone()
        if device_row:
            metrics = DeviceMetrics(
                temperature=float(device_row["temperature"]),
                voltage=220.0,
                current=15.0,
                power=float(device_row["power"]),
                energy=125.0,
                delay=15,
                isConnected=bool(device_row["is_online"]),
            )
            return metrics, True, "fallback-device"

    return get_latest_metrics(), True, "fallback-global"


def list_metric_history(metric: str, points: int) -> list[dict[str, float]]:
    metric_map = {
        "temperature": "temperature",
        "voltage": "voltage",
        "current": "current",
        "power": "power",
        "energy": "energy",
    }
    column = metric_map.get(metric)
    if column is None:
        raise ValueError("unsupported metric")

    safe_points = max(1, min(points, 300))

    with _get_conn() as conn:
        rows = conn.execute(
            f"SELECT {column} AS value FROM metric_snapshots ORDER BY collected_at DESC, id DESC LIMIT ?",
            (safe_points,),
        ).fetchall()

    values = [float(row["value"]) for row in reversed(rows)]
    if not values:
        latest = get_latest_metrics()
        values = [float(getattr(latest, column))]

    if len(values) < safe_points:
        base = values[-1]
        amplitude = 0.5 if metric == "power" else (2.0 if metric == "current" else (3.0 if metric == "temperature" else 6.0))
        generated: list[float] = []
        for i in range(safe_points):
            wave = math.sin(i * 0.25) * amplitude * 0.5
            generated.append(float(f"{base + wave:.1f}"))
        values = generated

    return [{"x": float(i), "y": float(f"{value:.1f}")} for i, value in enumerate(values[-safe_points:])]


def list_metric_history_for_device(
    device_id: str,
    metric: str,
    points: int,
) -> tuple[list[dict[str, float]], bool, str]:
    metric_map = {
        "temperature": "temperature",
        "voltage": "voltage",
        "current": "current",
        "power": "power",
        "energy": "energy",
    }
    column = metric_map.get(metric)
    if column is None:
        raise ValueError("unsupported metric")

    safe_points = max(1, min(points, 300))
    with _get_conn() as conn:
        rows = conn.execute(
            f"SELECT {column} AS value FROM sensor_readings WHERE device_id = ? ORDER BY reading_time DESC, id DESC LIMIT ?",
            (device_id, safe_points),
        ).fetchall()

    values = [float(row["value"]) for row in reversed(rows)]
    is_simulated = False
    data_source = "sensor"

    if not values:
        metrics, _, _ = get_latest_metrics_for_device(device_id)
        base = float(getattr(metrics, column))
        amplitude = 0.5 if metric == "power" else (2.0 if metric == "current" else (3.0 if metric == "temperature" else 6.0))
        generated: list[float] = []
        for i in range(safe_points):
            wave = math.sin(i * 0.25) * amplitude * 0.5
            generated.append(float(f"{base + wave:.1f}"))
        values = generated
        is_simulated = True
        data_source = "fallback-simulated"

    points_data = [{"x": float(i), "y": float(f"{value:.1f}")} for i, value in enumerate(values[-safe_points:])]
    return points_data, is_simulated, data_source


def list_realtime_events() -> list[RealtimeEvent]:
    with _get_conn() as conn:
        rows = conn.execute("SELECT * FROM realtime_events ORDER BY id DESC").fetchall()
        return [
            RealtimeEvent(type=row["event_type"], icon=row["icon"], text=row["text"], time=row["event_time"])
            for row in rows
        ]


def list_realtime_events_for_device(device_id: str, limit: int = 20) -> tuple[list[RealtimeEvent], bool, str]:
    safe_limit = max(1, min(limit, 100))
    with _get_conn() as conn:
        rows = conn.execute(
            """
            SELECT event_type, icon, text, event_time
            FROM realtime_events
            WHERE device_id = ? OR text LIKE ?
            ORDER BY id DESC
            LIMIT ?
            """,
            (device_id, f"%设备{device_id}%", safe_limit),
        ).fetchall()

    if rows:
        return (
            [RealtimeEvent(type=row["event_type"], icon=row["icon"], text=row["text"], time=row["event_time"]) for row in rows],
            False,
            "sensor",
        )

    events = list_realtime_events()[:safe_limit]
    return events, True, "fallback-global"


def list_components() -> list[Component]:
    with _get_conn() as conn:
        rows = conn.execute("SELECT * FROM components ORDER BY id").fetchall()
        result: list[Component] = []
        for row in rows:
            component_id = row["id"]
            metric_rows = conn.execute(
                "SELECT metric_name, metric_value, metric_unit FROM component_metrics WHERE component_id = ? ORDER BY seq, id",
                (component_id,),
            ).fetchall()
            suggestion_rows = conn.execute(
                "SELECT suggestion FROM component_suggestions WHERE component_id = ? ORDER BY seq, id",
                (component_id,),
            ).fetchall()

            result.append(
                Component(
                    id=component_id,
                    name=row["name"],
                    healthIndex=row["health_index"],
                    rul=row["rul"],
                    rulRange=row["rul_range"],
                    suggestions=[s["suggestion"] for s in suggestion_rows],
                    metrics=[
                        ComponentMetric(name=m["metric_name"], value=m["metric_value"], unit=m["metric_unit"])
                        for m in metric_rows
                    ],
                )
            )
        return result


def get_component(component_id: str) -> Optional[Component]:
    with _get_conn() as conn:
        row = conn.execute("SELECT * FROM components WHERE id = ?", (component_id,)).fetchone()
        if not row:
            return None

        metric_rows = conn.execute(
            "SELECT metric_name, metric_value, metric_unit FROM component_metrics WHERE component_id = ? ORDER BY seq, id",
            (component_id,),
        ).fetchall()
        suggestion_rows = conn.execute(
            "SELECT suggestion FROM component_suggestions WHERE component_id = ? ORDER BY seq, id",
            (component_id,),
        ).fetchall()

        return Component(
            id=row["id"],
            name=row["name"],
            healthIndex=row["health_index"],
            rul=row["rul"],
            rulRange=row["rul_range"],
            suggestions=[s["suggestion"] for s in suggestion_rows],
            metrics=[
                ComponentMetric(name=m["metric_name"], value=m["metric_value"], unit=m["metric_unit"])
                for m in metric_rows
            ],
        )


def get_latest_health(device_id: Optional[str] = None) -> HealthData:
    with _get_conn() as conn:
        if device_id:
            snapshot = conn.execute(
                "SELECT * FROM health_snapshots WHERE device_id = ? ORDER BY collected_at DESC, id DESC LIMIT 1",
                (device_id,),
            ).fetchone()
            if snapshot is None:
                snapshot = conn.execute(
                    "SELECT * FROM health_snapshots ORDER BY collected_at DESC, id DESC LIMIT 1"
                ).fetchone()
        else:
            snapshot = conn.execute(
                "SELECT * FROM health_snapshots ORDER BY collected_at DESC, id DESC LIMIT 1"
            ).fetchone()
        snapshot_id = snapshot["id"]

        component_rows = conn.execute(
            "SELECT component_name, hi, rul, status FROM health_components WHERE snapshot_id = ? ORDER BY seq, id",
            (snapshot_id,),
        ).fetchall()
        prediction_rows = conn.execute(
            "SELECT prediction_date, hi FROM health_predictions WHERE snapshot_id = ? ORDER BY seq, id",
            (snapshot_id,),
        ).fetchall()
        suggestion_rows = conn.execute(
            "SELECT suggestion FROM health_suggestions WHERE snapshot_id = ? ORDER BY seq, id",
            (snapshot_id,),
        ).fetchall()

        return HealthData(
            overallHI=snapshot["overall_hi"],
            overallRUL=snapshot["overall_rul"],
            rulRange=snapshot["rul_range"],
            trend=snapshot["trend"],
            components=[
                ComponentHealth(name=c["component_name"], hi=c["hi"], rul=c["rul"], status=c["status"])
                for c in component_rows
            ],
            predictions=[HealthPrediction(date=p["prediction_date"], hi=p["hi"]) for p in prediction_rows],
            suggestions=[s["suggestion"] for s in suggestion_rows],
        )


def get_latest_health_for_device(device_id: str) -> tuple[HealthData, bool, str]:
    with _get_conn() as conn:
        snapshot = conn.execute(
            "SELECT * FROM health_snapshots WHERE device_id = ? ORDER BY collected_at DESC, id DESC LIMIT 1",
            (device_id,),
        ).fetchone()

    if snapshot:
        return get_latest_health(device_id=device_id), False, "sensor"

    return get_latest_health(), True, "fallback-global"


def _build_sensor_training_sample(payload: dict[str, Any]) -> tuple[str, str]:
    input_text = (
        f"传感器上报：设备 {payload['deviceId']}，温度 {payload['temperature']}°C，"
        f"电压 {payload['voltage']}V，电流 {payload['current']}A，功率 {payload['power']}kW，"
        f"电能 {payload['energy']}kWh，延迟 {payload['delay']}ms，"
        f"状态 {'在线' if payload['isConnected'] else '离线'}。请给出处置建议。"
    )

    temperature = float(payload["temperature"])
    if not payload["isConnected"]:
        output = "设备离线，建议优先检查网络链路与供电状态，并进行现场连通性验证。"
    elif temperature >= 75:
        output = "温度明显超阈值，建议立即降载并检查散热系统，必要时停机检修。"
    elif temperature >= 60:
        output = "温度偏高，建议提升巡检频次，排查风道堵塞与负载异常。"
    else:
        output = "当前运行总体稳定，建议按计划巡检并持续观察温度趋势。"
    return input_text, output


def _calc_health_from_sensor(payload: dict[str, Any]) -> tuple[float, int, str]:
    temperature = float(payload["temperature"])
    power = max(0.0, float(payload["power"]))
    delay = max(0.0, float(payload["delay"]))
    is_connected = bool(payload["isConnected"])

    temp_factor = max(0.0, min(1.0, (temperature - 40.0) / 40.0))
    power_factor = max(0.0, min(1.0, power / 8.0))
    delay_factor = max(0.0, min(1.0, delay / 400.0))
    connect_penalty = 0.35 if not is_connected else 0.0

    risk = temp_factor * 0.45 + power_factor * 0.25 + delay_factor * 0.2 + connect_penalty
    hi = max(0.2, min(0.99, 1.0 - risk))
    rul = int(max(30, min(720, hi * 720)))

    trend = "declining" if hi < 0.75 else ("stable" if hi < 0.9 else "improving")
    return hi, rul, trend


def _append_health_snapshot(
    conn: sqlite3.Connection,
    *,
    device_id: str,
    hi: float,
    rul: int,
    trend: str,
) -> None:
    min_rul = max(1, rul - 30)
    max_rul = rul + 30
    cursor = conn.execute(
        """
        INSERT INTO health_snapshots (device_id, overall_hi, overall_rul, rul_range, trend, collected_at)
        VALUES (?, ?, ?, ?, ?, ?)
        """,
        (device_id, hi, rul, f"{min_rul}-{max_rul}", trend, _now_iso()),
    )
    snapshot_id = cursor.lastrowid

    component_rows = conn.execute(
        "SELECT name FROM components ORDER BY id"
    ).fetchall()
    if not component_rows:
        component_rows = [{"name": "整机"}]

    for idx, row in enumerate(component_rows):
        comp_hi = max(0.2, min(0.99, hi - idx * 0.03))
        comp_rul = max(20, rul - idx * 25)
        comp_status = "good" if comp_hi >= 0.8 else ("warning" if comp_hi >= 0.6 else "danger")
        conn.execute(
            """
            INSERT INTO health_components (snapshot_id, component_name, hi, rul, status, seq)
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            (snapshot_id, row["name"], comp_hi, comp_rul, comp_status, idx),
        )

    for idx in range(5):
        month = datetime.now(timezone.utc).month + idx * 3
        year = datetime.now(timezone.utc).year + (month - 1) // 12
        month = ((month - 1) % 12) + 1
        predicted_hi = max(0.2, min(0.99, hi - idx * 0.06))
        conn.execute(
            "INSERT INTO health_predictions (snapshot_id, prediction_date, hi, seq) VALUES (?, ?, ?, ?)",
            (snapshot_id, f"{year}-{month:02d}", predicted_hi, idx),
        )

    base_suggestion = "建议加强散热与负载巡检" if hi < 0.75 else "设备健康状态稳定，维持计划巡检"
    conn.execute(
        "INSERT INTO health_suggestions (snapshot_id, suggestion, seq) VALUES (?, ?, ?)",
        (snapshot_id, base_suggestion, 0),
    )
    conn.execute(
        "INSERT INTO health_suggestions (snapshot_id, suggestion, seq) VALUES (?, ?, ?)",
        (snapshot_id, f"重点关注设备 {device_id} 的温度与延迟趋势", 1),
    )


def ingest_sensor_reading(payload: dict[str, Any], *, add_training_sample: bool = True) -> DeviceMetrics:
    reading_time = _normalize_timestamp(payload.get("timestamp"))
    event_text = (
        f"设备{payload['deviceId']}传感器上报：温度 {payload['temperature']}°C，"
        f"功率 {payload['power']}kW"
    )
    input_text, expected_output = _build_sensor_training_sample(payload)
    new_hi, new_rul, trend = _calc_health_from_sensor(payload)

    with _get_conn() as conn:
        conn.execute(
            """
            INSERT INTO sensor_readings (
                device_id, reading_time, temperature, voltage, current, power,
                energy, delay, is_connected, raw_payload
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                payload["deviceId"],
                reading_time,
                payload["temperature"],
                payload["voltage"],
                payload["current"],
                payload["power"],
                payload["energy"],
                payload["delay"],
                int(bool(payload["isConnected"])),
                json.dumps(payload, ensure_ascii=False),
            ),
        )

        conn.execute(
            """
            INSERT INTO metric_snapshots (temperature, voltage, current, power, energy, delay, is_connected)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            (
                payload["temperature"],
                payload["voltage"],
                payload["current"],
                payload["power"],
                payload["energy"],
                payload["delay"],
                int(bool(payload["isConnected"])),
            ),
        )

        conn.execute(
            "INSERT INTO realtime_events (event_type, icon, text, event_time, device_id) VALUES (?, ?, ?, ?, ?)",
            (
                "alarm" if float(payload["temperature"]) >= 75 else "status",
                "warning" if float(payload["temperature"]) >= 75 else "info",
                event_text,
                reading_time,
                payload["deviceId"],
            ),
        )

        if add_training_sample:
            conn.execute(
                """
                INSERT INTO training_samples (source, input_text, expected_output)
                VALUES (?, ?, ?)
                """,
                ("sensor", input_text, expected_output),
            )

        conn.execute(
            """
            UPDATE devices
            SET is_online = ?,
                last_update = ?,
                temperature = ?,
                power = ?,
                health_index = ?,
                rul = ?,
                updated_at = datetime('now')
            WHERE id = ?
            """,
            (
                int(bool(payload["isConnected"])),
                reading_time,
                payload["temperature"],
                payload["power"],
                new_hi,
                new_rul,
                payload["deviceId"],
            ),
        )

        _append_health_snapshot(
            conn,
            device_id=payload["deviceId"],
            hi=new_hi,
            rul=new_rul,
            trend=trend,
        )

    return get_latest_metrics()


def list_sensor_replay_series(max_points_per_device: int = 1500) -> dict[str, list[dict[str, Any]]]:
    safe_limit = max(50, min(max_points_per_device, 10000))
    with _get_conn() as conn:
        device_rows = conn.execute("SELECT id FROM devices ORDER BY id").fetchall()
        result: dict[str, list[dict[str, Any]]] = {}

        for row in device_rows:
            device_id = str(row["id"])
            samples = conn.execute(
                """
                SELECT temperature, voltage, current, power, energy, delay, is_connected
                FROM sensor_readings
                WHERE device_id = ?
                ORDER BY reading_time ASC, id ASC
                LIMIT ?
                """,
                (device_id, safe_limit),
            ).fetchall()
            if not samples:
                continue

            result[device_id] = [
                {
                    "temperature": float(sample["temperature"]),
                    "voltage": float(sample["voltage"]),
                    "current": float(sample["current"]),
                    "power": float(sample["power"]),
                    "energy": float(sample["energy"]),
                    "delay": int(sample["delay"]),
                    "isConnected": bool(sample["is_connected"]),
                }
                for sample in samples
            ]
        return result


def _row_to_training_sample(row: sqlite3.Row) -> TrainingSample:
    return TrainingSample(
        id=row["id"],
        source=row["source"],
        input=row["input_text"],
        expectedOutput=row["expected_output"],
        createdAt=row["created_at"],
    )


def add_training_sample(source: str, input_text: str, expected_output: str) -> TrainingSample:
    with _get_conn() as conn:
        cursor = conn.execute(
            """
            INSERT INTO training_samples (source, input_text, expected_output)
            VALUES (?, ?, ?)
            """,
            (source, input_text, expected_output),
        )
        sample_id = cursor.lastrowid
        row = conn.execute(
            "SELECT id, source, input_text, expected_output, created_at FROM training_samples WHERE id = ?",
            (sample_id,),
        ).fetchone()

    return _row_to_training_sample(row)


def collect_training_samples_from_devices() -> int:
    devices = list_devices()
    for device in devices:
        input_text = (
            f"设备 {device.name}，温度 {device.temperature}°C，功率 {device.power}kW，"
            f"健康指数 {device.healthIndex}，RUL {device.rul} 天，"
            f"状态 {'在线' if device.isOnline else '离线'}。请分析。"
        )
        if not device.isOnline:
            output = "设备离线，建议检查供电与通信链路，并确认是否处于停机维护状态。"
        elif device.healthIndex < 0.6:
            output = "健康指数较低，建议立即安排专项检修并评估停机窗口。"
        elif device.healthIndex < 0.8:
            output = "健康指数中等，建议增加巡检频次并提前准备备件。"
        else:
            output = "设备运行状态较好，按计划维护并持续监测关键指标。"
        add_training_sample("device", input_text, output)
    return len(devices)


def collect_training_samples_from_alarms() -> int:
    alarms = list_alarms()
    for alarm in alarms:
        input_text = (
            f"告警：{alarm.title}；级别：{alarm.level}；设备：{alarm.device}；"
            f"部件：{alarm.component}；当前值：{alarm.currentValue}；阈值：{alarm.threshold}。"
            "请给出处置方案。"
        )
        output = (
            "1) 立即复核传感器与采样链路；2) 对比历史趋势确认异常是否持续；"
            "3) 按告警等级执行现场检查与降载/停机策略；4) 闭环记录工单与复盘。"
        )
        add_training_sample("alarm", input_text, output)
    return len(alarms)


def list_training_samples(limit: int = 200) -> list[TrainingSample]:
    safe_limit = max(1, min(limit, 2000))
    with _get_conn() as conn:
        rows = conn.execute(
            """
            SELECT id, source, input_text, expected_output, created_at
            FROM training_samples
            ORDER BY id DESC
            LIMIT ?
            """,
            (safe_limit,),
        ).fetchall()
    return [_row_to_training_sample(row) for row in rows]


def delete_training_sample(sample_id: int) -> bool:
    with _get_conn() as conn:
        cursor = conn.execute("DELETE FROM training_samples WHERE id = ?", (sample_id,))
        return cursor.rowcount > 0


def list_training_messages() -> list[dict[str, Any]]:
    with _get_conn() as conn:
        rows = conn.execute(
            "SELECT source, input_text, expected_output FROM training_samples ORDER BY id"
        ).fetchall()

    if not rows:
        collect_training_samples_from_devices()
        collect_training_samples_from_alarms()
        with _get_conn() as conn:
            rows = conn.execute(
                "SELECT source, input_text, expected_output FROM training_samples ORDER BY id"
            ).fetchall()

    return [
        {
            "messages": [
                {"role": "system", "content": "你是设备监测领域专家，回答要专业、可执行、简明。"},
                {"role": "user", "content": row["input_text"]},
                {"role": "assistant", "content": row["expected_output"]},
            ],
            "source": row["source"],
        }
        for row in rows
    ]


def create_training_job(total_samples: int, message: Optional[str] = None) -> TrainingJob:
    job_id = f"job_{uuid4().hex[:12]}"
    with _get_conn() as conn:
        conn.execute(
            """
            INSERT INTO training_jobs (id, status, total_samples, processed_samples, message)
            VALUES (?, ?, ?, ?, ?)
            """,
            (job_id, "running", total_samples, 0, message),
        )
    return get_training_job(job_id)


def update_training_job(
    job_id: str,
    *,
    status: Optional[str] = None,
    processed_samples: Optional[int] = None,
    model_name: Optional[str] = None,
    message: Optional[str] = None,
) -> Optional[TrainingJob]:
    set_parts: list[str] = ["updated_at = datetime('now')"]
    values: list[Any] = []
    if status is not None:
        set_parts.append("status = ?")
        values.append(status)
    if processed_samples is not None:
        set_parts.append("processed_samples = ?")
        values.append(processed_samples)
    if model_name is not None:
        set_parts.append("model_name = ?")
        values.append(model_name)
    if message is not None:
        set_parts.append("message = ?")
        values.append(message)

    values.append(job_id)
    with _get_conn() as conn:
        cursor = conn.execute(
            f"UPDATE training_jobs SET {', '.join(set_parts)} WHERE id = ?",
            values,
        )
        if cursor.rowcount == 0:
            return None
    return get_training_job(job_id)


def get_training_job(job_id: str) -> Optional[TrainingJob]:
    with _get_conn() as conn:
        row = conn.execute(
            """
            SELECT id, status, total_samples, processed_samples, model_name, message, created_at
            FROM training_jobs
            WHERE id = ?
            """,
            (job_id,),
        ).fetchone()
    if not row:
        return None
    return TrainingJob(
        id=row["id"],
        status=row["status"],
        totalSamples=row["total_samples"],
        processedSamples=row["processed_samples"],
        modelName=row["model_name"],
        message=row["message"],
        createdAt=row["created_at"],
    )


def list_training_jobs(limit: int = 20) -> list[TrainingJob]:
    safe_limit = max(1, min(limit, 200))
    with _get_conn() as conn:
        rows = conn.execute(
            """
            SELECT id, status, total_samples, processed_samples, model_name, message, created_at
            FROM training_jobs
            ORDER BY created_at DESC
            LIMIT ?
            """,
            (safe_limit,),
        ).fetchall()
    return [
        TrainingJob(
            id=row["id"],
            status=row["status"],
            totalSamples=row["total_samples"],
            processedSamples=row["processed_samples"],
            modelName=row["model_name"],
            message=row["message"],
            createdAt=row["created_at"],
        )
        for row in rows
    ]


def export_training_jsonl(output_path: Path) -> int:
    messages = list_training_messages()
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("w", encoding="utf-8") as f:
        for item in messages:
            f.write(json.dumps(item, ensure_ascii=False) + "\n")
    return len(messages)


def get_user(username: str) -> Optional[dict[str, Any]]:
    with _get_conn() as conn:
        row = conn.execute(
            "SELECT username, password_hash, role, is_active FROM users WHERE username = ?",
            (username,),
        ).fetchone()
        if not row:
            return None
        return {
            "username": row["username"],
            "hashed_password": row["password_hash"],
            "role": row["role"],
            "is_active": bool(row["is_active"]),
        }


init_db()
