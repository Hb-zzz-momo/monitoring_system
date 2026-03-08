/// 设备数据模型（强类型，替代页面层直接使用 Map<String, dynamic>）
class DeviceModel {
  final String id;
  final String name;
  final String type;
  final double temperature;
  final double power;
  final String location;
  final bool isOnline;
  final double healthIndex;
  final String? lastSeen;
  final String? status;
  final Map<String, dynamic> extra;

  const DeviceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.isOnline,
    required this.healthIndex,
    this.temperature = 0.0,
    this.power = 0.0,
    this.lastSeen,
    this.status,
    this.extra = const {},
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      isOnline: json['isOnline'] as bool? ?? false,
      healthIndex: (json['healthIndex'] as num?)?.toDouble() ?? 1.0,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      power: (json['power'] as num?)?.toDouble() ?? 0.0,
      lastSeen: json['lastSeen']?.toString(),
      status: json['status']?.toString(),
      extra: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'location': location,
        'isOnline': isOnline,
        'healthIndex': healthIndex,
        'temperature': temperature,
        'power': power,
        if (lastSeen != null) 'lastSeen': lastSeen,
        if (status != null) 'status': status,
      };

  @override
  String toString() => 'DeviceModel(id: $id, name: $name, isOnline: $isOnline)';
}
