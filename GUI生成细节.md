### 总体 GUI 布局设计稿

下面给的是**“可生成代码的布局规格”**：包含全局设计令牌（Design Tokens，设计变量）、导航结构、每个页面的区域划分、组件清单、状态（加载/空/错误）与交互。复制最后的“生成提示词（Prompt）”即可让工具按页生成。

------

### 全局设计令牌（Design Tokens，设计变量）

**1) 画布与栅格**

- 目标屏幕：360×800（dp，设备无关像素）
- 间距体系：8dp 基准（8/16/24/32）
- 圆角：12dp（卡片）、16dp（大卡）、999dp（胶囊按钮）
- 阴影：2 级（卡片轻阴影、弹窗中阴影）

**2) 字体层级（Typography，排版）**

- H0：24sp（页面主标题）
- H1：18sp（分区标题）
- Body：14sp（正文）
- Caption：12sp（辅助信息）
- 数值：28sp（KPI 数字，等宽字体可选）

**3) 颜色（仅 RGB）**

- 主色 Primary：RGB(39, 99, 255)
- 背景 Background：RGB(245, 247, 250)
- 卡片 Card：RGB(255, 255, 255)
- 正文 Text：RGB(18, 24, 38)
- 次级文字 SubText：RGB(102, 112, 133)
- 分割线 Divider：RGB(228, 231, 236)
- 成功 Success：RGB(18, 183, 106)
- 警告 Warning：RGB(245, 158, 11)
- 危险 Danger：RGB(240, 68, 56)
- 信息 Info：RGB(46, 144, 250)

**4) 通用组件规范**

- Card（卡片）：内边距 16dp，标题与内容间距 8dp
- Button（按钮）：高度 48dp，主按钮填充 Primary，次按钮描边 Divider
- Chip（标签胶囊）：高度 28dp，左右 padding 10dp
- List Item（列表项）：高度 72–88dp，左图标/状态点 + 中间标题/副标题 + 右侧箭头/按钮

------

### 导航结构（Navigation，页面跳转骨架）

**主结构：底部 4 个 Tab（底部页签/底部导航）**

1. **3D 设备**
2. **实时监测**
3. **告警/工单**
4. **我的**

**非 Tab 页面（从任意页可进入）**

- 启动页（Splash，启动过渡页）
- 登录/绑定（Login/Bind，登录与设备绑定）
- 设备列表（Device List，设备选择入口）
- 告警详情（Alarm Detail）
- 工单详情（Work Order Detail）
- 筛选弹窗（Filter Modal，对话框）
- 时间范围弹窗（Time Range Picker，时间选择器）

------

## 页面布局规格（逐页可生成）

> 说明：下面用到的专业词在首次出现后都加括号解释。
> Widget（组件/控件）、Scaffold（页面骨架）、AppBar（顶部栏）、BottomNavigationBar（底部导航栏）、ListView（可滚动列表容器）、Grid（网格布局）、Drawer（侧边抽屉）、Modal（对话框弹窗）、Skeleton（骨架屏）、Empty State（空状态页）。

------

### 1) 启动页（Splash）

**结构**

- 全屏背景：Background
- 中央：Logo（120dp）+ App 名称（18sp）
- 底部：加载条（Linear Progress，线性进度条）+ 文案（Caption）

**状态**

- Loading：进度条滚动
- Error：底部提示条（Toast/Snackbar，轻提示）+ “重试”按钮

------

### 2) 登录/绑定页（Login/Bind）

**布局**

- AppBar：标题“登录”
- Body：居中卡片（宽 320dp）
  - 标题：欢迎 / 项目名
  - 输入框 1：账号
  - 输入框 2：密码（带“显示/隐藏”图标）
  - 主按钮：登录
  - 次按钮：演示账号一键填充（可选）
  - 辅助区：网络状态/服务不可用提示（灰色小字）

**交互**

- 登录成功 → 设备列表
- 登录失败 → 输入框下方红色错误文案 + 轻提示条

------

### 3) 设备列表页（Device List）

**AppBar**

- 左：项目 Logo（小）
- 中：标题“设备”
- 右：搜索图标 + 筛选图标（打开 Modal）

**Body（ListView）**

- 顶部：概览条（横向滚动 Chip）
  - Chip：全部 / 在线 / 离线 / 告警中
- 列表项：Device Card（设备卡）
  - 左：状态点（在线 Success，离线 SubText）
  - 中：设备名（Body 14sp 加粗）+ 最后更新时间（Caption）
  - 下：关键 2 指标（例如温度、功率）用小型 KPI
  - 右：箭头（进入设备）

**底部**

- 悬浮按钮（FAB，浮动操作按钮）：扫码绑定（可选占位）

**状态**

