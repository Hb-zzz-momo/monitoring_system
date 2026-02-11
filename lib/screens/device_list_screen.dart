import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/common_widgets.dart';
import '../mock_data/mock_data.dart';
import '../routes/app_routes.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  PageState _state = PageState.loading;
  String _selectedFilter = '全部';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _state = PageState.loading;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _state = PageState.content;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredDevices {
    if (_selectedFilter == '全部') {
      return MockData.devices;
    } else if (_selectedFilter == '在线') {
      return MockData.devices.where((d) => d['isOnline'] == true).toList();
    } else if (_selectedFilter == '离线') {
      return MockData.devices.where((d) => d['isOnline'] == false).toList();
    } else {
      return MockData.devices;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.monitor_heart,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        title: const Text('设备'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: StateWidget(
        state: _state,
        onRetry: _loadData,
        emptyMessage: '暂无设备',
        child: Column(
          children: [
            // Filter chips
            Container(
              color: AppColors.card,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('全部'),
                    const SizedBox(width: 8),
                    _buildFilterChip('在线'),
                    const SizedBox(width: 8),
                    _buildFilterChip('离线'),
                    const SizedBox(width: 8),
                    _buildFilterChip('告警中'),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            // Device list
            Expanded(
              child: _filteredDevices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.devices_other,
                            size: 80,
                            color: AppColors.subText,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '暂无设备',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.subText,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('去绑定'),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredDevices.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final device = _filteredDevices[index];
                        return _buildDeviceCard(device);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.mainShell);
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: StatusChip(
        label: label,
        isSelected: isSelected,
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRoutes.deviceDetail,
            arguments: {
              'deviceId': device['id'],
              'deviceName': device['name'],
            },
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  StatusDot(isOnline: device['isOnline']),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      device['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '最后更新: ${device['lastUpdate']}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.subText,
                ),
              ),
              const SizedBox(height: 12),
              // Metrics row
              Row(
                children: [
                  Expanded(
                    child: _buildMetric(
                      '温度',
                      '${device['temperature']}',
                      '℃',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: AppColors.divider,
                  ),
                  Expanded(
                    child: _buildMetric(
                      '功率',
                      '${device['power']}',
                      'kW',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.subText,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.subText,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
