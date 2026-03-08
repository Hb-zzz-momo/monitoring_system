import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/common_widgets.dart';
import '../routes/app_routes.dart';
import '../routes/route_args.dart';
import '../services/api_service.dart';
import '../models/device_model.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  PageState _state = PageState.loading;
  String _selectedFilter = '全部';
  String _searchQuery = '';
  List<DeviceModel> _devices = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _state = PageState.loading);
    try {
      final devices = await fetchDeviceModels();
      if (!mounted) return;
      setState(() {
        _devices = devices;
        _state = devices.isEmpty ? PageState.empty : PageState.content;
      });
    } catch (e) {
      debugPrint('DeviceListScreen._loadData error: $e');
      if (!mounted) return;
      setState(() => _state = PageState.error);
    }
  }

  List<DeviceModel> get _filteredDevices {
    final baseList = _devices.where((d) {
      if (_selectedFilter == '在线') {
        return d.isOnline;
      }
      if (_selectedFilter == '离线') {
        return !d.isOnline;
      }
      if (_selectedFilter == '告警中') {
        return d.healthIndex < 0.7;
      }
      return true;
    });

    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return baseList.toList();
    }

    return baseList.where((d) {
      return d.id.toLowerCase().contains(query) ||
          d.name.toLowerCase().contains(query) ||
          d.type.toLowerCase().contains(query) ||
          d.location.toLowerCase().contains(query);
    }).toList();
  }

  void _showScanDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.qr_code_scanner, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('扫码绑定设备'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code, size: 80, color: AppColors.subText),
                  const SizedBox(height: 12),
                  Text(
                    '请将设备二维码放入框内',
                    style: TextStyle(fontSize: 12, color: AppColors.subText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '扫描设备上的二维码完成绑定',
              style: TextStyle(fontSize: 14, color: AppColors.subText),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showManualBindDialog();
            },
            child: const Text('手动输入编号'),
          ),
        ],
      ),
    );
  }

  Future<void> _showManualBindDialog() async {
    final controller = TextEditingController();
    final deviceCode = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('手动输入设备编号'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '例如：DEV-001',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (!mounted || deviceCode == null || deviceCode.isEmpty) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已记录设备编号: $deviceCode，可继续完善绑定流程')),
    );
  }

  Future<void> _showSearchDialog() async {
    final controller = TextEditingController(text: _searchQuery);
    final query = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索设备'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入设备名 / ID / 部件',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(''),
            child: const Text('清空'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('应用'),
          ),
        ],
      ),
    );

    if (query == null || !mounted) return;
    setState(() => _searchQuery = query);
  }

  Future<void> _showAdvancedFilterDialog() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['全部', '在线', '离线', '告警中'].map((option) {
            return ListTile(
              leading: Icon(
                _selectedFilter == option
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: _selectedFilter == option ? AppColors.primary : AppColors.subText,
              ),
              title: Text(option),
              onTap: () => Navigator.of(context).pop(option),
            );
          }).toList(),
        ),
      ),
    );

    if (selected == null || !mounted) return;
    setState(() => _selectedFilter = selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.monitor_heart, color: Colors.white, size: 24),
          ),
        ),
        title: const Text('设备'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showAdvancedFilterDialog,
          ),
        ],
      ),
      body: StateWidget(
        state: _state,
        onRetry: _loadData,
        emptyMessage: '暂无设备',
        child: Column(
          children: [
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
            Expanded(
              child: _filteredDevices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.devices_other, size: 80, color: AppColors.subText),
                          const SizedBox(height: 16),
                          Text('暂无设备', style: TextStyle(fontSize: 16, color: AppColors.subText)),
                          const SizedBox(height: 24),
                          ElevatedButton(onPressed: _showScanDialog, child: const Text('去绑定')),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredDevices.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _buildDeviceCard(_filteredDevices[index]),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showScanDialog,
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return InkWell(
      onTap: () => setState(() => _selectedFilter = label),
      child: StatusChip(label: label, isSelected: _selectedFilter == label),
    );
  }

  Widget _buildDeviceCard(DeviceModel device) {
    final hi = device.healthIndex;
    final hiPercent = (hi * 100).toInt();
    final hiColor = hi >= 0.8 ? AppColors.success : (hi >= 0.6 ? AppColors.warning : AppColors.danger);

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRoutes.deviceDetail,
            arguments: DeviceDetailArgs(
              deviceId: device.id,
              deviceName: device.name,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StatusDot(isOnline: device.isOnline),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(device.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 4),
              Text('最后更新: ${device.lastSeen ?? '-'}',
                  style: TextStyle(fontSize: 12, color: AppColors.subText)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildMetric('温度', device.temperature > 0 ? '${device.temperature}' : '-', '℃')),
                  Container(width: 1, height: 32, color: AppColors.divider),
                  Expanded(child: _buildMetric('功率', device.power > 0 ? '${device.power}' : '-', 'kW')),
                  Container(width: 1, height: 32, color: AppColors.divider),
                  Expanded(
                    child: Column(
                      children: [
                        Text('健康度', style: TextStyle(fontSize: 12, color: AppColors.subText)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(color: hiColor, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 4),
                            Text('$hiPercent%',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold, color: hiColor)),
                          ],
                        ),
                      ],
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
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.subText)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
            const SizedBox(width: 2),
            Text(unit, style: TextStyle(fontSize: 12, color: AppColors.subText)),
          ],
        ),
      ],
    );
  }
}
