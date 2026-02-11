import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../mock_data/mock_data.dart';
import '../widgets/ai_alarm_analysis.dart';

class AlarmDetailScreen extends StatelessWidget {
  final String alarmId;

  const AlarmDetailScreen({super.key, required this.alarmId});

  @override
  Widget build(BuildContext context) {
    final alarm = MockData.alarms.firstWhere(
      (a) => a['id'] == alarmId,
      orElse: () => MockData.alarms.first,
    );

    final color =
        alarm['level'] == 'danger' ? AppColors.danger : AppColors.warning;

    return Scaffold(
      appBar: AppBar(
        title: const Text('告警详情'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary card
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  alarm['title'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  alarm['level'] == 'danger'
                                      ? '告警'
                                      : '预警',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('设备', alarm['device']),
                          const SizedBox(height: 8),
                          _buildInfoRow('部件', alarm['component']),
                          const SizedBox(height: 8),
                          _buildInfoRow('触发时间', alarm['time']),
                          const SizedBox(height: 8),
                          _buildInfoRow('当前值',
                              '${alarm['currentValue']} (阈值: ${alarm['threshold']})'),
                        ],
                      ),
                    ),
                  ),
                  // Evidence section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '证据条',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildEvidenceItem(
                                  '温度超过阈值',
                                  0.92,
                                  Icons.thermostat,
                                ),
                                const SizedBox(height: 12),
                                _buildEvidenceItem(
                                  '持续时间超过10分钟',
                                  0.85,
                                  Icons.access_time,
                                ),
                                const SizedBox(height: 12),
                                _buildEvidenceItem(
                                  '温度上升趋势明显',
                                  0.78,
                                  Icons.trending_up,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Small chart
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.show_chart,
                                  size: 40,
                                  color: AppColors.subText,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '告警前后10s曲线',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.subText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // AI Analysis Widget
                        AIAlarmAnalysis(
                          alarmType: alarm['title'],
                          deviceName: alarm['device'],
                          componentName: alarm['component'],
                          currentValue: double.tryParse(
                            alarm['currentValue'].toString().replaceAll(RegExp(r'[^0-9.]'), ''),
                          ) ?? 0.0,
                          threshold: double.tryParse(
                            alarm['threshold'].toString().replaceAll(RegExp(r'[^0-9.]'), ''),
                          ) ?? 0.0,
                          historicalData: '过去24小时数据趋势',
                        ),
                        const SizedBox(height: 16),
                        // Suggestions section
                        const Text(
                          '建议动作',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildSuggestionItem(
                                    '立即检查主轴承温度'),
                                _buildSuggestionItem('检查润滑油是否充足'),
                                _buildSuggestionItem(
                                    '降低设备运行负载'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Parts section
                        const Text(
                          '建议更换件',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildPartCard('主轴承', 'NSK-6308'),
                              const SizedBox(width: 12),
                              _buildPartCard('润滑油', 'Shell-T68'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('标记已处理'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('生成工单'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.subText,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEvidenceItem(String text, double confidence, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.warning,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: confidence,
                      backgroundColor: AppColors.divider,
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(confidence * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.subText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionItem(String text) {
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
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartCard(String name, String model) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            model,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.subText,
            ),
          ),
        ],
      ),
    );
  }
}
