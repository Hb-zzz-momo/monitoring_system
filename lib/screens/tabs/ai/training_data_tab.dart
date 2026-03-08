part of '../ai_tab.dart';

extension _AiTrainingDataTab on _AiTabState {
  Widget _buildTrainingDataTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '训练数据采集',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
              ),
              const SizedBox(height: 4),
              Text(
                '采集设备和告警数据，或手动添加问答对来训练专家模型',
                style: TextStyle(fontSize: 12, color: AppColors.subText),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _aiService.collectDeviceTrainingData(),
                      icon: const Icon(Icons.devices, size: 16),
                      label: const Text('采集设备数据', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _aiService.collectAlarmTrainingData(),
                      icon: const Icon(Icons.notifications, size: 16),
                      label: const Text('采集告警数据', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showAddTrainingDataDialog,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('手动添加', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '共 ${_aiService.trainingData.length} 条样本',
                style: TextStyle(fontSize: 12, color: AppColors.subText),
              ),
              const Spacer(),
              if (_aiService.trainingData.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    _tabController.animateTo(2);
                    _aiService.submitTrainingJob();
                  },
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('开始训练', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: _aiService.trainingData.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.dataset, size: 48, color: AppColors.subText.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      Text('暂无训练数据', style: TextStyle(color: AppColors.subText)),
                      const SizedBox(height: 4),
                      Text('点击上方按钮采集或手动添加', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _aiService.trainingData.length,
                  itemBuilder: (context, index) {
                    return _buildTrainingDataCard(_aiService.trainingData[index], index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTrainingDataCard(TrainingDataItem item, int index) {
    final sourceIcon = {
      'device': Icons.devices,
      'alarm': Icons.notifications,
      'manual': Icons.edit,
    }[item.source] ?? Icons.data_object;
    final sourceLabel = {
      'device': '设备数据',
      'alarm': '告警数据',
      'manual': '手动添加',
    }[item.source] ?? item.source;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(sourceIcon, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(sourceLabel, style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                const Spacer(),
                InkWell(
                  onTap: () => _aiService.removeTrainingData(index),
                  child: Icon(Icons.close, size: 16, color: AppColors.subText),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('输入:', style: TextStyle(fontSize: 11, color: AppColors.subText, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(item.input, style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text('期望输出:', style: TextStyle(fontSize: 11, color: AppColors.subText, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(item.expectedOutput, style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
