import 'package:flutter/material.dart';
import '../widgets/ai_work_order_suggestion.dart';

/// Example screen showing how to integrate AI work order suggestions
class WorkOrderCreateExample extends StatelessWidget {
  const WorkOrderCreateExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建工单'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form fields
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '工单信息',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Device field
                  const TextField(
                    decoration: InputDecoration(
                      labelText: '设备名称',
                      border: OutlineInputBorder(),
                      hintText: '电机 A',
                    ),
                    enabled: false,
                  ),
                  const SizedBox(height: 12),
                  
                  // Component field
                  const TextField(
                    decoration: InputDecoration(
                      labelText: '部件名称',
                      border: OutlineInputBorder(),
                      hintText: '冷却风扇',
                    ),
                    enabled: false,
                  ),
                  const SizedBox(height: 12),
                  
                  // Alarm type field
                  const TextField(
                    decoration: InputDecoration(
                      labelText: '告警类型',
                      border: OutlineInputBorder(),
                      hintText: '过温告警',
                    ),
                    enabled: false,
                  ),
                  const SizedBox(height: 12),
                  
                  // Description field
                  const TextField(
                    decoration: InputDecoration(
                      labelText: '问题描述',
                      border: OutlineInputBorder(),
                      hintText: '请输入问题描述...',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  
                  // Priority selector
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: '优先级',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('低')),
                      DropdownMenuItem(value: 'medium', child: Text('中')),
                      DropdownMenuItem(value: 'high', child: Text('高')),
                      DropdownMenuItem(value: 'urgent', child: Text('紧急')),
                    ],
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),

            // AI Work Order Suggestion Widget Integration
            const AIWorkOrderSuggestion(
              deviceName: '电机 A',
              alarmType: '过温告警',
              componentName: '冷却风扇',
              additionalContext: '温度持续超过阈值30分钟，历史记录显示冷却效率下降',
            ),

            // Actions section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '处理措施',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        CheckboxListTile(
                          title: const Text('检查冷却风扇运行状态'),
                          value: false,
                          onChanged: (value) {},
                        ),
                        CheckboxListTile(
                          title: const Text('清理散热器灰尘'),
                          value: false,
                          onChanged: (value) {},
                        ),
                        CheckboxListTile(
                          title: const Text('测量风扇转速'),
                          value: false,
                          onChanged: (value) {},
                        ),
                        CheckboxListTile(
                          title: const Text('更换故障风扇（如需要）'),
                          value: false,
                          onChanged: (value) {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Required parts section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '所需备件',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildPartRow('冷却风扇', '型号: FAN-001', '备用'),
                          const Divider(),
                          _buildPartRow('散热硅脂', '规格: 5g', '库存充足'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Submit buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('工单已创建'),
                            backgroundColor: Color.fromRGBO(18, 183, 106, 1),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(39, 99, 255, 1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
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

  Widget _buildPartRow(String name, String spec, String status) {
    Color statusColor;
    if (status == '库存充足') {
      statusColor = const Color.fromRGBO(18, 183, 106, 1);
    } else if (status == '备用') {
      statusColor = const Color.fromRGBO(245, 158, 11, 1);
    } else {
      statusColor = const Color.fromRGBO(240, 68, 56, 1);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  spec,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
