# AI 集成指南 / AI Integration Guide

## 概述 / Overview

本监控系统已集成 OpenAI 大模型，提供智能化的设备监控、告警分析和工单建议功能。

This monitoring system has integrated OpenAI's large language model to provide intelligent device monitoring, alarm analysis, and work order suggestions.

## 功能特性 / Features

### 1. AI 专家助手 (AI Expert Assistant)
- 位于底部导航栏的独立 Tab
- 支持与 AI 进行对话交互
- 快捷操作：工单建议、告警分析、预测维护、设备诊断
- 保持对话历史记录

### 2. AI 告警分析 (AI Alarm Analysis)
- 自动分析告警根因
- 评估潜在风险
- 提供处理建议
- 预防措施推荐

### 3. AI 工单建议 (AI Work Order Suggestions)
- 基于告警自动生成工单建议
- 推荐所需备件和材料
- 估算完成时间
- 评估优先级

## 使用说明 / Usage

### 配置 API Key

1. 打开应用并导航到"AI 助手" Tab
2. 点击右上角的"设置"图标
3. 输入您的 OpenAI API Key (格式: sk-...)
4. 点击"保存"

### 使用 AI 助手

1. 在"AI 助手"页面，您可以：
   - 直接输入问题与 AI 对话
   - 使用快捷操作按钮快速获取建议
   - 查看历史对话记录

2. 在"告警/工单"页面：
   - 点击告警卡片中的"AI 告警分析"按钮获取智能分析
   - 在工单中点击"AI 工单建议"获取处理建议

## 技术实现 / Technical Implementation

### 架构组件 / Architecture Components

```
lib/
├── services/
│   ├── ai_service.dart          # OpenAI API 集成
│   └── ai_chat_provider.dart    # 状态管理
├── models/
│   └── chat_message.dart        # 聊天消息模型
├── screens/
│   └── ai_assistant_screen.dart # AI 助手界面
└── widgets/
    ├── ai_work_order_suggestion.dart  # 工单建议组件
    └── ai_alarm_analysis.dart         # 告警分析组件
```

### 依赖包 / Dependencies

- `http: ^1.2.0` - HTTP 客户端
- `provider: ^6.1.1` - 状态管理

### API 集成 / API Integration

系统使用 OpenAI GPT-4 模型，通过以下端点进行通信：
- Endpoint: `https://api.openai.com/v1/chat/completions`
- Model: `gpt-4`
- Temperature: `0.7`
- Max Tokens: `500`

## 安全注意事项 / Security Notes

⚠️ **重要提示 / Important:**

1. API Key 应妥善保管，不要硬编码在代码中
2. 建议使用环境变量或安全存储来管理 API Key
3. 在生产环境中应实现适当的访问控制
4. 注意 API 调用限制和成本控制

## 示例使用场景 / Example Use Cases

### 场景 1: 设备过温告警
```
用户: 电机 A 温度超过阈值，当前 85°C，阈值 75°C
AI: 根据告警信息，我分析如下：
    1. 根因：可能是冷却系统效率降低或负载过大
    2. 风险：持续高温可能导致设备损坏或停机
    3. 建议：立即降低负载，检查冷却风扇
    4. 预防：定期维护冷却系统，监控负载变化
```

### 场景 2: 工单建议
```
用户: 需要为电机 A 的过温告警创建工单
AI: 工单建议：
    1. 优先级：高
    2. 所需备件：冷却风扇、散热片
    3. 预计时间：2-3 小时
    4. 建议措施：
       - 更换冷却风扇
       - 清理散热器
       - 检查热传感器
```

## 扩展功能 / Future Enhancements

- [ ] 支持多种 AI 模型选择
- [ ] 本地模型部署选项
- [ ] 历史数据训练专家模型
- [ ] 多语言支持
- [ ] 离线模式
- [ ] 语音交互

## 开发指南 / Development Guide

### 添加新的 AI 功能

1. 在 `ai_service.dart` 中添加新方法
2. 在 `ai_chat_provider.dart` 中暴露接口
3. 创建对应的 UI 组件
4. 集成到相应页面

### 自定义 AI 提示词

编辑 `ai_service.dart` 中的 prompt 模板：

```dart
final prompt = '''
您的自定义提示词...
''';
```

## 故障排查 / Troubleshooting

### API Key 无效
- 确保 API Key 格式正确 (以 sk- 开头)
- 检查 OpenAI 账户余额

### 请求失败
- 检查网络连接
- 确认 API 配额未超限
- 查看错误日志

### 响应缓慢
- 可能是网络延迟
- OpenAI 服务器负载较高
- 考虑调整 timeout 设置

## 贡献 / Contributing

欢迎提交 Issue 和 Pull Request 来改进 AI 集成功能。

## 许可证 / License

请遵循项目主许可证。
