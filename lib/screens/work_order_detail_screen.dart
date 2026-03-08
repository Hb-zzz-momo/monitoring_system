import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/common_widgets.dart';
import '../services/api_service.dart';
import '../models/work_order_model.dart';

class WorkOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const WorkOrderDetailScreen({super.key, required this.orderId});

  @override
  State<WorkOrderDetailScreen> createState() => _WorkOrderDetailScreenState();
}

class _WorkOrderDetailScreenState extends State<WorkOrderDetailScreen> {
  PageState _state = PageState.loading;
  WorkOrderModel? _workOrder;
  final List<Map<String, dynamic>> _checklistItems =
      List.from([
    {'title': '检查轴承温度', 'description': '使用红外测温仪测量', 'checked': true},
    {'title': '检查润滑情况', 'description': '确认润滑油充足', 'checked': true},
    {'title': '检查振动情况', 'description': '使用振动仪测量', 'checked': false},
    {'title': '更换轴承', 'description': '使用新备件更换', 'checked': false},
    {'title': '运行测试', 'description': '确认设备正常运行', 'checked': false},
  ]);

  final List<Map<String, dynamic>> _timeline =
      List.from([
    {'title': '工单创建', 'time': '2024-01-10 08:30', 'description': '系统自动创建工单'},
    {'title': '已接单', 'time': '2024-01-10 09:00', 'description': '已接单'},
    {'title': '处理中', 'time': '2024-01-10 10:00', 'description': '开始现场检查'},
  ]);

  @override
  void initState() {
    super.initState();
    _loadWorkOrder();
  }

  Future<void> _loadWorkOrder() async {
    setState(() => _state = PageState.loading);
    try {
      final raw = await fetchWorkOrder(widget.orderId);
      if (!mounted) return;
      setState(() {
        _workOrder = WorkOrderModel.fromJson(raw);
        _state = PageState.content;
      });
    } catch (e) {
      debugPrint('WorkOrderDetailScreen._loadWorkOrder error: $e');
      if (!mounted) return;
      setState(() => _state = PageState.error);
    }
  }

  Future<void> _moveNextStep() async {
    final current = _workOrder;
    if (current == null) return;
    final nextStatus = current.isPending
        ? '处理中'
        : (current.status == '处理中' ? '已完成' : '已完成');
    try {
      await updateWorkOrder(widget.orderId, {'status': nextStatus});
      await _loadWorkOrder();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('状态已更新为$nextStatus')),
      );
    } catch (e) {
      debugPrint('WorkOrderDetailScreen._moveNextStep error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('更新失败，请稍后重试')),
      );
    }
  }

  /// Returns [value] if non-empty, otherwise '-'.
  static String _orDash(String value) => value.isEmpty ? '-' : value;

  @override
  Widget build(BuildContext context) {
    final workOrder = _workOrder;
    if (workOrder == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('工单详情')),
        body: StateWidget(state: _state, onRetry: _loadWorkOrder, child: const SizedBox.shrink()),
      );
    }

    Color statusColor;
    switch (workOrder.status) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('工单详情'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary card
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _orDash(workOrder.id),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _orDash(workOrder.status),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('标题', _orDash(workOrder.title)),
                          const SizedBox(height: 8),
                          _buildInfoRow('设备', _orDash(workOrder.device)),
                          const SizedBox(height: 8),
                          _buildInfoRow('部件', _orDash(workOrder.component)),
                          const SizedBox(height: 8),
                          _buildInfoRow('创建时间', _orDash(workOrder.createdTime)),
                          const SizedBox(height: 8),
                          _buildInfoRow('描述', _orDash(workOrder.description)),
                        ],
                      ),
                    ),
                  ),
                  // Checklist
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '处理清单',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: _checklistItems.map((item) {
                                return _buildChecklistItem(item);
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Attachments
                        const Text(
                          '附件',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  children: [
                                    _buildImagePlaceholder(),
                                    _buildImagePlaceholder(),
                                    _buildUploadButton(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Timeline
                        const Text(
                          '处理记录',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: _timeline.map((event) {
                                return _buildTimelineItem(event);
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    // TODO(P2): 实现添加备注功能（弹出输入框并提交到后端）
                    onPressed: () {},
                    child: const Text('添加备注'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _moveNextStep,
                    child: const Text('下一步'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.subText,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: item['checked'],
            onChanged: (value) {
              setState(() {
                item['checked'] = value ?? false;
              });
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: item['checked']
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.subText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Center(
        child: Icon(
          Icons.image,
          size: 40,
          color: AppColors.subText,
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return InkWell(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate,
                size: 32,
                color: AppColors.primary,
              ),
              const SizedBox(height: 4),
              Text(
                '上传',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 40,
                color: AppColors.divider,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event['time'],
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.subText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.subText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
