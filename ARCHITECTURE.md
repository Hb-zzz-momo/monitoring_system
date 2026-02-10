# 应用架构图

## 页面导航流程

```
启动页 (Splash)
    ↓
登录页 (Login)
    ↓
设备列表 (Device List) ←------ 我的/设置 (Profile)
    ↓                              ↑
    ├─→ 设备详情壳 ──────────────────┤
    │   (Device Detail Shell)      │
    │   ├─ 3D视图                   │
    │   ├─ 监测总览                 │
    │   └─ 曲线                     │
    │                               │
    └─→ 主应用壳 (Main Shell) ──────┘
        ├─ 3D设备 (3D Device Tab)
        │  └─→ 部件抽屉 (Component Drawer)
        │
        ├─ 实时监测 (Realtime Tab)
        │
        ├─ 告警/工单 (Alarm/Work Tab)
        │  ├─ 告警中心
        │  │  └─→ 告警详情 (Alarm Detail)
        │  └─ 工单列表
        │     └─→ 工单详情 (Work Order Detail)
        │
        └─ 我的/设置 (Profile Tab)
           └─→ 设备列表
```

## 组件层次结构

```
MonitoringSystemApp (main.dart)
│
├─ Theme (app_theme.dart)
│  ├─ Colors (AppColors)
│  ├─ Typography
│  ├─ Card Theme
│  ├─ Button Theme
│  └─ Input Theme
│
├─ Routes (app_routes.dart)
│  ├─ /                    → SplashScreen
│  ├─ /login               → LoginScreen
│  ├─ /device-list         → DeviceListScreen
│  ├─ /main                → MainShell
│  ├─ /device-detail       → DeviceDetailShell
│  ├─ /alarm-detail        → AlarmDetailScreen
│  └─ /work-order-detail   → WorkOrderDetailScreen
│
├─ Common Widgets (common_widgets.dart)
│  ├─ StateWidget (loading/empty/error)
│  ├─ SkeletonLoader
│  ├─ StatusChip
│  ├─ StatusDot
│  └─ KpiCard
│
├─ Mock Data (mock_data.dart)
│  ├─ devices[]
│  ├─ alarms[]
│  ├─ workOrders[]
│  ├─ deviceMetrics{}
│  ├─ realtimeEvents[]
│  ├─ components[]
│  ├─ checklistItems[]
│  └─ timeline[]
│
└─ Screens
   ├─ SplashScreen
   │  └─ 加载动画 + Logo
   │
   ├─ LoginScreen
   │  └─ 登录表单 + 演示账号
   │
   ├─ DeviceListScreen
   │  ├─ AppBar (搜索 + 筛选)
   │  ├─ Filter Chips (全部/在线/离线/告警中)
   │  ├─ Device Card List
   │  └─ FAB (扫码绑定)
   │
   ├─ MainShell
   │  ├─ BottomNavigationBar (4 tabs)
   │  └─ IndexedStack
   │     ├─ ThreeDDeviceTab
   │     │  ├─ 3D Viewer Area (占位)
   │     │  ├─ Toolbar (重置/爆炸图/全屏)
   │     │  ├─ KPI Cards (2x2 Grid)
   │     │  ├─ Recent Alarms Card
   │     │  └─ Component Drawer (右侧)
   │     │     ├─ Health Index Bar
   │     │     ├─ RUL Display
   │     │     ├─ Suggestions List
   │     │     ├─ Metrics List
   │     │     └─ Action Buttons
   │     │
   │     ├─ RealtimeTab
   │     │  ├─ Connection Status Bar
   │     │  ├─ Time Range Chips
   │     │  ├─ Large KPI Card (温度 + Sparkline)
   │     │  ├─ KPI Grid (2x2)
   │     │  └─ Recent Events Card
   │     │
   │     ├─ AlarmWorkTab
   │     │  ├─ TabBar (告警/工单)
   │     │  ├─ AlarmCenterView
   │     │  │  ├─ Filter Chips (级别/状态)
   │     │  │  └─ Alarm Card List
   │     │  └─ WorkOrdersView
   │     │     ├─ Filter Chips (状态/时间)
   │     │     └─ WorkOrder Card List
   │     │
   │     └─ ProfileTab
   │        ├─ Profile Card (头像 + 名称)
   │        ├─ Device Management Section
   │        ├─ Notification Settings
   │        ├─ Threshold Display
   │        └─ About Section
   │
   ├─ DeviceDetailShell
   │  ├─ AppBar (设备名 + 状态)
   │  ├─ TabBar (3D视图/监测总览/曲线)
   │  └─ TabBarView
   │     ├─ DeviceThreeDView
   │     │  ├─ 3D Container (占位)
   │     │  └─ KPI Cards
   │     ├─ DeviceRealtimeView
   │     │  └─ KPI Grid (2x2)
   │     └─ DeviceChartsView
   │        ├─ Metric Selection Chips
   │        ├─ Component Dropdown
   │        ├─ Control Buttons
   │        ├─ Main Chart (占位)
   │        └─ Data Points Table (可折叠)
   │
   ├─ AlarmDetailScreen
   │  ├─ Summary Card
   │  ├─ Evidence List (带进度条)
   │  ├─ Small Chart (占位)
   │  ├─ Suggestions List
   │  ├─ Parts Cards (横向滚动)
   │  └─ Bottom Buttons
   │
   └─ WorkOrderDetailScreen
      ├─ Summary Card
      ├─ Checklist (可勾选)
      ├─ Attachments Grid (图片 + 上传)
      ├─ Timeline
      └─ Bottom Buttons
```

## 数据流

```
UI Layer (Screens)
    ↓ 读取
Mock Data Layer
    ↓ (未来)
API Service Layer
    ↓ HTTP/WebSocket
Backend Server
    ↓
Database / IoT Devices
```

## 状态管理

当前使用 StatefulWidget 本地状态管理：
- 筛选选择状态
- UI展开/折叠状态
- 表单输入状态
- 加载/错误状态

建议未来迁移到：
- Provider / Riverpod (推荐)
- Bloc / Cubit
- GetX

## 主题系统

```
AppTheme
├─ ColorScheme
│  ├─ primary: RGB(39, 99, 255)
│  ├─ surface: RGB(245, 247, 250)
│  ├─ error: RGB(240, 68, 56)
│  └─ ...
│
├─ TextTheme
│  ├─ displayLarge: 24sp
│  ├─ titleLarge: 18sp
│  ├─ bodyLarge: 14sp
│  └─ bodySmall: 12sp
│
├─ CardTheme
│  ├─ elevation: 2
│  └─ borderRadius: 12dp
│
├─ ButtonTheme
│  ├─ ElevatedButton: 48dp, primary color
│  └─ OutlinedButton: 48dp, divider border
│
└─ InputDecorationTheme
   └─ borderRadius: 12dp
```

## 响应式设计

目标屏幕尺寸: 360×800 dp

间距体系:
- 基准: 8dp
- 常用: 8, 12, 16, 24, 32

适配策略:
- 使用 dp (设备无关像素)
- Flexible/Expanded 布局
- MediaQuery 获取屏幕信息
- 断点设计 (手机/平板)
