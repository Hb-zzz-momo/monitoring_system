import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'tabs/3d_device_tab.dart';
import 'tabs/realtime_tab.dart';
import 'tabs/charts_tab.dart';
import 'tabs/health_life_tab.dart';

class DeviceDetailShell extends StatefulWidget {
  final String deviceId;
  final String deviceName;

  const DeviceDetailShell({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  State<DeviceDetailShell> createState() => _DeviceDetailShellState();
}

class _DeviceDetailShellState extends State<DeviceDetailShell>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _switchToChartsTab({String? metric}) {
    _tabController.animateTo(2);
  }

  Future<void> _handleMenuAction(String value) async {
    switch (value) {
      case 'info':
        await _showDeviceInfo();
        break;
      case 'unbind':
        await _confirmUnbind();
        break;
      case 'export':
        await _exportDataPreview();
        break;
    }
  }

  Future<void> _showDeviceInfo() async {
    try {
      final device = await fetchDevice(widget.deviceId);
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('设备信息'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow('设备ID', device['id']?.toString() ?? '-'),
                const SizedBox(height: 8),
                _infoRow('名称', device['name']?.toString() ?? '-'),
                const SizedBox(height: 8),
                _infoRow('部件', device['component']?.toString() ?? '-'),
                const SizedBox(height: 8),
                _infoRow('状态', (device['isOnline'] == true) ? '在线' : '离线'),
                const SizedBox(height: 8),
                _infoRow('健康值', device['healthIndex']?.toString() ?? '-'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('关闭'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('加载设备信息失败，请稍后重试')),
      );
    }
  }

  Future<void> _confirmUnbind() async {
    final shouldUnbind = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('解绑设备'),
              content: const Text('确认将该设备标记为离线并解绑吗？'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('确认解绑'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldUnbind) return;

    try {
      await updateDevice(widget.deviceId, {'isOnline': false});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('设备已解绑（已标记离线）')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('解绑失败：当前账号可能无权限')),
      );
    }
  }

  Future<void> _exportDataPreview() async {
    try {
      final points = await fetchMetricHistory(
        'temperature',
        points: 30,
        deviceId: widget.deviceId,
      );
      if (!mounted) return;

      final csv = StringBuffer('index,temperature\n');
      for (var i = 0; i < points.length; i++) {
        csv.writeln('${i + 1},${points[i]['y']?.toStringAsFixed(3) ?? ''}');
      }

      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('导出数据预览（CSV）'),
            content: SingleChildScrollView(
              child: SelectableText(csv.toString()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('关闭'),
              ),
            ],
          );
        },
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('导出失败，请稍后重试')),
      );
    }
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            '$label:',
            style: TextStyle(color: AppColors.subText),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.deviceName),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(18, 183, 106, 1),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'info', child: Text('设备信息')),
              const PopupMenuItem(value: 'unbind', child: Text('解绑设备')),
              const PopupMenuItem(value: 'export', child: Text('导出数据')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.subText,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: '3D视图'),
            Tab(text: '监测总览'),
            Tab(text: '曲线'),
            Tab(text: '健康寿命'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ThreeDDeviceContent(
            deviceId: widget.deviceId,
            onViewCharts: _switchToChartsTab,
          ),
          RealtimeContent(deviceId: widget.deviceId),
          ChartsContent(deviceId: widget.deviceId),
          HealthLifeContent(deviceId: widget.deviceId),
        ],
      ),
    );
  }
}
