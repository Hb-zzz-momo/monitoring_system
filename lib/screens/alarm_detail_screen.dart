import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../mock_data/mock_data.dart';

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
                        // Small chart - 告警前后10s曲线
                        Container(
                          height: 180,
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
                                Text(
                                  '告警前后10s曲线',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.subText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: CustomPaint(
                                    size: const Size(double.infinity, double.infinity),
                                    painter: _AlarmChartPainter(
                                      alarmValue: (alarm['currentValue'] as num).toDouble(),
                                      threshold: (alarm['threshold'] as num).toDouble(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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

/// 告警前后10s曲线绘制器
class _AlarmChartPainter extends CustomPainter {
  final double alarmValue;
  final double threshold;

  _AlarmChartPainter({required this.alarmValue, required this.threshold});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final random = Random(42);

    // 生成虚拟数据：告警前10秒温度逐渐上升，告警后10秒波动
    final points = <Offset>[];
    final totalPoints = 40;
    final baseTemp = threshold - 8;

    for (int i = 0; i < totalPoints; i++) {
      final t = i / (totalPoints - 1);
      final x = t * w;
      double temp;
      if (i < totalPoints ~/ 2) {
        // 告警前：逐渐上升
        final progress = i / (totalPoints / 2);
        temp = baseTemp + progress * (alarmValue - baseTemp) +
            (random.nextDouble() - 0.5) * 1.5;
      } else {
        // 告警后：在告警值附近波动
        temp = alarmValue + (random.nextDouble() - 0.5) * 3;
      }
      final minTemp = baseTemp - 3;
      final maxTemp = alarmValue + 5;
      final y = h - ((temp - minTemp) / (maxTemp - minTemp)) * h;
      points.add(Offset(x, y.clamp(0, h)));
    }

    // 绘制阈值虚线
    final thresholdY = h - ((threshold - (baseTemp - 3)) / (alarmValue + 5 - (baseTemp - 3))) * h;
    final dashPaint = Paint()
      ..color = const Color(0xFFF04438)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final dashPath = Path();
    for (double dx = 0; dx < w; dx += 8) {
      dashPath.moveTo(dx, thresholdY);
      dashPath.lineTo(dx + 4, thresholdY);
    }
    canvas.drawPath(dashPath, dashPaint);

    // 阈值标签
    final tp = TextPainter(
      text: TextSpan(
        text: '阈值 ${threshold.toStringAsFixed(0)}',
        style: const TextStyle(color: Color(0xFFF04438), fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(w - tp.width - 2, thresholdY - tp.height - 2));

    // 绘制告警时刻竖线
    final alertX = w / 2;
    final alertLinePaint = Paint()
      ..color = const Color(0xFFF04438).withValues(alpha: 0.3)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(alertX, 0), Offset(alertX, h), alertLinePaint);

    // 绘制填充区域
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, h);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, h);
    fillPath.close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFF59E0B).withValues(alpha: 0.2),
          const Color(0xFFF59E0B).withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(fillPath, fillPaint);

    // 绘制曲线
    final linePaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final linePath = Path();
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        linePath.moveTo(points[i].dx, points[i].dy);
      } else {
        linePath.lineTo(points[i].dx, points[i].dy);
      }
    }
    canvas.drawPath(linePath, linePaint);

    // X轴标签
    for (final label in ['-10s', '-5s', '告警', '+5s', '+10s']) {
      final idx = ['-10s', '-5s', '告警', '+5s', '+10s'].indexOf(label);
      final lx = (idx / 4) * w;
      final ltp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: label == '告警' ? const Color(0xFFF04438) : const Color(0xFF667085),
            fontSize: 9,
            fontWeight: label == '告警' ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      ltp.layout();
      ltp.paint(canvas, Offset(lx - ltp.width / 2, h - ltp.height));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
