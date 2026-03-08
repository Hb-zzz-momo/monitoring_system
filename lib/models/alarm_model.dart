/// 告警数据模型（强类型，替代页面层直接使用 Map<String, dynamic>）
class AlarmModel {
  final String id;
  final String title;

  /// 告警级别：'danger'（告警）、'warning'（预警）、'info'（提示）
  final String level;
  final String device;
  final String component;
  final String time;
  final double currentValue;
  final double threshold;

  /// 告警状态：'未处理'、'已处理' 等
  final String status;
  final Map<String, dynamic> extra;

  const AlarmModel({
    required this.id,
    required this.title,
    required this.level,
    required this.device,
    required this.component,
    required this.time,
    required this.currentValue,
    required this.threshold,
    required this.status,
    this.extra = const {},
  });

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      level: json['level']?.toString() ?? 'warning',
      device: json['device']?.toString() ?? '',
      component: json['component']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      threshold: (json['threshold'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? '未处理',
      extra: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'level': level,
        'device': device,
        'component': component,
        'time': time,
        'currentValue': currentValue,
        'threshold': threshold,
        'status': status,
      };

  /// 是否已处理
  bool get isProcessed => status == '已处理';

  /// 是否为严重告警
  bool get isDanger => level == 'danger';

  @override
  String toString() => 'AlarmModel(id: $id, level: $level, status: $status)';
}
