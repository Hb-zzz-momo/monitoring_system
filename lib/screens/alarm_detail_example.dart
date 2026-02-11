import 'package:flutter/material.dart';
import '../widgets/ai_alarm_analysis.dart';

/// Example screen showing how to integrate AI alarm analysis
class AlarmDetailExample extends StatelessWidget {
  const AlarmDetailExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('告警详情'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alarm summary card
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(240, 68, 56, 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '告警',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '部件过温',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const _InfoRow(label: '设备', value: '电机 A'),
                    const _InfoRow(label: '部件', value: '冷却风扇'),
                    const _InfoRow(label: '当前值', value: '85.2°C'),
                    const _InfoRow(label: '阈值', value: '75.0°C'),
                    const _InfoRow(label: '触发时间', value: '2024-02-11 10:30:45'),
                  ],
                ),
              ),
            ),

            // AI Analysis Widget Integration
            const AIAlarmAnalysis(
              alarmType: '过温告警',
              deviceName: '电机 A',
              componentName: '冷却风扇',
              currentValue: 85.2,
              threshold: 75.0,
              historicalData: '过去24小时平均温度: 72°C, 最高: 85.2°C',
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Create work order with AI context
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('创建工单（含 AI 分析）'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.assignment),
                      label: const Text('生成工单'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(39, 99, 255, 1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('标记为已处理')),
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('已处理'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
