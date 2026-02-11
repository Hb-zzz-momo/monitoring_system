import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
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
            onSelected: (value) {},
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
