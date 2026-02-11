import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../mock_data/mock_data.dart';

/// 曲线 Tab 内容
class ChartsContent extends StatefulWidget {
  final String deviceId;

  const ChartsContent({super.key, required this.deviceId});

  @override
  State<ChartsContent> createState() => _ChartsContentState();
}

class _ChartsContentState extends State<ChartsContent> {
  final Set<String> _selectedMetrics = {'温度'};
  String _selectedComponent = '整机';
  bool _isPaused = false;
  bool _showDataTable = false;

  static const _metrics = ['温度', '电压', '电流', '功率'];
  static const _components = ['整机', '主轴承', '电机', 'IGBT模块'];
  static const _metricUnits = {'温度': '℃', '电压': 'V', '电流': 'A', '功率': 'kW'};
  static const _metricColors = {
    '温度': Color(0xFFF59E0B),
    '电压': Color(0xFF2E90FA),
    '电流': Color(0xFF12B76A),
    '功率': Color(0xFF2763FF),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 顶部工具栏（固定）
        Container(
          color: AppColors.card,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 指标选择 Chip 组
              Row(
                children: [
                  Text('指标:', style: TextStyle(fontSize: 12, color: AppColors.subText)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _metrics.map((m) {
                          final selected = _selectedMetrics.contains(m);
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (selected && _selectedMetrics.length > 1) {
                                    _selectedMetrics.remove(m);
                                  } else {
                                    _selectedMetrics.add(m);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? _metricColors[m]!.withOpacity(0.15)
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: selected ? _metricColors[m]! : AppColors.divider,
                                  ),
                                ),
                                child: Text(m,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: selected ? _metricColors[m]! : AppColors.text,
                                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                    )),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 部件选择 + 控制按钮
              Row(
                children: [
                  Text('部件:', style: TextStyle(fontSize: 12, color: AppColors.subText)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedComponent,
                        isDense: true,
                        style: TextStyle(fontSize: 12, color: AppColors.text),
                        items: _components.map((c) {
                          return DropdownMenuItem(value: c, child: Text(c));
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedComponent = v!),
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause, size: 20),
                    onPressed: () => setState(() => _isPaused = !_isPaused),
                    tooltip: _isPaused ? '继续' : '暂停',
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                  IconButton(
                    icon: const Icon(Icons.zoom_out_map, size: 20),
                    onPressed: () {},
                    tooltip: '重置缩放',
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo_camera_outlined, size: 20),
                    onPressed: () {},
                    tooltip: '截图',
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // 主图表区
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 主折线图  
                Container(
                  height: 320,
                  padding: const EdgeInsets.all(16),
                  child: _buildChart(320 - 32),
                ),
                // 图例
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _selectedMetrics.map((m) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 3,
                              color: _metricColors[m],
                            ),
                            const SizedBox(width: 4),
                            Text('$m (${_metricUnits[m]})',
                                style: TextStyle(fontSize: 11, color: AppColors.subText)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                // 数据点表（可折叠）
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4),
                    ],
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => setState(() => _showDataTable = !_showDataTable),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              const Text('数据点表',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Icon(
                                _showDataTable ? Icons.expand_less : Icons.expand_more,
                                color: AppColors.subText,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_showDataTable) _buildDataTable(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChart(double height) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _LineChartPainter(
        selectedMetrics: _selectedMetrics.toList(),
        metricColors: _metricColors,
      ),
    );
  }

  Widget _buildDataTable() {
    final metric = _selectedMetrics.first;
    final data = MockData.generateChartData(metric, 20);
    final unit = _metricUnits[metric] ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          // 表头
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Text('#',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.subText))),
                Expanded(
                    flex: 3,
                    child: Text('时间',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.subText))),
                Expanded(
                    flex: 2,
                    child: Text('$metric ($unit)',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.subText),
                        textAlign: TextAlign.right)),
              ],
            ),
          ),
          // 数据行
          ...data.asMap().entries.take(20).map((entry) {
            final i = entry.key;
            final d = entry.value;
            final now = DateTime.now().subtract(Duration(seconds: (20 - i) * 5));
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.5))),
              ),
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Text('${i + 1}', style: TextStyle(fontSize: 11, color: AppColors.subText))),
                  Expanded(
                      flex: 3,
                      child: Text(
                          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 11))),
                  Expanded(
                      flex: 2,
                      child: Text('${d['y']}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.right)),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// 折线图绘制器
class _LineChartPainter extends CustomPainter {
  final List<String> selectedMetrics;
  final Map<String, Color> metricColors;

  _LineChartPainter({required this.selectedMetrics, required this.metricColors});

  @override
  void paint(Canvas canvas, Size size) {
    final leftMargin = 50.0;
    final bottomMargin = 30.0;
    final rightMargin = 16.0;
    final topMargin = 16.0;

    final chartWidth = size.width - leftMargin - rightMargin;
    final chartHeight = size.height - topMargin - bottomMargin;

    // 绘制网格背景
    final gridPaint = Paint()
      ..color = const Color(0xFFE4E7EC)
      ..strokeWidth = 0.5;

    // 水平网格线
    for (int i = 0; i <= 5; i++) {
      final y = topMargin + (i / 5) * chartHeight;
      canvas.drawLine(Offset(leftMargin, y), Offset(leftMargin + chartWidth, y), gridPaint);
    }

    // 垂直网格线
    for (int i = 0; i <= 5; i++) {
      final x = leftMargin + (i / 5) * chartWidth;
      canvas.drawLine(Offset(x, topMargin), Offset(x, topMargin + chartHeight), gridPaint);
    }

    // 绘制坐标轴
    final axisPaint = Paint()
      ..color = const Color(0xFFB0B8C4)
      ..strokeWidth = 1;
    canvas.drawLine(
        Offset(leftMargin, topMargin), Offset(leftMargin, topMargin + chartHeight), axisPaint);
    canvas.drawLine(Offset(leftMargin, topMargin + chartHeight),
        Offset(leftMargin + chartWidth, topMargin + chartHeight), axisPaint);

    // 对每个选中的指标绘制折线
    for (final metric in selectedMetrics) {
      final data = MockData.generateChartData(metric, 60);
      if (data.isEmpty) continue;

      final values = data.map((d) => d['y']!).toList();
      final minV = values.reduce((a, b) => a < b ? a : b) - 2;
      final maxV = values.reduce((a, b) => a > b ? a : b) + 2;
      final range = maxV - minV;

      final color = metricColors[metric] ?? Colors.blue;

      // 绘制面积填充
      final fillPath = Path();
      for (int i = 0; i < values.length; i++) {
        final x = leftMargin + (i / (values.length - 1)) * chartWidth;
        final y = range == 0
            ? topMargin + chartHeight / 2
            : topMargin + chartHeight - ((values[i] - minV) / range) * chartHeight;
        if (i == 0) {
          fillPath.moveTo(x, topMargin + chartHeight);
          fillPath.lineTo(x, y);
        } else {
          fillPath.lineTo(x, y);
        }
      }
      fillPath.lineTo(leftMargin + chartWidth, topMargin + chartHeight);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.2), color.withOpacity(0.02)],
        ).createShader(Rect.fromLTWH(leftMargin, topMargin, chartWidth, chartHeight));
      canvas.drawPath(fillPath, fillPaint);

      // 绘制折线
      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final linePath = Path();
      for (int i = 0; i < values.length; i++) {
        final x = leftMargin + (i / (values.length - 1)) * chartWidth;
        final y = range == 0
            ? topMargin + chartHeight / 2
            : topMargin + chartHeight - ((values[i] - minV) / range) * chartHeight;
        if (i == 0) {
          linePath.moveTo(x, y);
        } else {
          linePath.lineTo(x, y);
        }
      }
      canvas.drawPath(linePath, linePaint);

      // Y 轴刻度标签
      if (metric == selectedMetrics.first) {
        for (int i = 0; i <= 5; i++) {
          final val = minV + (5 - i) / 5 * range;
          final y = topMargin + (i / 5) * chartHeight;
          final tp = TextPainter(
            text: TextSpan(
              text: val.toStringAsFixed(0),
              style: const TextStyle(color: Color(0xFF667085), fontSize: 10),
            ),
            textDirection: TextDirection.ltr,
          );
          tp.layout();
          tp.paint(canvas, Offset(leftMargin - tp.width - 6, y - tp.height / 2));
        }
      }
    }

    // X 轴时间标签
    for (int i = 0; i <= 5; i++) {
      final x = leftMargin + (i / 5) * chartWidth;
      final seconds = ((5 - i) * 60).toInt();
      final label = seconds == 0 ? '现在' : '${seconds}s前';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(color: Color(0xFF667085), fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, topMargin + chartHeight + 8));
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.selectedMetrics != selectedMetrics;
  }
}
