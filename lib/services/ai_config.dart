/// AI Configuration
/// 
/// This file contains configuration for AI features.
/// In production, sensitive values should be loaded from secure storage or environment variables.

class AIConfig {
  // OpenAI API Configuration
  static const String openAIBaseUrl = 'https://api.openai.com/v1';
  
  // Model selection
  // Options: gpt-4, gpt-4-turbo, gpt-3.5-turbo
  static const String defaultModel = 'gpt-4';
  
  // Alternative models for different use cases
  static const String fastModel = 'gpt-3.5-turbo';  // Faster, less expensive
  static const String advancedModel = 'gpt-4-turbo';  // More capable
  
  // Model parameters
  static const double temperature = 0.7;  // Creativity level (0.0 - 1.0)
  static const int maxTokens = 500;  // Max response length
  static const double topP = 1.0;  // Nucleus sampling
  
  // Timeout and retry settings
  static const Duration requestTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  
  // Context settings
  static const int maxConversationHistory = 10;  // Number of messages to keep in context
  
  // Feature flags
  static const bool enableWorkOrderSuggestions = true;
  static const bool enableAlarmAnalysis = true;
  static const bool enablePredictiveMaintenance = true;
  static const bool enableChatHistory = true;
  
  // System prompts for different contexts
  static const String monitoringSystemPrompt = '''
You are an expert AI assistant for an industrial monitoring system.
You help with device monitoring, alarm analysis, work order suggestions, and predictive maintenance.
Your responses should be:
- Concise and actionable
- Based on industrial best practices
- Focused on safety and efficiency
- Specific to the context provided
Always provide structured recommendations when applicable.
''';
  
  static const String alarmAnalysisPrompt = '''
You are analyzing an alarm condition in an industrial monitoring system.
Provide:
1. Root cause analysis (most likely causes)
2. Risk assessment (what could happen if not addressed)
3. Immediate action recommendations
4. Long-term prevention measures
Be specific and technical but clear.
''';
  
  static const String workOrderPrompt = '''
You are creating work order recommendations based on alarm or maintenance needs.
Provide:
1. Recommended immediate actions (step-by-step)
2. Required parts or materials
3. Estimated time for completion
4. Priority level (low/medium/high/urgent) with justification
5. Safety considerations
Be practical and implementation-focused.
''';
  
  static const String predictiveMaintenancePrompt = '''
You are analyzing device metrics to predict maintenance needs.
Provide:
1. Components requiring attention (with urgency)
2. Estimated remaining useful life (be realistic)
3. Recommended maintenance schedule
4. Risk assessment (consequences of delayed maintenance)
Base your analysis on the provided metrics and typical failure patterns.
''';
  
  // Response formatting preferences
  static const bool useMarkdownFormatting = true;
  static const bool includeTechnicalDetails = true;
  
  // Logging and debugging
  static const bool enableDebugLogging = false;
  static const bool logAPIRequests = false;
  
  // Cost and usage limits (optional safeguards)
  static const int maxRequestsPerHour = 100;
  static const int maxTokensPerRequest = 1000;
  
  // Cache settings
  static const bool enableResponseCaching = true;
  static const Duration cacheDuration = Duration(hours: 1);
  
  // Multilingual support
  static const String defaultLanguage = 'zh-CN';  // Chinese
  static const List<String> supportedLanguages = ['zh-CN', 'en-US'];
  
  // Custom model endpoints (for using alternative AI providers)
  static String? customEndpoint;
  
  // API key validation pattern
  static final RegExp apiKeyPattern = RegExp(r'^sk-[a-zA-Z0-9]{32,}$');
  
  // User preferences (can be overridden per user)
  static const Map<String, dynamic> defaultUserPreferences = {
    'showQuickActions': true,
    'autoExpandAnalysis': false,
    'enableNotifications': true,
    'preferredResponseLength': 'medium', // short, medium, long
  };
  
  /// Validate API key format
  static bool isValidApiKey(String apiKey) {
    return apiKeyPattern.hasMatch(apiKey);
  }
  
  /// Get system prompt for specific context
  static String getSystemPrompt(AIContext context) {
    switch (context) {
      case AIContext.general:
        return monitoringSystemPrompt;
      case AIContext.alarmAnalysis:
        return alarmAnalysisPrompt;
      case AIContext.workOrder:
        return workOrderPrompt;
      case AIContext.predictiveMaintenance:
        return predictiveMaintenancePrompt;
    }
  }
}

enum AIContext {
  general,
  alarmAnalysis,
  workOrder,
  predictiveMaintenance,
}

/// Specialized prompts for Chinese language
class ChinesePrompts {
  static const String alarmAnalysisPrompt = '''
你是一个工业监控系统的专家AI助手，正在分析告警情况。
请提供：
1. 根本原因分析（最可能的原因）
2. 风险评估（如果不处理会发生什么）
3. 立即行动建议
4. 长期预防措施
请具体且技术性强，但表述清晰。
''';
  
  static const String workOrderPrompt = '''
你是一个工业监控系统的专家AI助手，正在创建工单建议。
请提供：
1. 建议的立即行动（分步骤说明）
2. 所需零件或材料
3. 预计完成时间
4. 优先级（低/中/高/紧急）及理由
5. 安全注意事项
请实用且具有可实施性。
''';
}
