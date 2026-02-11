/// AI 对话消息
class AiMessage {
  final String role; // 'user', 'assistant', 'system'
  final String content;
  final DateTime timestamp;

  AiMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}

/// 专家模型训练数据条目
class TrainingDataItem {
  final String input;
  final String expectedOutput;
  final String source; // 'device', 'alarm', 'manual'
  final DateTime createdAt;

  TrainingDataItem({
    required this.input,
    required this.expectedOutput,
    required this.source,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'input': input,
        'expected_output': expectedOutput,
        'source': source,
        'created_at': createdAt.toIso8601String(),
      };
}

/// 训练任务状态
class TrainingJob {
  final String id;
  final String status; // 'pending', 'running', 'completed', 'failed'
  final int totalSamples;
  final int processedSamples;
  final String? modelName;
  final DateTime createdAt;

  TrainingJob({
    required this.id,
    required this.status,
    required this.totalSamples,
    this.processedSamples = 0,
    this.modelName,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get progress =>
      totalSamples > 0 ? processedSamples / totalSamples : 0;
}

/// OpenAI 配置
class AiConfig {
  String apiKey;
  String baseUrl;
  String model;
  double temperature;
  int maxTokens;

  AiConfig({
    this.apiKey = '',
    this.baseUrl = 'https://api.openai.com/v1',
    this.model = 'gpt-4o-mini',
    this.temperature = 0.7,
    this.maxTokens = 2048,
  });
}