- Loading：Skeleton 列表（6 行）
- Empty：插画占位 + “暂无设备” + “去绑定”
- Error：整页错误插画 + 重试按钮

------

### 4) 设备详情容器页（Device Detail Shell）

> 这个页是“进入某台设备后”的壳：顶部显示设备名，下面是**二级 Tab**（页面内切换）。

**AppBar**

- 左：返回
- 中：设备名 + 在线状态小点
- 右：更多（打开 Bottom Sheet（底部抽屉弹层））

**Body**

- 二级 Tab（TabBar，页内标签栏）：
  1. 3D 视图 2) 监测总览 3) 曲线 4) 健康寿命（可选）
- Tab 内容区：根据不同 Tab 渲染不同页面（下面分别给布局）

------

### 5) 3D 设备页（3D View Tab）

**整体为上下分区 + 右侧抽屉（Drawer）**

- 上半区（高度约 55%）：3D Viewer Shell（3D 模型容器壳）
  - 顶部叠加一行工具条（右上角）：重置视角 / 爆炸图（可选占位）/ 全屏
  - 左下角：当前选中部件名（Chip）
- 下半区（高度约 45%）：关键卡片区（可滚动）
  - Row 1（Grid 2 列）：温度卡、电压卡
  - Row 2（Grid 2 列）：电流卡、功率卡
  - Row 3（整行）：最近告警卡（最多 2 条，点进详情）

**右侧抽屉（点击部件弹出）**

- 抽屉标题：部件名 + 健康等级
- 内容：
  - HI（Health Index，健康度）大条形
  - RUL（Remaining Useful Life，剩余寿命）数值 + 区间
  - “建议动作”列表（3 条以内）
  - “相关测点”列表（温/压/流）
- 底部按钮：查看曲线 / 创建工单

**交互**

- 点击 3D 部件 → 打开 Drawer，并高亮部件
- Drawer 内点击“查看曲线”→ 切换到曲线 Tab 并预选该部件指标

------

### 6) 监测总览页（Realtime Dashboard Tab）

**顶部状态条（固定）**

- 连接状态：已连接/重连中（小圆点 + 文案）
- 延迟：xx ms
- 时间范围选择器：Chip（5s/30s/1m/5m）

**主体（SingleChildScrollView，可滚动单列）**

- KPI 大卡（高度 140dp）
  - 左：大数字（例如 42.3）+ 单位（℃）
  - 右：迷你趋势线占位（Sparkline，小趋势图占位）
  - 下：最大/最小/均值（三列）
- KPI 网格（Grid 2 列）
  - 电压卡、电流卡、功率卡、电能卡（kWh）
- “最新事件”卡（整行）
  - 最近 3 条：告警/状态变化/工单更新
  - 每条：图标 + 文案 + 时间

**状态**

- Loading：顶部状态条仍显示，下面 KPI 用 Skeleton
- Empty：显示“暂无实时数据”，按钮“检查连接”

------

### 7) 曲线页（Charts Tab）

**顶部工具栏（固定）**

- 指标选择（MultiSelect，指标多选）：温度/电压/电流/功率（Chip 组）
- 部件选择（Dropdown，下拉选择）：默认“整机”或“当前部件”
- 控制按钮：暂停/继续、重置缩放、截图（IconButton，图标按钮）

**主体**

- 主图表区（高度 320–380dp）：Line Chart（折线图）
  - 悬浮提示（Tooltip）：时间 + 值 + 单位
  - 十字准线（Crosshair，交叉指示线）可选占位
- 次图表区（可选）：例如温度与功率分开两张小图（每张 180dp）
- 底部“数据点表”（可折叠面板 Expandable，折叠面板）
  - 最新 20 条（时间、值、单位）

------

### 8) 告警/工单 Tab 容器页（Alarm & Work Tab）

**二级切换（Segmented Control，分段控制器）**

- 左：告警
- 右：工单

下面分别给两页布局。

------

### 9) 告警中心页（Alarm Center）

**顶部筛选区（固定）**

- 级别筛选 Chip：全部/提示/预警/告警/故障
- 状态筛选 Chip：进行中/已处理
- 右侧：筛选按钮（打开 Modal：设备/部件/时间）

**列表（ListView）**

- Alarm Card（告警卡）
  - 左：级别色条（Danger/Warning）
  - 中：标题（例如“部件过温”）+ 副标题（部件名、阈值信息）
  - 右：时间（Caption）+ “详情”箭头
  - 底部一行按钮：确认（Acknowledge，确认已读）/ 创建工单

------

### 10) 告警详情页（Alarm Detail）

**顶部摘要卡（Card）**

- 标题：告警类型 + 级别徽标
- 关键信息：触发时间、持续时长、当前值、阈值、设备/部件

**证据区（Evidence，依据展示）**

- “证据条”列表（3–5 条）
  - 每条：图标 + 规则命中文案 + 置信度/强度（小进度条）
