import 'package:flutter/material.dart';
import 'dart:math';
import '../../theme/app_theme.dart';
import '../../mock_data/mock_data.dart';
import '../../routes/app_routes.dart';

/// 3D视图 Tab 内容（嵌入 DeviceDetailShell）
class ThreeDDeviceContent extends StatefulWidget {
  final String deviceId;
  final VoidCallback? onViewCharts;

  const ThreeDDeviceContent({
    super.key,
    required this.deviceId,
    this.onViewCharts,
  });

  @override
  State<ThreeDDeviceContent> createState() => _ThreeDDeviceContentState();
}

class _ThreeDDeviceContentState extends State<ThreeDDeviceContent> {
  bool _showDrawer = false;
  Map<String, dynamic>? _selectedComponent;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // 上半区 3D Viewer（约55%）
            Expanded(
              flex: 55,
              child: Container(
                color: const Color(0xFFE8EAED),
                child: Stack(
                  children: [
                    // 3D 功率模块渲染图
                    Center(
                      child: GestureDetector(
                        onTapDown: (details) => _onModuleTap(details, context),
                        child: const SiCModuleWidget(),
                      ),
                    ),
                    // 顶部工具栏
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Row(
                        children: [
                          _buildToolButton(Icons.refresh, '重置'),
                          const SizedBox(width: 8),
                          _buildToolButton(Icons.all_out, '爆炸图'),
                          const SizedBox(width: 8),
                          _buildToolButton(Icons.fullscreen, '全屏'),
                        ],
                      ),
                    ),
                    // 左下角提示
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            const Text('点击模块部件查看详情', style: TextStyle(fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 下半区 KPI + 告警（约45%）
            Expanded(
              flex: 45,
              child: Container(
                color: AppColors.background,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Row 1: 温度、电压
                      Row(
                        children: [
                          Expanded(
                            child: _buildKpiCard('温度', '${MockData.deviceMetrics['temperature']}',
                                '℃', AppColors.warning),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildKpiCard('功率', '${MockData.deviceMetrics['power']}',
                                'kW', AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Row 2: 电流、功率
                      Row(
                        children: [
                          Expanded(
                            child: _buildKpiCard('电流', '${MockData.deviceMetrics['current']}',
                                'A', AppColors.success),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildKpiCard('电压', '${MockData.deviceMetrics['voltage']}',
                                'V', AppColors.info),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Row 3: 最近告警卡（整行，最多2条）
                      _buildRecentAlarmsCard(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        // 右侧抽屉
        if (_showDrawer && _selectedComponent != null) ...[
          // 半透明背景
          GestureDetector(
            onTap: () => setState(() => _showDrawer = false),
            child: Container(color: Colors.black38),
          ),
          // 抽屉面板
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: MediaQuery.of(context).size.width * 0.75,
            child: _buildDrawer(_selectedComponent!),
          ),
        ],
      ],
    );
  }

  void _onModuleTap(TapDownDetails details, BuildContext context) {
    // 模拟点击不同部件
    final components = MockData.components;
    final random = Random();
    final component = components[random.nextInt(components.length)];
    setState(() {
      _showDrawer = true;
      _selectedComponent = component;
    });
  }

  Widget _buildToolButton(IconData icon, String tooltip) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: () {},
        tooltip: tooltip,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, String unit, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 11, color: AppColors.subText)),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(unit, style: TextStyle(fontSize: 11, color: AppColors.subText)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAlarmsCard() {
    final recentAlarms = MockData.alarms.take(2).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, size: 16, color: AppColors.danger),
                const SizedBox(width: 8),
                const Text('最近告警',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${recentAlarms.length}条',
                    style: TextStyle(fontSize: 12, color: AppColors.subText)),
              ],
            ),
            const SizedBox(height: 12),
            ...recentAlarms.map((alarm) {
              return InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.alarmDetail,
                    arguments: {'alarmId': alarm['id']},
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 32,
                        decoration: BoxDecoration(
                          color: alarm['level'] == 'danger'
                              ? AppColors.danger
                              : AppColors.warning,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(alarm['title'],
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text('${alarm['component']} · ${alarm['time']}',
                                style: TextStyle(fontSize: 11, color: AppColors.subText)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 18, color: AppColors.subText),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(Map<String, dynamic> component) {
    final hi = (component['healthIndex'] as double);
    final hiPercent = (hi * 100).toInt();
    final hiColor = hi >= 0.8
        ? AppColors.success
        : (hi >= 0.6 ? AppColors.warning : AppColors.danger);

    return Material(
      elevation: 16,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // 标题：部件名 + 健康等级
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(component['name'],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: hiColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('健康度: $hiPercent%',
                                  style: TextStyle(fontSize: 12, color: hiColor, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _showDrawer = false),
                  ),
                ],
              ),
            ),
            // 内容区域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HI 大条形
                    const Text('HI (健康度)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: hi,
                        backgroundColor: AppColors.divider,
                        color: hiColor,
                        minHeight: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$hiPercent%',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: hiColor)),
                        Text(hi >= 0.8 ? '良好' : (hi >= 0.6 ? '注意' : '警告'),
                            style: TextStyle(fontSize: 12, color: hiColor)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // RUL
                    const Text('RUL (剩余寿命)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${component['rul']}',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text('天', style: TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('预测区间: ${component['rulRange']} 天',
                        style: TextStyle(fontSize: 12, color: AppColors.subText)),
                    const SizedBox(height: 24),
                    // 建议动作
                    const Text('建议动作',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...(component['suggestions'] as List).map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
                              const SizedBox(width: 8),
                              Expanded(child: Text(s, style: const TextStyle(fontSize: 12))),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                    // 相关测点
                    const Text('相关测点',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...(component['metrics'] as List).map((m) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(m['name'], style: const TextStyle(fontSize: 13)),
                              Text('${m['value']} ${m['unit']}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            // 底部按钮
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _showDrawer = false);
                        widget.onViewCharts?.call();
                      },
                      child: const Text('查看曲线'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('创建工单'),
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

/// 自绘 SiC/Si 混合功率模块 3D 渲染图
class SiCModuleWidget extends StatelessWidget {
  const SiCModuleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      height: 220,
      child: CustomPaint(painter: _SiCModulePainter()),
    );
  }
}

class _SiCModulePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 底座阴影
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.08, h * 0.2, w * 0.88, h * 0.7), const Radius.circular(6)),
      shadowPaint,
    );

    // 模块主体（白色壳体）
    final bodyRect = Rect.fromLTWH(w * 0.08, h * 0.15, w * 0.84, h * 0.65);
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF5F5F0), Color(0xFFE8E6E0), Color(0xFFD8D6D0)],
      ).createShader(bodyRect);
    canvas.drawRRect(
        RRect.fromRectAndRadius(bodyRect, const Radius.circular(6)), bodyPaint);

    // 壳体边框
    final borderPaint = Paint()
      ..color = const Color(0xFFB0AEA8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
        RRect.fromRectAndRadius(bodyRect, const Radius.circular(6)), borderPaint);

    // 顶部透明盖（半透明效果）
    final coverRect = Rect.fromLTWH(w * 0.14, h * 0.22, w * 0.72, h * 0.35);
    final coverPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x40FFFFFF), Color(0x20B0D0F0), Color(0x30FFFFFF)],
      ).createShader(coverRect);
    canvas.drawRRect(
        RRect.fromRectAndRadius(coverRect, const Radius.circular(3)), coverPaint);
    final coverBorder = Paint()
      ..color = const Color(0x60909090)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
        RRect.fromRectAndRadius(coverRect, const Radius.circular(3)), coverBorder);

    // 芯片（SiC 和 Si）
    final chipPaint = Paint()..color = const Color(0xFF2D2D3D);
    final goldPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..strokeWidth = 0.8;

    // 左侧芯片组
    for (int i = 0; i < 3; i++) {
      final cx = w * 0.22 + i * w * 0.08;
      final cy = h * 0.32;
      canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: 18, height: 14), chipPaint);
      // 金色引线
      canvas.drawLine(Offset(cx, cy - 7), Offset(cx, cy - 14), goldPaint);
      canvas.drawLine(Offset(cx, cy + 7), Offset(cx, cy + 14), goldPaint);
    }

    // 右侧芯片组
    for (int i = 0; i < 3; i++) {
      final cx = w * 0.58 + i * w * 0.08;
      final cy = h * 0.32;
      canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: 18, height: 14), chipPaint);
      canvas.drawLine(Offset(cx, cy - 7), Offset(cx, cy - 14), goldPaint);
      canvas.drawLine(Offset(cx, cy + 7), Offset(cx, cy + 14), goldPaint);
    }

    // 中间 DBC 基板
    final dbcPaint = Paint()..color = const Color(0xFFC0B8A0);
    canvas.drawRect(
        Rect.fromLTWH(w * 0.16, h * 0.44, w * 0.68, h * 0.1), dbcPaint);

    // 螺丝安装孔（四角）
    final holePaint = Paint()..color = const Color(0xFF606060);
    final holeStroke = Paint()
      ..color = const Color(0xFF808080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final holes = [
      Offset(w * 0.13, h * 0.22),
      Offset(w * 0.87, h * 0.22),
      Offset(w * 0.13, h * 0.72),
      Offset(w * 0.87, h * 0.72),
    ];
    for (final pos in holes) {
      canvas.drawCircle(pos, 8, holePaint);
      canvas.drawCircle(pos, 8, holeStroke);
      canvas.drawCircle(pos, 3, Paint()..color = const Color(0xFF404040));
    }

    // 顶部引脚（电极端子）
    final pinPaint = Paint()..color = const Color(0xFFB0B0B0);
    final pinHighlight = Paint()..color = const Color(0xFFD0D0D0);
    for (int i = 0; i < 4; i++) {
      final px = w * 0.25 + i * w * 0.17;
      final pinRect = Rect.fromLTWH(px - 8, h * 0.02, 16, h * 0.15);
      canvas.drawRRect(
          RRect.fromRectAndRadius(pinRect, const Radius.circular(2)), pinPaint);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(px - 6, h * 0.03, 4, h * 0.13), const Radius.circular(1)),
          pinHighlight);
    }

    // 底部引脚
    for (int i = 0; i < 4; i++) {
      final px = w * 0.25 + i * w * 0.17;
      final pinRect = Rect.fromLTWH(px - 8, h * 0.82, 16, h * 0.15);
      canvas.drawRRect(
          RRect.fromRectAndRadius(pinRect, const Radius.circular(2)), pinPaint);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(px - 6, h * 0.83, 4, h * 0.13), const Radius.circular(1)),
          pinHighlight);
    }

    // 标签文字
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'SiC/Si Power Module',
        style: TextStyle(color: Color(0xFF606060), fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(w * 0.3, h * 0.62));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
