import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../mock_data/mock_data.dart';
import '../../components/common_widgets.dart';

class RealtimeTab extends StatefulWidget {
  const RealtimeTab({super.key});

  @override
  State<RealtimeTab> createState() => _RealtimeTabState();
}

class _RealtimeTabState extends State<RealtimeTab> {
  String _selectedTimeRange = '30s';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('实时监测'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Connection status bar
            Container(
              color: AppColors.card,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Connection status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '已连接',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Delay
                      Text(
                        '延迟: ${MockData.deviceMetrics['delay']} ms',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.subText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Time range selector
                  Row(
                    children: [
                      Text(
                        '时间范围:',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.subText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildTimeRangeChip('5s'),
                      const SizedBox(width: 8),
                      _buildTimeRangeChip('30s'),
                      const SizedBox(width: 8),
                      _buildTimeRangeChip('1m'),
                      const SizedBox(width: 8),
                      _buildTimeRangeChip('5m'),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Large KPI card
                  Card(
                    child: Container(
                      height: 140,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.thermostat,
                                size: 16,
                                color: AppColors.subText,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '温度',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.subText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${MockData.deviceMetrics['temperature']}',
                                          style: TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.warning,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 6),
                                          child: Text(
                                            '℃',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: AppColors.subText,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        _buildMiniStat(
                                            '最大', '45.2', '℃'),
                                        const SizedBox(width: 16),
                                        _buildMiniStat(
                                            '最小', '38.5', '℃'),
                                        const SizedBox(width: 16),
                                        _buildMiniStat(
                                            '均值', '42.1', '℃'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Sparkline placeholder
                              Container(
                                width: 100,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    'Sparkline',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.subText,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Grid of KPI cards
                  Row(
                    children: [
                      Expanded(
                        child: KpiCard(
                          title: '电压',
                          value:
                              '${MockData.deviceMetrics['voltage']}',
                          unit: 'V',
                          icon: Icons.bolt,
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: KpiCard(
                          title: '电流',
                          value:
                              '${MockData.deviceMetrics['current']}',
                          unit: 'A',
                          icon: Icons.flash_on,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: KpiCard(
                          title: '功率',
                          value: '${MockData.deviceMetrics['power']}',
                          unit: 'kW',
                          icon: Icons.power,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: KpiCard(
                          title: '电能',
                          value:
                              '${MockData.deviceMetrics['energy']}',
                          unit: 'kWh',
                          icon: Icons.energy_savings_leaf,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Recent events card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '最新事件',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                                      color: _getEventColor(event['type'])
                                          .withOpacity(0.1),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _getEventIcon(event['icon']),
                                      size: 16,
                                      color: _getEventColor(event['type']),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event['text'],
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          event['time'],
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.subText,
                                          ),
                                        ),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeChip(String label) {
    final isSelected = _selectedTimeRange == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTimeRange = label;
        });
      },
      child: StatusChip(
        label: label,
        isSelected: isSelected,
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.subText,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.subText,
              ),
            ),
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
