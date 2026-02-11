import 'dart:math' show sin, cos;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/common_widgets.dart';
import '../mock_data/mock_data.dart';

class DeviceDetailShell extends StatefulWidget {
  final String deviceId;
  final String deviceName;

  const DeviceDetailShell({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  State<DeviceDetailShell> createState() => _DeviceDetailShellState();
}

class _DeviceDetailShellState extends State<DeviceDetailShell>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.deviceName),
            const SizedBox(width: 8),
            const StatusDot(isOnline: true, size: 6),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showBottomSheet();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.subText,
          tabs: const [
            Tab(text: '3D视图'),
            Tab(text: '监测总览'),
            Tab(text: '曲线'),
            Tab(text: '健康寿命'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DeviceThreeDView(),
          DeviceRealtimeView(),
          DeviceChartsView(),
          DeviceHealthLifespanView(),
        ],
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('编辑设备'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('刷新数据'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: AppColors.danger),
                title: Text('删除设备',
                    style: TextStyle(color: AppColors.danger)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// 3D View Tab in device detail
class DeviceThreeDView extends StatelessWidget {
  const DeviceThreeDView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.grey[300],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.view_in_ar,
                    size: 80,
                    color: AppColors.subText,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '3D Model Placeholder',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.subText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          color: AppColors.background,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: KpiCard(
                  title: '温度',
                  value: '${MockData.deviceMetrics['temperature']}',
                  unit: '℃',
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                  title: '功率',
                  value: '${MockData.deviceMetrics['power']}',
                  unit: 'kW',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Realtime Dashboard Tab in device detail
class DeviceRealtimeView extends StatelessWidget {
  const DeviceRealtimeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  title: '温度',
                  value: '${MockData.deviceMetrics['temperature']}',
                  unit: '℃',
                  icon: Icons.thermostat,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                  title: '电压',
                  value: '${MockData.deviceMetrics['voltage']}',
                  unit: 'V',
                  icon: Icons.bolt,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  title: '电流',
                  value: '${MockData.deviceMetrics['current']}',
                  unit: 'A',
                  icon: Icons.flash_on,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                  title: '功率',
                  value: '${MockData.deviceMetrics['power']}',
                  unit: 'kW',
                  icon: Icons.power,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Charts Tab in device detail
class DeviceChartsView extends StatefulWidget {
  const DeviceChartsView({super.key});

  @override
  State<DeviceChartsView> createState() => _DeviceChartsViewState();
}

class _DeviceChartsViewState extends State<DeviceChartsView> {
  final List<String> _selectedMetrics = ['温度'];
  String _selectedComponent = '整机';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top toolbar
        Container(
          color: AppColors.card,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '指标:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.subText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: ['温度', '电压', '电流', '功率']
                          .map((metric) => _buildMetricChip(metric))
                          .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '部件:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.subText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedComponent,
                    items: ['整机', '主轴承', '电机'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedComponent = newValue;
                        });
                      }
                    },
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Chart area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Main chart
                Container(
                  height: 320,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '实时曲线',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                            Text(
                              '最近30分钟',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.subText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: CustomPaint(
                            painter: LineChartPainter(
                              metrics: _selectedMetrics,
                            ),
                            child: Container(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Legend
                        Wrap(
                          spacing: 16,
                          children: _selectedMetrics.map((metric) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 16,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: _getMetricColor(metric),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  metric,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.subText,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Data points table (collapsible)
                Card(
                  child: ExpansionTile(
                    title: const Text(
                      '数据点表',
                      style: TextStyle(fontSize: 14),
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: List.generate(5, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '2024-01-10 ${10 + index}:${30 + index * 5}:00',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.subText,
                                    ),
                                  ),
                                  Text(
                                    '${42.0 + index * 0.5} ℃',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricChip(String metric) {
    final isSelected = _selectedMetrics.contains(metric);
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedMetrics.remove(metric);
          } else {
            _selectedMetrics.add(metric);
          }
        });
      },
      child: StatusChip(
        label: metric,
        isSelected: isSelected,
      ),
    );
  }

  Color _getMetricColor(String metric) {
    switch (metric) {
      case '温度':
        return AppColors.warning;
      case '电压':
        return AppColors.info;
      case '电流':
        return AppColors.success;
      case '功率':
        return AppColors.primary;
      default:
        return AppColors.text;
    }
  }
}

// Custom line chart painter with virtual data
class LineChartPainter extends CustomPainter {
  final List<String> metrics;

  LineChartPainter({required this.metrics});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw grid lines
    for (int i = 0; i <= 5; i++) {
      final y = size.height / 5 * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    for (int i = 0; i <= 6; i++) {
      final x = size.width / 6 * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    // Generate and draw data for each metric
    const dataPoints = 30;
    for (int metricIndex = 0; metricIndex < metrics.length; metricIndex++) {
      final metric = metrics[metricIndex];
      final color = _getMetricColorForPaint(metric);
      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path();
      
      // Generate virtual data points with some variation
      final baseValue = _getBaseValue(metric);
      final amplitude = _getAmplitude(metric);
      
      for (int i = 0; i < dataPoints; i++) {
        final x = size.width / (dataPoints - 1) * i;
        // Create a sine wave with some randomness for realistic look
        final noise = (i * 0.3).sin() * 0.3 + (i * 0.7).cos() * 0.2;
        final normalizedValue = 0.5 + (i / dataPoints * 0.3).sin() * 0.3 + noise * amplitude;
        final y = size.height - (normalizedValue * size.height);
        
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, linePaint);

      // Draw dots on data points
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      for (int i = 0; i < dataPoints; i += 5) {
        final x = size.width / (dataPoints - 1) * i;
        final noise = (i * 0.3).sin() * 0.3 + (i * 0.7).cos() * 0.2;
        final normalizedValue = 0.5 + (i / dataPoints * 0.3).sin() * 0.3 + noise * amplitude;
        final y = size.height - (normalizedValue * size.height);
        canvas.drawCircle(Offset(x, y), 3, dotPaint);
      }
    }
  }

  Color _getMetricColorForPaint(String metric) {
    switch (metric) {
      case '温度':
        return AppColors.warning;
      case '电压':
        return AppColors.info;
      case '电流':
        return AppColors.success;
      case '功率':
        return AppColors.primary;
      default:
        return AppColors.text;
    }
  }

  double _getBaseValue(String metric) {
    switch (metric) {
      case '温度':
        return 42.0;
      case '电压':
        return 220.0;
      case '电流':
        return 15.0;
      case '功率':
        return 3.3;
      default:
        return 50.0;
    }
  }

  double _getAmplitude(String metric) {
    switch (metric) {
      case '温度':
        return 0.15;
      case '电压':
        return 0.10;
      case '电流':
        return 0.20;
      case '功率':
        return 0.18;
      default:
        return 0.15;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Health Lifespan Tab in device detail
class DeviceHealthLifespanView extends StatelessWidget {
  const DeviceHealthLifespanView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall health card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '整体健康度',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '78%',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '状态良好',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.subText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          size: 48,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: 0.78,
                    backgroundColor: AppColors.divider,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Expected lifespan
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '预期剩余寿命',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        '240',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '天',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.subText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '预测区间: 200-280 天',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.subText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '预计到期日: 2024-09-07',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.subText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Component health list
          const Text(
            '部件健康详情',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...MockData.components.map((component) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            component['name'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getHealthColor(component['healthIndex'])
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${(component['healthIndex'] * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getHealthColor(component['healthIndex']),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: component['healthIndex'],
                      backgroundColor: AppColors.divider,
                      color: _getHealthColor(component['healthIndex']),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '剩余寿命',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.subText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${component['rul']} 天',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '预测区间',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.subText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${component['rulRange']} 天',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            '查看详情',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          // Maintenance recommendations
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 20,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '维护建议',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildRecommendationItem(
                    '建议在未来30天内安排主轴承维护',
                    Icons.build,
                    AppColors.warning,
                  ),
                  const SizedBox(height: 8),
                  _buildRecommendationItem(
                    '持续监控温度变化趋势',
                    Icons.thermostat,
                    AppColors.info,
                  ),
                  const SizedBox(height: 8),
                  _buildRecommendationItem(
                    '准备相关备件',
                    Icons.inventory,
                    AppColors.success,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String text, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Color _getHealthColor(double healthIndex) {
    if (healthIndex >= 0.8) {
      return AppColors.success;
    } else if (healthIndex >= 0.6) {
      return AppColors.warning;
    } else {
      return AppColors.danger;
    }
  }
}
}
