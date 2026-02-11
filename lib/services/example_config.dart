/// Example configuration file
/// Copy this file and rename it to match your environment
/// 
/// SECURITY WARNING: Never commit actual API keys to version control!
/// This file is for demonstration purposes only.

class ExampleConfig {
  // ============================================
  // OpenAI API Configuration Example
  // ============================================
  
  /// Example: How to set up your API key
  /// 
  /// In production, you should:
  /// 1. Store API keys in environment variables
  /// 2. Use secure storage (e.g., flutter_secure_storage)
  /// 3. Never hardcode keys in source code
  /// 
  /// Example environment variable setup:
  /// ```
  /// export OPENAI_API_KEY="sk-your-actual-api-key-here"
  /// ```
  static const String apiKeyExample = 'sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
  
  // ============================================
  // Configuration Examples for Different Scenarios
  // ============================================
  
  /// Example 1: Development Environment
  static const Map<String, dynamic> developmentConfig = {
    'environment': 'development',
    'apiKey': 'use-environment-variable',
    'model': 'gpt-3.5-turbo', // Faster and cheaper for dev
    'maxTokens': 300,
    'enableDebugLogging': true,
  };
  
  /// Example 2: Production Environment
  static const Map<String, dynamic> productionConfig = {
    'environment': 'production',
    'apiKey': 'use-secure-storage',
    'model': 'gpt-4', // More accurate for production
    'maxTokens': 500,
    'enableDebugLogging': false,
    'enableResponseCaching': true,
  };
  
  /// Example 3: Cost-Optimized Configuration
  static const Map<String, dynamic> costOptimizedConfig = {
    'model': 'gpt-3.5-turbo',
    'maxTokens': 250,
    'temperature': 0.5,
    'maxRequestsPerHour': 50,
    'enableResponseCaching': true,
    'cacheDuration': 'PT2H', // 2 hours
  };
  
  // ============================================
  // Example Custom Prompts
  // ============================================
  
  /// Example: Customized alarm analysis prompt for specific industry
  static const String customAlarmPrompt = '''
You are an AI expert for industrial motor monitoring systems.
When analyzing alarms:
- Focus on electrical and mechanical failure modes
- Consider bearing wear, thermal issues, and electrical faults
- Reference industry standards (ISO, NEMA, etc.)
- Prioritize safety and uptime
Provide specific, actionable recommendations.
''';
  
  /// Example: Customized work order prompt with company-specific procedures
  static const String customWorkOrderPrompt = '''
Generate work orders following our company procedures:
1. Always include safety checks first
2. Reference our internal part numbers
3. Estimate time based on technician skill level
4. Include required certifications if applicable
5. Add quality check steps
Format the work order in our standard template.
''';
  
  // ============================================
  // Example API Key Validation
  // ============================================
  
  /// Example: How to validate API key before using
  static bool validateApiKey(String apiKey) {
    // Check format
    if (!apiKey.startsWith('sk-')) {
      print('Error: API key must start with "sk-"');
      return false;
    }
    
    // Check length
    if (apiKey.length < 35) {
      print('Error: API key is too short');
      return false;
    }
    
    return true;
  }
  
  // ============================================
  // Example Usage Scenarios
  // ============================================
  
  /// Example 1: Simple chat message
  static const Map<String, dynamic> exampleChatRequest = {
    'message': '分析电机A的运行状态',
    'context': 'general',
  };
  
  /// Example 2: Alarm analysis
  static const Map<String, dynamic> exampleAlarmRequest = {
    'alarmType': '过温告警',
    'deviceName': '电机 A',
    'componentName': '冷却风扇',
    'currentValue': 85.2,
    'threshold': 75.0,
    'historicalData': '过去24小时平均温度: 72°C',
  };
  
  /// Example 3: Work order suggestion
  static const Map<String, dynamic> exampleWorkOrderRequest = {
    'deviceName': '电机 A',
    'alarmType': '过温告警',
    'componentName': '冷却风扇',
    'additionalContext': '温度持续超过阈值30分钟',
  };
  
  // ============================================
  // Example Response Handling
  // ============================================
  
  /// Example: Expected AI response structure
  static const Map<String, dynamic> exampleAlarmAnalysisResponse = {
    'rootCause': [
      '冷却风扇效率降低',
      '散热器堵塞',
      '环境温度过高',
    ],
    'riskAssessment': '高风险 - 可能导致设备损坏或停机',
    'immediateActions': [
      '降低设备负载',
      '检查冷却风扇运行状态',
      '清理散热器',
    ],
    'preventiveMeasures': [
      '定期维护冷却系统',
      '监控环境温度',
      '建立预防性维护计划',
    ],
  };
  
  /// Example: Expected work order response structure
  static const Map<String, dynamic> exampleWorkOrderResponse = {
    'priority': 'high',
    'estimatedTime': '2-3 hours',
    'requiredParts': [
      {'name': '冷却风扇', 'model': 'FAN-001', 'quantity': 1},
      {'name': '散热硅脂', 'spec': '5g', 'quantity': 1},
    ],
    'steps': [
      '1. 关闭设备电源',
      '2. 移除旧风扇',
      '3. 清理散热器',
      '4. 安装新风扇',
      '5. 测试运行',
    ],
    'safetyNotes': [
      '确保设备已断电',
      '佩戴防护手套',
    ],
  };
  
  // ============================================
  // Example Error Handling
  // ============================================
  
  /// Example error messages
  static const Map<String, String> exampleErrors = {
    'invalid_api_key': 'API Key 无效或未配置',
    'network_error': '网络连接失败，请检查网络设置',
    'rate_limit': 'API 调用频率超限，请稍后重试',
    'timeout': '请求超时，请重试',
    'invalid_response': 'AI 响应格式错误',
  };
  
  // ============================================
  // Example Testing Configuration
  // ============================================
  
  /// Example: Mock responses for testing
  static const bool enableMockResponses = false; // Set to true for testing
  
  static const String mockAlarmAnalysis = '''
根本原因分析：
1. 冷却系统效率降低 - 风扇老化或灰尘堆积
2. 环境温度异常 - 外部环境温度过高

风险评估：
- 短期：设备性能下降，可能触发保护停机
- 长期：加速设备老化，缩短使用寿命

建议措施：
1. 立即检查冷却风扇状态
2. 清理散热器
3. 监控环境温度
4. 如风扇损坏，立即更换

预防措施：
- 建立定期维护计划（每月检查一次）
- 安装温度监控传感器
- 保持机房良好通风
''';
  
  static const String mockWorkOrderSuggestion = '''
工单建议：

优先级：高
预计时间：2-3小时

立即行动：
1. 关闭设备并断电（安全第一）
2. 检查冷却风扇运行状态
3. 测量风扇转速（应 ≥ 1200 RPM）
4. 清理散热器灰尘
5. 检查热传感器校准

所需备件：
- 冷却风扇 (型号: FAN-001) x 1
- 散热硅脂 (5g) x 1
- 清洁工具套装

安全注意事项：
- 确保设备已完全断电
- 佩戴防护手套和护目镜
- 注意旋转部件
''';
}
