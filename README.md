# monitoring_system

监控系统 - 集成 AI 专家助手的工业监控平台

## 项目简介

这是一个基于 Flutter 开发的工业设备监控系统，集成了 OpenAI 大语言模型，提供智能化的设备监控、告警分析和工单建议功能。

## 主要功能

### 🤖 AI 专家助手
- **智能对话**：与 AI 进行自然语言交互，获取专业建议
- **快捷操作**：一键获取工单建议、告警分析、预测维护等
- **上下文理解**：AI 会记住对话历史，提供连贯的建议

### 📊 实时监控
- 3D 设备视图
- 实时数据监测
- 关键指标展示
- 历史数据曲线

### ⚠️ 智能告警
- **AI 告警分析**：自动分析告警根因和风险
- 多级别告警管理
- 告警历史记录
- 智能推荐处理措施

### 📝 智能工单
- **AI 工单建议**：基于告警自动生成处理建议
- 工单生命周期管理
- 处理清单和备件管理
- 维护记录追踪

## 快速开始

### 前置要求
- Flutter SDK (>=3.10.8)
- Dart SDK
- OpenAI API Key (用于 AI 功能)

### 安装步骤

1. 克隆项目
```bash
git clone https://github.com/Hb-zzz-momo/monitoring_system.git
cd monitoring_system
```

2. 安装依赖
```bash
flutter pub get
```

3. 运行应用
```bash
flutter run
```

### 配置 AI 功能

1. 启动应用后，点击底部导航栏的 "AI 助手" 标签
2. 点击右上角的设置图标
3. 输入您的 OpenAI API Key
4. 开始使用 AI 功能

详细的 AI 集成文档请查看 [AI_INTEGRATION.md](AI_INTEGRATION.md)

## 项目结构

```
lib/
├── main.dart                      # 应用入口
├── services/                      # 服务层
│   ├── ai_service.dart           # AI API 集成
│   ├── ai_chat_provider.dart     # AI 状态管理
│   └── ai_config.dart            # AI 配置
├── models/                        # 数据模型
│   └── chat_message.dart         # 聊天消息模型
├── screens/                       # 页面
│   ├── ai_assistant_screen.dart  # AI 助手页面
│   ├── alarm_detail_example.dart # 告警详情示例
│   └── work_order_create_example.dart # 工单创建示例
└── widgets/                       # 组件
    ├── ai_work_order_suggestion.dart # 工单建议组件
    └── ai_alarm_analysis.dart        # 告警分析组件
```

## 技术栈

- **框架**: Flutter / Dart
- **AI 集成**: OpenAI GPT-4
- **状态管理**: Provider
- **HTTP 客户端**: http package

## 功能演示

### AI 助手对话
<details>
<summary>点击展开</summary>

- 自然语言交互
- 快捷操作按钮
- 对话历史记录
- 实时响应
</details>

### AI 告警分析
<details>
<summary>点击展开</summary>

- 自动根因分析
- 风险评估
- 处理建议
- 预防措施
</details>

### AI 工单建议
<details>
<summary>点击展开</summary>

- 智能生成处理步骤
- 备件推荐
- 时间估算
- 优先级评估
</details>

## 开发指南

详细的开发文档请参考：
- [GUI 生成细节](GUI生成细节.md) - UI 设计规范
- [AI 集成指南](AI_INTEGRATION.md) - AI 功能集成文档

## 测试

运行测试：
```bash
flutter test
```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

本项目遵循项目许可证条款。

## 联系方式

如有问题或建议，请通过 GitHub Issues 联系我们。

---

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
