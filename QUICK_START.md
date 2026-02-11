# 快速开始指南 / Quick Start Guide

## 5 分钟快速上手 AI 功能

### 步骤 1: 获取 OpenAI API Key

1. 访问 [OpenAI Platform](https://platform.openai.com/)
2. 注册或登录账号
3. 进入 [API Keys 页面](https://platform.openai.com/api-keys)
4. 点击 "Create new secret key"
5. 复制生成的 API Key (格式: sk-...)

**重要提示**: 
- API Key 只显示一次，请妥善保存
- 建议设置使用限额以控制成本
- 不要在公共场合分享您的 API Key

### 步骤 2: 运行应用

```bash
# 克隆项目
git clone https://github.com/Hb-zzz-momo/monitoring_system.git
cd monitoring_system

# 安装依赖
flutter pub get

# 运行应用
flutter run
```

### 步骤 3: 配置 API Key

1. 启动应用后，点击底部导航栏最右边的 **"AI 助手"** 图标 (🤖)
2. 在欢迎页面，点击 **"配置 API Key"** 按钮
3. 在弹出的对话框中，粘贴您的 OpenAI API Key
4. 点击 **"保存"**

### 步骤 4: 开始使用

#### 4.1 AI 聊天助手

在 AI 助手页面：
- 使用快捷按钮快速提问：
  - 📝 **工单建议**
  - ⚠️ **告警分析**
  - 🔧 **预测维护**
  - 🔍 **设备诊断**
- 或者直接在输入框输入您的问题

**示例问题**:
```
- "帮我分析电机 A 的过温告警"
- "如何处理冷却系统故障？"
- "给出设备维护建议"
```

#### 4.2 AI 告警分析

在告警/工单页面：
1. 查看告警列表
2. 点击告警卡片中的 **"AI 告警分析"** 按钮
3. 等待几秒，AI 会自动分析：
   - 根本原因
   - 风险评估
   - 处理建议
   - 预防措施
4. 点击 **"创建工单"** 将 AI 分析应用到新工单

#### 4.3 AI 工单建议

在工单创建页面：
1. 填写基本信息（设备、部件、告警类型）
2. 点击 **"获取建议"** 按钮
3. AI 会提供：
   - 处理步骤
   - 所需备件
   - 预计时间
   - 优先级评估
4. 点击 **"应用建议"** 将内容填入工单

## 常见问题 / FAQ

### Q1: API Key 配置后没有反应？
**A**: 请检查：
- API Key 格式是否正确 (应以 sk- 开头)
- 网络连接是否正常
- OpenAI 账户是否有余额

### Q2: AI 响应很慢或超时？
**A**: 可能的原因：
- 网络延迟
- OpenAI 服务器负载高
- 尝试在 AI 配置中切换到 gpt-3.5-turbo 模型（更快）

### Q3: 出现 "Rate limit exceeded" 错误？
**A**: 您的 API 调用频率超限：
- 等待一段时间后重试
- 在 OpenAI 账户中查看配额
- 考虑升级 API 计划

### Q4: 如何修改 API Key？
**A**: 
1. 进入 AI 助手页面
2. 点击右上角的设置图标 (⚙️)
3. 输入新的 API Key
4. 点击保存

### Q5: 数据安全吗？
**A**: 
- API Key 存储在本地设备
- 对话通过 HTTPS 加密传输
- 建议不要输入敏感的企业机密信息

## 进阶使用

### 自定义 AI 提示词

编辑 `lib/services/ai_config.dart` 文件：

```dart
static const String customAlarmPrompt = '''
您的自定义提示词...
专注于您的行业特定需求
''';
```

### 切换 AI 模型

在 `ai_config.dart` 中修改：

```dart
// 使用 GPT-3.5 (更快、更便宜)
static const String defaultModel = 'gpt-3.5-turbo';

// 使用 GPT-4 (更准确、更智能)
static const String defaultModel = 'gpt-4';
```

### 调整响应长度

修改最大 token 数：

```dart
static const int maxTokens = 500;  // 默认
static const int maxTokens = 1000; // 更长的响应
static const int maxTokens = 250;  // 更短、更省成本
```

## 成本估算

基于 OpenAI 定价（2024年2月）：

| 模型 | 输入价格 | 输出价格 | 单次对话成本 |
|------|---------|---------|-------------|
| GPT-3.5-turbo | $0.0005/1K tokens | $0.0015/1K tokens | ~$0.002 |
| GPT-4 | $0.03/1K tokens | $0.06/1K tokens | ~$0.05 |

**估算**：
- 100次对话 (GPT-3.5): ~$0.20
- 100次对话 (GPT-4): ~$5.00

**省钱技巧**：
1. 开发环境使用 GPT-3.5
2. 启用响应缓存
3. 减少 maxTokens 值
4. 清除不必要的对话历史

## 技术支持

### 查看日志

开启调试日志：

```dart
// 在 ai_config.dart 中
static const bool enableDebugLogging = true;
```

### 测试 API 连接

运行测试：

```bash
flutter test test/ai_integration_test.dart
```

### 查看文档

- [AI 集成文档](AI_INTEGRATION.md)
- [UI 界面指南](UI_GUIDE.md)
- [配置示例](lib/services/example_config.dart)

## 反馈与贡献

遇到问题或有建议？
- 提交 [GitHub Issue](https://github.com/Hb-zzz-momo/monitoring_system/issues)
- 参与讨论和改进

## 下一步

- 探索更多 AI 功能
- 根据您的需求自定义提示词
- 集成到实际监控系统
- 训练专家模型（使用您的历史数据）

---

开始使用 AI 让您的监控系统更智能！🚀
