PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

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
    device_id TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS health_snapshots (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    device_id TEXT,
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

CREATE INDEX IF NOT EXISTS idx_alarms_status ON alarms(status);
CREATE INDEX IF NOT EXISTS idx_work_orders_status ON work_orders(status);
CREATE INDEX IF NOT EXISTS idx_metric_snapshots_collected_at ON metric_snapshots(collected_at);
CREATE INDEX IF NOT EXISTS idx_realtime_events_created_at ON realtime_events(created_at);
CREATE INDEX IF NOT EXISTS idx_realtime_events_device_time ON realtime_events(device_id, event_time DESC);
CREATE INDEX IF NOT EXISTS idx_sensor_readings_device_time ON sensor_readings(device_id, reading_time DESC);
CREATE INDEX IF NOT EXISTS idx_health_snapshots_device_time ON health_snapshots(device_id, collected_at DESC);
CREATE INDEX IF NOT EXISTS idx_training_samples_source ON training_samples(source);
CREATE INDEX IF NOT EXISTS idx_training_jobs_created_at ON training_jobs(created_at DESC);

COMMIT;
