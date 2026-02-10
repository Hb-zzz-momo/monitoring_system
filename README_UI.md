# 设备监测系统 - 前端UI

这是一个基于 Flutter 开发的设备监测系统移动应用前端界面。

## 功能特性

### 页面导航
- **启动页（Splash）**: 应用启动过渡页面
- **登录页（Login）**: 用户登录界面，支持演示账号
- **设备列表（Device List）**: 显示所有设备，支持筛选（全部/在线/离线）
- **主应用壳（Main Shell）**: 包含4个底部标签页的主界面
  - 3D设备视图
  - 实时监测
  - 告警/工单
  - 我的/设置

### 主要功能模块

#### 1. 3D设备标签页
- 3D模型展示区（占位符）
- 实时KPI指标卡片（温度、电压、电流、功率）
- 最近告警列表
- 右侧抽屉显示部件详情
  - 健康度（HI）
  - 剩余寿命（RUL）
  - 建议动作
  - 相关测点

#### 2. 实时监测标签页
- 连接状态显示
- 时间范围选择（5s/30s/1m/5m）
- 大型KPI卡片（温度，带迷你趋势图占位）
- 网格KPI卡片（电压、电流、功率、电能）
- 最新事件列表

#### 3. 告警/工单标签页
- **告警中心**
  - 按级别筛选（全部/提示/预警/告警）
  - 按状态筛选（进行中/已处理）
  - 告警卡片列表
  - 确认和创建工单操作
- **工单列表**
  - 按状态筛选（全部/待处理/处理中/已完成）
  - 按时间筛选（近24h/7d/30d）
  - 工单卡片列表

#### 4. 我的/设置标签页
- 用户信息展示
- 设备管理入口
- 通知设置开关
- 阈值展示（温度、电压、电流）
- 关于信息（版本、隐私、日志导出）

### 详情页面

#### 设备详情页
包含3个子标签：
- **3D视图**: 3D模型展示 + KPI卡片
- **监测总览**: 实时数据展示
- **曲线**: 折线图展示（占位符）+ 数据点表

#### 告警详情页
- 告警摘要卡片
- 证据条列表（带置信度进度条）
- 告警前后曲线图（占位符）
- 建议动作列表
- 建议更换件卡片
- 生成工单/标记已处理按钮

#### 工单详情页
- 工单摘要信息
- 处理清单（可勾选）
- 附件网格（图片占位 + 上传按钮）
- 处理记录时间线
- 添加备注/下一步按钮

## 设计规范

### 颜色
- 主色（Primary）: RGB(39, 99, 255)
- 背景（Background）: RGB(245, 247, 250)
- 卡片（Card）: RGB(255, 255, 255)
- 正文（Text）: RGB(18, 24, 38)
- 次级文字（SubText）: RGB(102, 112, 133)
- 分割线（Divider）: RGB(228, 231, 236)
- 成功（Success）: RGB(18, 183, 106)
- 警告（Warning）: RGB(245, 158, 11)
- 危险（Danger）: RGB(240, 68, 56)
- 信息（Info）: RGB(46, 144, 250)

### 字体
- H0: 24sp（页面主标题）
- H1: 18sp（分区标题）
- Body: 14sp（正文）
- Caption: 12sp（辅助信息）
- 数值: 28sp（KPI数字）

### 组件
- 卡片圆角: 12dp
- 按钮高度: 48dp
- 标签胶囊高度: 28dp
- 列表项高度: 72-88dp

## 项目结构

```
lib/
├── main.dart                          # 应用入口
├── theme/
│   └── app_theme.dart                 # 全局主题配置
├── routes/
│   └── app_routes.dart                # 路由配置
├── screens/
│   ├── splash_screen.dart             # 启动页
│   ├── login_screen.dart              # 登录页
│   ├── device_list_screen.dart        # 设备列表页
│   ├── main_shell.dart                # 主应用壳（底部导航）
│   ├── device_detail_shell.dart       # 设备详情壳（标签栏）
│   ├── alarm_detail_screen.dart       # 告警详情页
│   ├── work_order_detail_screen.dart  # 工单详情页
│   └── tabs/
│       ├── 3d_device_tab.dart         # 3D设备标签页
│       ├── realtime_tab.dart          # 实时监测标签页
│       ├── alarm_work_tab.dart        # 告警/工单标签页
│       └── profile_tab.dart           # 我的/设置标签页
├── components/
│   └── common_widgets.dart            # 通用组件（KpiCard、StatusChip等）
└── mock_data/
    └── mock_data.dart                 # 模拟数据
```

## 如何运行

### 前置要求
- Flutter SDK 3.10.8 或更高版本
- Dart SDK
- Android Studio / VS Code（带Flutter插件）

### 安装步骤

1. 克隆仓库
```bash
git clone <repository-url>
cd monitoring_system
```

2. 安装依赖
```bash
flutter pub get
```

3. 运行应用
```bash
# 在连接的设备或模拟器上运行
flutter run

# 或者在特定平台上运行
flutter run -d chrome        # Web
flutter run -d android       # Android
flutter run -d ios           # iOS
flutter run -d macos         # macOS
flutter run -d windows       # Windows
flutter run -d linux         # Linux
```

### 登录信息
- 演示账号: demo
- 演示密码: demo123

## 功能状态

### 已实现
✅ 所有页面布局和UI组件
✅ 页面间导航和路由
✅ 三种状态UI（加载/空/错误）
✅ 模拟数据展示
✅ 响应式设计
✅ Material 3 设计规范

### 占位符
⏳ 3D模型渲染（使用占位容器）
⏳ 折线图渲染（使用占位容器）
⏳ 后端API集成
⏳ 实时数据更新
⏳ 图片上传功能
⏳ 筛选弹窗详细实现

## 下一步开发建议

1. **集成3D渲染库**
   - 使用 `flutter_cube` 或 `model_viewer` 包
   - 实现3D模型加载和交互

2. **集成图表库**
   - 使用 `fl_chart` 或 `syncfusion_flutter_charts`
   - 实现实时曲线图和历史数据图表

3. **后端集成**
   - 实现RESTful API调用
   - WebSocket实时数据推送
   - 数据持久化（SQLite/Hive）

4. **状态管理**
   - 引入Provider/Riverpod/Bloc
   - 全局状态管理

5. **完善交互**
   - 实现筛选弹窗
   - 时间范围选择器
   - 图片预览和上传
   - 下拉刷新和加载更多

6. **性能优化**
   - 列表虚拟滚动
   - 图片缓存
   - 路由预加载

## 许可证

MIT License