- 小图：告警前后 10s 折线（高度 180dp）

**建议区（Actions）**

- 建议动作清单（Checklist）
- 建议更换件（Parts，备件）卡片（可横向滚动）

**底部固定按钮**

- 主按钮：生成工单
- 次按钮：标记已处理

------

### 11) 工单列表页（Work Orders）

**顶部筛选（固定）**

- 状态 Chip：全部/待处理/处理中/已完成
- 时间筛选：近 24h/7d/30d（Chip）
- 右：搜索（按工单号/部件）

**列表（ListView）**

- WorkOrder Card（工单卡）
  - 上：工单号 + 状态徽标
  - 中：设备/部件 + 建议动作一句话
  - 下：负责人 + 更新时间
  - 右：箭头进入详情

------

### 12) 工单详情页（Work Order Detail）

**顶部摘要卡**

- 工单号、状态、创建时间、设备/部件

**处理清单（Checklist）**

- 勾选项列表（至少 5 条占位）
- 每项：标题 + 说明（Caption）

**附件区（Attachment，附件）**

- 图片占位网格（Grid 3 列）
- “上传”按钮（先占位）

**处理记录（Timeline）**

- 时间线列表：创建/接单/处理/完成

**底部按钮**

- 主按钮：状态流转（下一步）
- 次按钮：添加备注

------

### 13) 我的/设置页（Profile/Settings）

**顶部个人卡**

- 头像圆形（48dp）+ 名称 + 账号
- 右侧：退出登录（小按钮）

**设置分组（Section）**

- 设备管理：已绑定设备列表入口
- 通知设置：开关（Switch，开关控件）
- 阈值展示：温度/电压/电流阈值（只读卡片）
- 关于：版本号、隐私、日志导出（占位）

------

## 给 Copilot/Complit 的“可直接复制”生成提示词（Prompt）

> 按“先生成壳，再逐页生成”的顺序最稳：
> 1）先生成全局壳（路由+底部 Tab+主题） → 2）再生成每个页面 Widget Tree（组件树） → 3）最后接假数据与状态。

```text
生成一个 Flutter(跨平台移动UI框架) 前端 UI 工程，只做 GUI，不接真实后端。
要求：
1) 使用 Material 3(谷歌UI规范)；全局主题颜色使用：Primary RGB(39,99,255)、Background RGB(245,247,250)、Card RGB(255,255,255)、Text RGB(18,24,38)、SubText RGB(102,112,133)、Divider RGB(228,231,236)、Success RGB(18,183,106)、Warning RGB(245,158,11)、Danger RGB(240,68,56)。
2) 页面骨架用 Scaffold(页面骨架)，顶部栏用 AppBar(顶部栏)，底部导航用 BottomNavigationBar(底部导航栏)，列表用 ListView(可滚动列表)，网格用 GridView(网格布局)。
3) 实现以下页面（仅布局+假数据+加载/空/错误状态），并按路由可跳转：
- Splash(启动页)
- Login(登录页)
- DeviceList(设备列表页)
- DeviceDetailShell(设备详情壳：含页内 TabBar)
  - Tab: 3DView(3D设备页：上3D容器+下指标卡+右侧Drawer抽屉)
  - Tab: RealtimeDashboard(监测总览：顶部连接状态条+KPI大卡+网格指标+最新事件)
  - Tab: Charts(曲线：顶部指标多选+主折线图+数据点表折叠)
- AlarmWorkShell(告警/工单壳：分段切换)
  - AlarmCenter(告警中心列表+筛选)
  - WorkOrders(工单列表+筛选)
- AlarmDetail(告警详情：摘要卡+证据条+小折线+建议+底部按钮)
- WorkOrderDetail(工单详情：摘要+检查清单+附件网格+时间线+底部按钮)
- ProfileSettings(我的/设置)
4) 所有页面要有：Loading(骨架屏)、Empty(空状态)、Error(错误状态+重试) 三种状态 UI（用一个简单枚举切换）。
5) 3DView 的 3D 区域先用一个占位容器(带旋转/全屏按钮)；折线图区域先用占位容器(写明“Line Chart Placeholder”)。
6) 代码结构清晰：screens/ components/ theme/ routes/ mock_data/。
输出：完整可运行的 Flutter 工程代码。
```

------

## 生成顺序建议（让工具更容易一次成功）

1. 先生成 **theme + routes + bottom tabs 壳**
2. 再生成 **DeviceList / DeviceDetailShell / AlarmWorkShell** 三个“骨架页”
3. 再补 **每个 Tab 的内容页**（3DView、RealtimeDashboard、Charts、AlarmCenter、WorkOrders）
4. 最后补 **详情页**（AlarmDetail、WorkOrderDetail）与 **ProfileSettings**

