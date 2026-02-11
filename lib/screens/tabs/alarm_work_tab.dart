import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../mock_data/mock_data.dart';
import '../../routes/app_routes.dart';
import '../../components/common_widgets.dart';

class AlarmWorkTab extends StatefulWidget {
  const AlarmWorkTab({super.key});

  @override
  State<AlarmWorkTab> createState() => _AlarmWorkTabState();
}

class _AlarmWorkTabState extends State<AlarmWorkTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('告警/工单'),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.text,
              tabs: const [
                Tab(text: '告警'),
                Tab(text: '工单'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AlarmCenterView(),
          WorkOrdersView(),
        ],
      ),
    );
  }
}

class AlarmCenterView extends StatefulWidget {
  const AlarmCenterView({super.key});

  @override
  State<AlarmCenterView> createState() => _AlarmCenterViewState();
}

class _AlarmCenterViewState extends State<AlarmCenterView> {
  String _selectedLevel = '全部';
  String _selectedStatus = '进行中';

  List<Map<String, dynamic>> get _filteredAlarms {
    return MockData.alarms.where((alarm) {
      if (_selectedStatus != '全部' &&
          alarm['status'] !=
              (_selectedStatus == '进行中' ? '进行中' : '已处理')) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter area
        Container(
          color: AppColors.card,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '级别:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.subText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('全部', null),
                          const SizedBox(width: 8),
                          _buildFilterChip('提示', AppColors.info),
                          const SizedBox(width: 8),
                          _buildFilterChip('预警', AppColors.warning),
                          const SizedBox(width: 8),
                          _buildFilterChip('告警', AppColors.danger),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '状态:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.subText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip('进行中'),
                  const SizedBox(width: 8),
                  _buildStatusChip('已处理'),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Alarm list
        Expanded(
          child: _filteredAlarms.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: AppColors.success,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无告警',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.subText,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredAlarms.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final alarm = _filteredAlarms[index];
                    return _buildAlarmCard(alarm);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, Color? color) {
    final isSelected = _selectedLevel == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLevel = label;
        });
      },
      child: StatusChip(
        label: label,
        color: color,
        isSelected: isSelected,
      ),
    );
  }

  Widget _buildStatusChip(String label) {
    final isSelected = _selectedStatus == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatus = label;
        });
      },
      child: StatusChip(
        label: label,
        isSelected: isSelected,
      ),
    );
  }

  Widget _buildAlarmCard(Map<String, dynamic> alarm) {
    final color =
        alarm['level'] == 'danger' ? AppColors.danger : AppColors.warning;

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRoutes.alarmDetail,
            arguments: {'alarmId': alarm['id']},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Level indicator
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alarm['title'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${alarm['device']} - ${alarm['component']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.subText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alarm['description'],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.subText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (alarm['status'] == '进行中') ...[
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                            ),
                            child: const Text(
                              '确认',
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                            ),
                            child: const Text(
                              '创建工单',
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Time and arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    alarm['time'],
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.subText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.subText,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkOrdersView extends StatefulWidget {
  const WorkOrdersView({super.key});

  @override
  State<WorkOrdersView> createState() => _WorkOrdersViewState();
}

class _WorkOrdersViewState extends State<WorkOrdersView> {
  String _selectedStatus = '全部';
  String _selectedTime = '近24h';

  List<Map<String, dynamic>> get _filteredWorkOrders {
    if (_selectedStatus == '全部') {
      return MockData.workOrders;
    }
    return MockData.workOrders
        .where((wo) => wo['status'] == _selectedStatus)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter area
        Container(
          color: AppColors.card,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    '状态:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.subText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStatusChip('全部'),
                          const SizedBox(width: 8),
                          _buildStatusChip('待处理'),
                          const SizedBox(width: 8),
                          _buildStatusChip('处理中'),
                          const SizedBox(width: 8),
                          _buildStatusChip('已完成'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '时间:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.subText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildTimeChip('近24h'),
                  const SizedBox(width: 8),
                  _buildTimeChip('近7d'),
                  const SizedBox(width: 8),
                  _buildTimeChip('近30d'),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Work order list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredWorkOrders.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final workOrder = _filteredWorkOrders[index];
              return _buildWorkOrderCard(workOrder);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label) {
    final isSelected = _selectedStatus == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatus = label;
        });
      },
      child: StatusChip(
        label: label,
        isSelected: isSelected,
      ),
    );
  }

  Widget _buildTimeChip(String label) {
    final isSelected = _selectedTime == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTime = label;
        });
      },
      child: StatusChip(
        label: label,
        isSelected: isSelected,
      ),
    );
  }

  Widget _buildWorkOrderCard(Map<String, dynamic> workOrder) {
    Color statusColor;
    switch (workOrder['status']) {
      case '待处理':
        statusColor = AppColors.warning;
        break;
      case '处理中':
        statusColor = AppColors.info;
        break;
      case '已完成':
        statusColor = AppColors.success;
        break;
      default:
        statusColor = AppColors.subText;
    }

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRoutes.workOrderDetail,
            arguments: {'orderId': workOrder['id']},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          workOrder['id'],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            workOrder['status'],
                            style: TextStyle(
                              fontSize: 10,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${workOrder['device']} - ${workOrder['component']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.subText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workOrder['title'],
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 12,
                          color: AppColors.subText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          workOrder['assignee'],
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.subText,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppColors.subText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '更新: ${workOrder['updatedTime']}',
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
              Icon(
                Icons.chevron_right,
                color: AppColors.subText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
