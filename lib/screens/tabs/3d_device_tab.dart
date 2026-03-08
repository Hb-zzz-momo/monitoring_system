import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../routes/route_args.dart';
import '../../components/common_widgets.dart';
import '../../services/api_service.dart';
import '../../models/alarm_model.dart';
import '../../models/metrics_model.dart';
import '../../models/component_model.dart';
import 'widgets/sic_module_widget.dart';

part 'three_d/cards.dart';
part 'three_d/drawer.dart';

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
  ComponentModel? _selectedComponent;
  PageState _state = PageState.loading;
  MetricsModel _metrics = const MetricsModel(
    temperature: 0.0,
    voltage: 0.0,
    current: 0.0,
    power: 0.0,
  );
  List<ComponentModel> _components = [];
  List<AlarmModel> _alarms = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _state = PageState.loading);
    try {
      final device = await fetchDevice(widget.deviceId);
      final deviceName = device['name']?.toString() ?? '';
      final metrics = await fetchDeviceMetricsModel(deviceId: widget.deviceId);
      final components = await fetchComponentModels(
        deviceId: widget.deviceId,
        deviceName: deviceName,
      );
      final alarms = await fetchAlarmModels(
        deviceId: widget.deviceId,
        deviceName: deviceName,
      );

      if (!mounted) return;
      setState(() {
        _metrics = metrics;
        _components = components;
        _alarms = alarms;
        _state = PageState.content;
      });
    } catch (e) {
      debugPrint('ThreeDDeviceContent._loadData error: $e');
      if (!mounted) return;
      setState(() => _state = PageState.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StateWidget(
      state: _state,
      onRetry: _loadData,
      emptyMessage: '暂无设备数据',
      child: Stack(
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
                            child: _buildKpiCard('温度', '${_metrics.temperature}',
                                '℃', AppColors.warning),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildKpiCard('功率', '${_metrics.power}',
                                'kW', AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Row 2: 电流、功率
                      Row(
                        children: [
                          Expanded(
                            child: _buildKpiCard('电流', '${_metrics.current}',
                                'A', AppColors.success),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildKpiCard('电压', '${_metrics.voltage}',
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
      ),
    );
  }

  void _onModuleTap(TapDownDetails details, BuildContext context) {
    final components = _components;
    if (components.isEmpty) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || renderBox.size.width <= 0) {
      return;
    }

    final localX = details.localPosition.dx.clamp(0, renderBox.size.width);
    final ratio = localX / renderBox.size.width;
    final index = (ratio * components.length).floor().clamp(0, components.length - 1);
    final component = components[index];

    setState(() {
      _showDrawer = true;
      _selectedComponent = component;
    });
  }

  void _showTip(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleToolbarAction(String action) async {
    if (action == '重置') {
      setState(() {
        _showDrawer = false;
        _selectedComponent = null;
      });
      await _loadData();
      _showTip('视图已重置并刷新数据');
      return;
    }
    _showTip('$action 功能已触发，后续可接入真实 3D 引擎动作');
  }

  Future<void> _createWorkOrderFromComponent(ComponentModel component) async {
    final componentName = component.name;
    final matched = _alarms.where((alarm) {
      if (alarm.status != '进行中') return false;
      if (componentName.isEmpty) return true;
      return alarm.component == componentName;
    }).toList();

    AlarmModel? targetAlarm;
    if (matched.isNotEmpty) {
      targetAlarm = matched.first;
    } else {
      for (final alarm in _alarms) {
        if (alarm.status == '进行中') {
          targetAlarm = alarm;
          break;
        }
      }
    }

    if (targetAlarm == null) {
      _showTip('当前没有可创建工单的进行中告警');
      return;
    }

    try {
      final created = await createWorkOrderFromAlarm(targetAlarm.id);
      final workOrderId = created['id']?.toString() ?? '';
      _showTip(workOrderId.isEmpty ? '工单创建成功' : '工单已创建: $workOrderId');
    } catch (e) {
      debugPrint('ThreeDDeviceContent._createWorkOrderFromComponent error: $e');
      _showTip('创建工单失败，请稍后重试');
    }
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
        onPressed: () => _handleToolbarAction(tooltip),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
      ),
    );
  }

}

