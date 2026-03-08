/// 工单数据模型（强类型，替代页面层直接使用 Map<String, dynamic>）
class WorkOrderModel {
  final String id;
  final String title;
  final String device;
  final String component;

  /// 工单状态：'待处理'、'处理中'、'已完成'
  final String status;
  final String createdTime;
  final String description;
  final Map<String, dynamic> extra;

  const WorkOrderModel({
    required this.id,
    required this.title,
    required this.device,
    required this.component,
    required this.status,
    required this.createdTime,
    required this.description,
    this.extra = const {},
  });

  factory WorkOrderModel.fromJson(Map<String, dynamic> json) {
    return WorkOrderModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      device: json['device']?.toString() ?? '',
      component: json['component']?.toString() ?? '',
      status: json['status']?.toString() ?? '待处理',
      createdTime: json['createdTime']?.toString() ??
          json['created_time']?.toString() ??
          '',
      description: json['description']?.toString() ?? '',
      extra: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'device': device,
        'component': component,
        'status': status,
        'createdTime': createdTime,
        'description': description,
      };

  /// 是否已完成
  bool get isCompleted => status == '已完成';

  /// 是否待处理
  bool get isPending => status == '待处理';

  @override
  String toString() =>
      'WorkOrderModel(id: $id, status: $status, device: $device)';
}
