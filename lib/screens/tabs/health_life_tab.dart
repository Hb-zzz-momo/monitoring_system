import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../mock_data/mock_data.dart';

/// 健康寿命 Tab 内容
class HealthLifeContent extends StatelessWidget {
  final String deviceId;

  const HealthLifeContent({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final data = MockData.healthData;
    final hi = (data['overallHI'] as double);
    final hiPercent = (hi * 100).toInt();
    final hiColor = hi >= 0.8
        ? AppColors.success
        : (hi >= 0.6 ? AppColors.warning : AppColors.danger);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 设备整体健康概览卡
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('设备健康概览',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  // HI 大环形指示
                  Center(
                    child: SizedBox(
                      width: 160,
                      height: 160,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: CircularProgressIndicator(
                              value: hi,
                              strokeWidth: 14,
                              backgroundColor: AppColors.divider,
                              color: hiColor,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('$hiPercent%',
                                  style: TextStyle(
                                      fontSize: 36, fontWeight: FontWeight.bold, color: hiColor)),
                              const SizedBox(height: 4),
                              Text('健康指数',
                                  style: TextStyle(fontSize: 12, color: AppColors.subText)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // RUL 信息
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.schedule, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('剩余使用寿命 (RUL)',
                                  style: TextStyle(fontSize: 12, color: AppColors.subText)),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${data['overallRUL']}',
                                      style: const TextStyle(
                                          fontSize: 28, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 4),
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 4),
                                    child: Text('天', style: TextStyle(fontSize: 14)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('预测区间: ${data['rulRange']} 天',
                                  style: TextStyle(fontSize: 12, color: AppColors.subText)),
                            ],
                          ),
                        ),
                        // 趋势图标
                        Column(
                          children: [
                            Icon(
                              data['trend'] == 'declining'
                                  ? Icons.trending_down
                                  : (data['trend'] == 'improving'
                                      ? Icons.trending_up
                                      : Icons.trending_flat),
                              color: data['trend'] == 'declining'
                                  ? AppColors.danger
                                  : AppColors.success,
                              size: 28,
                            ),
                            Text(
                              data['trend'] == 'declining'
                                  ? '下降趋势'
                                  : (data['trend'] == 'improving' ? '上升趋势' : '平稳'),
                              style: TextStyle(fontSize: 10, color: AppColors.subText),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 健康预测曲线
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('健康度预测趋势',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: CustomPaint(
                      size: const Size(double.infinity, 180),
                      painter: _HealthTrendPainter(
                        predictions: (data['predictions'] as List).cast<Map<String, dynamic>>(),
                        currentHI: hi,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 部件健康列表
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('部件健康状态',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...(data['components'] as List).map((comp) {
                    final compHi = (comp['hi'] as double);
                    final compColor = compHi >= 0.8
                        ? AppColors.success
                        : (compHi >= 0.6 ? AppColors.warning : AppColors.danger);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: compColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(comp['name'],
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                              ),
                              Text('${(compHi * 100).toInt()}%',
                                  style: TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.bold, color: compColor)),
                              const SizedBox(width: 16),
                              Text('RUL: ${comp['rul']}天',
                                  style: TextStyle(fontSize: 11, color: AppColors.subText)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: compHi,
                              backgroundColor: AppColors.divider,
                              color: compColor,
                              minHeight: 6,
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
          const SizedBox(height: 16),
          // 维护建议
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, size: 18, color: AppColors.warning),
                      const SizedBox(width: 8),
                      const Text('维护建议',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...(data['suggestions'] as List).asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text('${entry.key + 1}',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(entry.value as String,
                                style: const TextStyle(fontSize: 13)),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// 健康趋势预测绘制器
class _HealthTrendPainter extends CustomPainter {
  final List<Map<String, dynamic>> predictions;
  final double currentHI;

  _HealthTrendPainter({required this.predictions, required this.currentHI});

  @override
  void paint(Canvas canvas, Size size) {
    if (predictions.isEmpty) return;

    final leftMargin = 40.0;
    final bottomMargin = 24.0;
    final topMargin = 8.0;
    final rightMargin = 16.0;

    final chartW = size.width - leftMargin - rightMargin;
    final chartH = size.height - topMargin - bottomMargin;

    // 网格
    final gridPaint = Paint()
      ..color = const Color(0xFFE4E7EC)
      ..strokeWidth = 0.5;
    for (int i = 0; i <= 4; i++) {
      final y = topMargin + (i / 4) * chartH;
      canvas.drawLine(Offset(leftMargin, y), Offset(leftMargin + chartW, y), gridPaint);
    }

    // Y 轴标签 (0%-100%)
    for (int i = 0; i <= 4; i++) {
      final val = 100 - i * 25;
      final y = topMargin + (i / 4) * chartH;
      final tp = TextPainter(
        text: TextSpan(
          text: '$val%',
          style: const TextStyle(color: Color(0xFF667085), fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(leftMargin - tp.width - 4, y - tp.height / 2));
    }

    // 警戒线 60%
    final warnY = topMargin + chartH * 0.4; // 100-60=40 -> 40/100
    final warnPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final dashPath = Path();
    for (double x = leftMargin; x < leftMargin + chartW; x += 8) {
      dashPath.moveTo(x, warnY);
      dashPath.lineTo(x + 4, warnY);
    }
    canvas.drawPath(dashPath, warnPaint);

    // 数据点：当前 + 预测
    final allPoints = <Map<String, dynamic>>[
      {'date': '现在', 'hi': currentHI},
      ...predictions,
    ];

    // 绘制趋势线
    final linePaint = Paint()
      ..color = const Color(0xFF2763FF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPath = Path();
    final linePath = Path();

    for (int i = 0; i < allPoints.length; i++) {
      final x = leftMargin + (i / (allPoints.length - 1)) * chartW;
      final hi = (allPoints[i]['hi'] as double);
      final y = topMargin + chartH * (1 - hi);

      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, topMargin + chartH);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(leftMargin + chartW, topMargin + chartH);
    fillPath.close();

    // 填充
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF2763FF).withOpacity(0.15),
          const Color(0xFF2763FF).withOpacity(0.02),
        ],
      ).createShader(Rect.fromLTWH(leftMargin, topMargin, chartW, chartH));
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    // 数据点圆圈
    for (int i = 0; i < allPoints.length; i++) {
      final x = leftMargin + (i / (allPoints.length - 1)) * chartW;
      final hi = (allPoints[i]['hi'] as double);
      final y = topMargin + chartH * (1 - hi);
      final dotColor = hi >= 0.6 ? const Color(0xFF2763FF) : const Color(0xFFF04438);

      canvas.drawCircle(Offset(x, y), 4, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = dotColor);

      // X 轴标签
      final tp = TextPainter(
        text: TextSpan(
          text: allPoints[i]['date'] as String,
          style: const TextStyle(color: Color(0xFF667085), fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, topMargin + chartH + 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
