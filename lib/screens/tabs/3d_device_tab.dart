import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../mock_data/mock_data.dart';
import '../../routes/app_routes.dart';

class ThreeDDeviceTab extends StatefulWidget {
  const ThreeDDeviceTab({super.key});

  @override
  State<ThreeDDeviceTab> createState() => _ThreeDDeviceTabState();
}

class _ThreeDDeviceTabState extends State<ThreeDDeviceTab> {
  bool _showDrawer = false;
  Map<String, dynamic>? _selectedComponent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D设备视图'),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 3D Viewer area
              Expanded(
                flex: 55,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[800]!,
                        Colors.grey[600]!,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // 3D placeholder with grid pattern
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 3D cube icon with shadow
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.view_in_ar,
                                size: 100,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              '3D 模型视图',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '拖动旋转 | 滚轮缩放 | 点击部件查看详情',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Simulated clickable components
                            Wrap(
                              spacing: 12,
                              children: [
                                _buildComponentChip('主轴承', Colors.orange),
                                _buildComponentChip('电机', Colors.blue),
                                _buildComponentChip('传动轴', Colors.green),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Grid overlay for 3D feel
                      Positioned.fill(
                        child: CustomPaint(
                          painter: GridPainter(),
                        ),
                      ),
                      // Top toolbar
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Row(
                          children: [
                            _buildToolButton(Icons.refresh, '重置'),
                            const SizedBox(width: 8),
                            _buildToolButton(Icons.explode, '爆炸图'),
                            const SizedBox(width: 8),
                            _buildToolButton(Icons.fullscreen, '全屏'),
                          ],
                        ),
                      ),
                      // Selected component chip
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showDrawer = true;
                              _selectedComponent = MockData.components[0];
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '点击查看部件详情',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // KPI Cards area
              Expanded(
                flex: 45,
                child: Container(
                  color: AppColors.background,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Row 1: Temperature and Voltage
                        Row(
                          children: [
                            Expanded(
                              child: _buildMiniKpiCard(
                                '温度',
                                '${MockData.deviceMetrics['temperature']}',
                                '℃',
                                Icons.thermostat,
                                AppColors.warning,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMiniKpiCard(
                                '电压',
                                '${MockData.deviceMetrics['voltage']}',
                                'V',
                                Icons.bolt,
                                AppColors.info,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Row 2: Current and Power
                        Row(
                          children: [
                            Expanded(
                              child: _buildMiniKpiCard(
                                '电流',
                                '${MockData.deviceMetrics['current']}',
                                'A',
                                Icons.flash_on,
                                AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMiniKpiCard(
                                '功率',
                                '${MockData.deviceMetrics['power']}',
                                'kW',
                                Icons.power,
                                AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Recent alarms card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber,
                                      size: 16,
                                      color: AppColors.danger,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      '最近告警',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...MockData.alarms.take(2).map((alarm) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                        AppRoutes.alarmDetail,
                                        arguments: {'alarmId': alarm['id']},
                                      );
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 3,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: alarm['level'] == 'danger'
                                                  ? AppColors.danger
                                                  : AppColors.warning,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  alarm['title'],
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  alarm['time'],
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: AppColors.subText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            size: 16,
                                            color: AppColors.subText,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Right drawer
          if (_showDrawer && _selectedComponent != null)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showDrawer = false;
                  });
                },
                child: Container(
                  color: Colors.black26,
                  child: GestureDetector(
                    onTap: () {}, // Prevent closing when tapping drawer
                    child: Container(
                      width: 300,
                      color: AppColors.card,
                      child: _buildDrawerContent(_selectedComponent!),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToolButton(IconData icon, String tooltip) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: () {},
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildMiniKpiCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.subText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.subText,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerContent(Map<String, dynamic> component) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(color: AppColors.divider),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      component['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '健康等级: ${(component['healthIndex'] * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _showDrawer = false;
                  });
                },
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Health Index
                const Text(
                  'HI (健康度)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: component['healthIndex'],
                  backgroundColor: AppColors.divider,
                  minHeight: 8,
                ),
                const SizedBox(height: 4),
                Text(
                  '${(component['healthIndex'] * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.subText,
                  ),
                ),
                const SizedBox(height: 24),
                // RUL
                const Text(
                  'RUL (剩余寿命)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${component['rul']}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('天'),
                  ],
                ),
                Text(
                  '预测区间: ${component['rulRange']} 天',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.subText,
                  ),
                ),
                const SizedBox(height: 24),
                // Suggestions
                const Text(
                  '建议动作',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...(component['suggestions'] as List).map((suggestion) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
                // Related metrics
                const Text(
                  '相关测点',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...(component['metrics'] as List).map((metric) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          metric['name'],
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          '${metric['value']} ${metric['unit']}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        // Bottom buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.divider),
            ),
          ),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('查看曲线'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {},
                child: const Text('创建工单'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComponentChip(String label, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showDrawer = true;
          _selectedComponent = MockData.components[0];
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for 3D grid effect
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (int i = 0; i < 10; i++) {
      final x = size.width / 10 * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (int i = 0; i < 10; i++) {
      final y = size.height / 10 * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
}
