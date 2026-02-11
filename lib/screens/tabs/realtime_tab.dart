import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../mock_data/mock_data.dart';
import '../../components/common_widgets.dart';

/// 监测总览 Tab 内容（嵌入 DeviceDetailShell）
class RealtimeContent extends StatefulWidget {
  final String deviceId;

  const RealtimeContent({super.key, required this.deviceId});

  @override
  State<RealtimeContent> createState() => _RealtimeContentState();
}

class _RealtimeContentState extends State<RealtimeContent> {
  String _selectedTimeRange = '30s';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 顶部状态条（固定）
        Container(
          color: AppColors.card,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Row(
                children: [
                  // 连接状态
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text('已连接',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('延迟: ${MockData.deviceMetrics['delay']} ms',
                      style: TextStyle(fontSize: 12, color: AppColors.subText)),
                ],
              ),
              const SizedBox(height: 10),
              // 时间范围选择器
              Row(
                children: [
                  Text('时间范围:', style: TextStyle(fontSize: 12, color: AppColors.subText)),
                  const SizedBox(width: 8),
                  for (final r in ['5s', '30s', '1m', '5m']) ...[
                    InkWell(
                      onTap: () => setState(() => _selectedTimeRange = r),
                      child: StatusChip(label: r, isSelected: _selectedTimeRange == r),
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // 主体可滚动
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // KPI 大卡（温度）
                _buildBigKpiCard(),
                const SizedBox(height: 12),
                // KPI 网格（2列）
                Row(
                  children: [
                    Expanded(
                      child: _buildGridKpiCard('电压', '${MockData.deviceMetrics['voltage']}',
                          'V', Icons.bolt, AppColors.info),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGridKpiCard('电流', '${MockData.deviceMetrics['current']}',
                          'A', Icons.flash_on, AppColors.success),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildGridKpiCard('功率', '${MockData.deviceMetrics['power']}',
                          'kW', Icons.power, AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGridKpiCard('电能', '${MockData.deviceMetrics['energy']}',
                          'kWh', Icons.energy_savings_leaf, AppColors.warning),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 最新事件卡
                _buildEventsCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBigKpiCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.thermostat, size: 16, color: AppColors.subText),
                const SizedBox(width: 6),
                Text('温度', style: TextStyle(fontSize: 12, color: AppColors.subText)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 左：大数字 + 最大最小均值
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${MockData.deviceMetrics['temperature']}',
                              style: TextStyle(
                                  fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.warning)),
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text('℃',
                                style: TextStyle(fontSize: 16, color: AppColors.subText)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildMiniStat('最大', '45.2', '℃'),
                          const SizedBox(width: 16),
                          _buildMiniStat('最小', '38.5', '℃'),
                          const SizedBox(width: 16),
                          _buildMiniStat('均值', '42.1', '℃'),
                        ],
                      ),
                    ],
                  ),
                ),
                // 右：迷你趋势线占位
                Container(
                  width: 100,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomPaint(painter: _SparklinePainter()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridKpiCard(
      String title, String value, String unit, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.subText),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(title,
                      style: TextStyle(fontSize: 12, color: AppColors.subText),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(value,
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold, color: color),
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(unit,
                      style: TextStyle(fontSize: 12, color: AppColors.subText)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('最新事件', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...MockData.realtimeEvents.map((event) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getEventColor(event['type']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_getEventIcon(event['icon']),
                          size: 16, color: _getEventColor(event['type'])),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event['text'],
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Text(event['time'],
                              style: TextStyle(fontSize: 10, color: AppColors.subText)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.subText)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text(unit, style: TextStyle(fontSize: 10, color: AppColors.subText)),
          ],
        ),
      ],
    );
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'alarm':
        return AppColors.danger;
      case 'status':
        return AppColors.info;
      case 'workorder':
        return AppColors.warning;
      default:
        return AppColors.subText;
    }
  }

  IconData _getEventIcon(String icon) {
    switch (icon) {
      case 'warning':
        return Icons.warning_amber;
      case 'info':
        return Icons.info_outline;
      case 'work':
        return Icons.work_outline;
      default:
        return Icons.circle;
    }
  }
}

/// 迷你趋势线绘制
class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final data = MockData.generateChartData('温度', 20);
    if (data.isEmpty) return;

    final values = data.map((d) => d['y']!).toList();
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = maxV - minV;

    final paint = Paint()
      ..color = AppColors.warning
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final y = range == 0 ? size.height / 2 : size.height - ((values[i] - minV) / range) * size.height * 0.8 - size.height * 0.1;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
