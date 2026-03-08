/// 实时指标数据模型
class MetricsModel {
  final double temperature;
  final double voltage;
  final double current;
  final double power;
  final double energy;

  /// 数据延迟（毫秒）
  final int delay;
  final bool isConnected;

  const MetricsModel({
    required this.temperature,
    required this.voltage,
    required this.current,
    required this.power,
    this.energy = 0.0,
    this.delay = 0,
    this.isConnected = false,
  });

  factory MetricsModel.fromJson(Map<String, dynamic> json) {
    return MetricsModel(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      voltage: (json['voltage'] as num?)?.toDouble() ?? 0.0,
      current: (json['current'] as num?)?.toDouble() ?? 0.0,
      power: (json['power'] as num?)?.toDouble() ?? 0.0,
      energy: (json['energy'] as num?)?.toDouble() ?? 0.0,
      delay: (json['delay'] as num?)?.toInt() ?? 0,
      isConnected: json['isConnected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'temperature': temperature,
        'voltage': voltage,
        'current': current,
        'power': power,
        'energy': energy,
        'delay': delay,
        'isConnected': isConnected,
      };

  @override
  String toString() =>
      'MetricsModel(temp: $temperature, volt: $voltage, cur: $current, pow: $power)';
}

/// 设备健康寿命模型
class HealthModel {
  /// 整体健康指数（0.0 ~ 1.0）
  final double overallHI;

  /// 剩余使用寿命（天）
  final int overallRUL;

  /// 寿命区间描述，例如 "2.5~3.2年"
  final String rulRange;

  /// 趋势：'stable'、'declining'、'improving'
  final String trend;

  /// 子部件健康数据列表
  final List<Map<String, dynamic>> components;

  /// 预测数据列表（用于趋势图）
  final List<Map<String, dynamic>> predictions;

  /// 维护建议列表
  final List<String> suggestions;

  const HealthModel({
    required this.overallHI,
    required this.overallRUL,
    required this.rulRange,
    required this.trend,
    this.components = const [],
    this.predictions = const [],
    this.suggestions = const [],
  });

  factory HealthModel.fromJson(Map<String, dynamic> json) {
    final rawComponents = json['components'];
    final rawPredictions = json['predictions'];
    final rawSuggestions = json['suggestions'];

    return HealthModel(
      overallHI: (json['overallHI'] as num?)?.toDouble() ?? 0.0,
      overallRUL: (json['overallRUL'] as num?)?.toInt() ?? 0,
      rulRange: json['rulRange']?.toString() ?? '-',
      trend: json['trend']?.toString() ?? 'stable',
      components: rawComponents is List
          ? rawComponents.whereType<Map<String, dynamic>>().toList()
          : const [],
      predictions: rawPredictions is List
          ? rawPredictions.whereType<Map<String, dynamic>>().toList()
          : const [],
      suggestions: rawSuggestions is List
          ? rawSuggestions.map((s) => s.toString()).toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'overallHI': overallHI,
        'overallRUL': overallRUL,
        'rulRange': rulRange,
        'trend': trend,
        'components': components,
        'predictions': predictions,
        'suggestions': suggestions,
      };

  @override
  String toString() =>
      'HealthModel(overallHI: $overallHI, overallRUL: $overallRUL, trend: $trend)';
}
