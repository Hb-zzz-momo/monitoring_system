import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/common_widgets.dart';
import '../mock_data/mock_data.dart';

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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.deviceName),
            const SizedBox(width: 8),
            const StatusDot(isOnline: true, size: 6),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showBottomSheet();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.subText,
          tabs: const [
            Tab(text: '3D视图'),
            Tab(text: '监测总览'),
            Tab(text: '曲线'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DeviceThreeDView(),
          DeviceRealtimeView(),
          DeviceChartsView(),
        ],
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('编辑设备'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('刷新数据'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: AppColors.danger),
                title: Text('删除设备',
                    style: TextStyle(color: AppColors.danger)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// 3D View Tab in device detail
class DeviceThreeDView extends StatelessWidget {
  const DeviceThreeDView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.grey[300],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.view_in_ar,
                    size: 80,
                    color: AppColors.subText,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '3D Model Placeholder',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.subText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          color: AppColors.background,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: KpiCard(
                  title: '温度',
                  value: '${MockData.deviceMetrics['temperature']}',
                  unit: '℃',
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                  title: '功率',
                  value: '${MockData.deviceMetrics['power']}',
                  unit: 'kW',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Realtime Dashboard Tab in device detail
class DeviceRealtimeView extends StatelessWidget {
  const DeviceRealtimeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  title: '温度',
                  value: '${MockData.deviceMetrics['temperature']}',
                  unit: '℃',
                  icon: Icons.thermostat,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                  title: '电压',
                  value: '${MockData.deviceMetrics['voltage']}',
                  unit: 'V',
                  icon: Icons.bolt,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  title: '电流',
                  value: '${MockData.deviceMetrics['current']}',
                  unit: 'A',
                  icon: Icons.flash_on,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KpiCard(
                  title: '功率',
                  value: '${MockData.deviceMetrics['power']}',
                  unit: 'kW',
                  icon: Icons.power,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Charts Tab in device detail
class DeviceChartsView extends StatefulWidget {
  const DeviceChartsView({super.key});

  @override
  State<DeviceChartsView> createState() => _DeviceChartsViewState();
}

class _DeviceChartsViewState extends State<DeviceChartsView> {
  final List<String> _selectedMetrics = ['温度'];
  String _selectedComponent = '整机';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top toolbar
        Container(
          color: AppColors.card,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '指标:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.subText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: ['温度', '电压', '电流', '功率']
                          .map((metric) => _buildMetricChip(metric))
                          .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '部件:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.subText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedComponent,
                    items: ['整机', '主轴承', '电机'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedComponent = newValue;
                        });
                      }
                    },
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Chart area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Main chart
                Container(
                  height: 320,
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
                          size: 60,
                          color: AppColors.subText,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Line Chart Placeholder',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.subText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '显示: ${_selectedMetrics.join(', ')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.subText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Data points table (collapsible)
                Card(
                  child: ExpansionTile(
                    title: const Text(
                      '数据点表',
                      style: TextStyle(fontSize: 14),
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: List.generate(5, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '2024-01-10 ${10 + index}:${30 + index * 5}:00',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.subText,
                                    ),
                                  ),
                                  Text(
                                    '${42.0 + index * 0.5} ℃',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricChip(String metric) {
    final isSelected = _selectedMetrics.contains(metric);
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedMetrics.remove(metric);
          } else {
            _selectedMetrics.add(metric);
          }
        });
      },
      child: StatusChip(
        label: metric,
        isSelected: isSelected,
      ),
    );
  }
}
