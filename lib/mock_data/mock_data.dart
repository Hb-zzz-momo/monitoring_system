class MockData {
  static List<Map<String, dynamic>> devices = [
    {
      'id': '1',
      'name': '主控设备-01',
      'isOnline': true,
      'lastUpdate': '2分钟前',
      'temperature': 42.3,
      'power': 3.2,
    },
    {
      'id': '2',
      'name': '监测设备-02',
      'isOnline': true,
      'lastUpdate': '5分钟前',
      'temperature': 38.7,
      'power': 2.8,
    },
    {
      'id': '3',
      'name': '备用设备-03',
      'isOnline': false,
      'lastUpdate': '2小时前',
      'temperature': 25.0,
      'power': 0.0,
    },
    {
      'id': '4',
      'name': '测试设备-04',
      'isOnline': true,
      'lastUpdate': '刚刚',
      'temperature': 45.2,
      'power': 4.1,
    },
  ];

  static List<Map<String, dynamic>> alarms = [
    {
      'id': '1',
      'title': '部件过温告警',
      'level': 'danger',
      'device': '主控设备-01',
      'component': '主轴承',
      'time': '10分钟前',
      'currentValue': 78.5,
      'threshold': 75.0,
      'status': '进行中',
      'description': '主轴承温度超过阈值',
    },
    {
      'id': '2',
      'title': '电压异常预警',
      'level': 'warning',
      'device': '监测设备-02',
      'component': '电源模块',
      'time': '1小时前',
      'currentValue': 235.0,
      'threshold': 240.0,
      'status': '进行中',
      'description': '电压接近上限',
    },
    {
      'id': '3',
      'title': '连接异常',
      'level': 'warning',
      'device': '备用设备-03',
      'component': '通讯模块',
      'time': '2小时前',
      'currentValue': 0,
      'threshold': 0,
      'status': '已处理',
      'description': '设备离线',
    },
  ];

  static List<Map<String, dynamic>> workOrders = [
    {
      'id': 'WO-2024-001',
      'device': '主控设备-01',
      'component': '主轴承',
      'status': '处理中',
      'title': '更换主轴承',
      'assignee': '张工',
      'createdTime': '2小时前',
      'updatedTime': '30分钟前',
      'description': '主轴承温度持续偏高，需要检查并更换',
    },
    {
      'id': 'WO-2024-002',
      'device': '监测设备-02',
      'component': '电源模块',
      'status': '待处理',
      'title': '检查电压稳定性',
      'assignee': '李工',
      'createdTime': '1小时前',
      'updatedTime': '1小时前',
      'description': '电压波动异常，需要检查电源模块',
    },
    {
      'id': 'WO-2024-003',
      'device': '备用设备-03',
      'component': '通讯模块',
      'status': '已完成',
      'title': '恢复设备连接',
      'assignee': '王工',
      'createdTime': '5小时前',
      'updatedTime': '3小时前',
      'description': '设备通讯异常，已重新配置网络',
    },
  ];

  static Map<String, dynamic> deviceMetrics = {
    'temperature': 42.3,
    'voltage': 220.5,
    'current': 15.2,
    'power': 3.35,
    'energy': 125.8,
    'delay': 12,
    'isConnected': true,
  };

  static List<Map<String, dynamic>> realtimeEvents = [
    {
      'type': 'alarm',
      'icon': 'warning',
      'text': '主轴承温度告警',
      'time': '10分钟前',
    },
    {
      'type': 'status',
      'icon': 'info',
      'text': '设备启动完成',
      'time': '1小时前',
    },
    {
      'type': 'workorder',
      'icon': 'work',
      'text': '工单WO-2024-001已创建',
      'time': '2小时前',
    },
  ];

  static List<Map<String, dynamic>> components = [
    {
      'id': '1',
      'name': '主轴承',
      'healthIndex': 0.72,
      'rul': 180,
      'rulRange': '150-210',
      'suggestions': [
        '建议在未来30天内安排维护',
        '监控温度变化趋势',
        '准备备件',
      ],
      'metrics': [
        {'name': '温度', 'value': 78.5, 'unit': '℃'},
        {'name': '振动', 'value': 2.3, 'unit': 'mm/s'},
        {'name': '压力', 'value': 1.2, 'unit': 'MPa'},
      ],
    },
    {
      'id': '2',
      'name': '电机',
      'healthIndex': 0.85,
      'rul': 320,
      'rulRange': '280-350',
      'suggestions': [
        '状态良好',
        '保持定期巡检',
      ],
      'metrics': [
        {'name': '温度', 'value': 65.2, 'unit': '℃'},
        {'name': '电流', 'value': 15.2, 'unit': 'A'},
      ],
    },
  ];

  static List<Map<String, dynamic>> checklistItems = [
    {
      'title': '检查轴承温度',
      'description': '使用红外测温仪测量',
      'checked': true,
    },
    {
      'title': '检查润滑情况',
      'description': '确认润滑油充足',
      'checked': true,
    },
    {
      'title': '检查振动情况',
      'description': '使用振动仪测量',
      'checked': false,
    },
    {
      'title': '更换轴承',
      'description': '使用新备件更换',
      'checked': false,
    },
    {
      'title': '运行测试',
      'description': '确认设备正常运行',
      'checked': false,
    },
  ];

  static List<Map<String, dynamic>> timeline = [
    {
      'title': '工单创建',
      'time': '2024-01-10 08:30',
      'description': '系统自动创建工单',
    },
    {
      'title': '已接单',
      'time': '2024-01-10 09:00',
      'description': '张工已接单',
    },
    {
      'title': '处理中',
      'time': '2024-01-10 10:00',
      'description': '开始现场检查',
    },
  ];
}
