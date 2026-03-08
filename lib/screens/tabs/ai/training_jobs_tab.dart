part of '../ai_tab.dart';

extension _AiTrainingJobsTab on _AiTabState {
  Widget _buildTrainingJobTab() {
    return _aiService.trainingJobs.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.model_training, size: 48, color: AppColors.subText.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Text('暂无训练任务', style: TextStyle(color: AppColors.subText)),
                const SizedBox(height: 4),
                Text('采集训练数据后即可开始训练', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _tabController.animateTo(1),
                  icon: const Icon(Icons.dataset, size: 16),
                  label: const Text('去准备数据'),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _aiService.trainingJobs.length,
            itemBuilder: (context, index) {
              return _buildTrainingJobCard(_aiService.trainingJobs[index]);
            },
          );
  }

  Widget _buildTrainingJobCard(TrainingJob job) {
    final statusColor = {
      'pending': AppColors.subText,
      'running': AppColors.info,
      'completed': AppColors.success,
      'failed': AppColors.danger,
    }[job.status] ?? AppColors.subText;
    final statusLabel = {
      'pending': '等待中',
      'running': '训练中',
      'completed': '已完成',
      'failed': '失败',
    }[job.status] ?? job.status;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.model_training, size: 20, color: statusColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job.modelName ?? job.id,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(statusLabel, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: job.progress,
                backgroundColor: AppColors.divider,
                color: statusColor,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${job.processedSamples} / ${job.totalSamples} 样本',
                  style: TextStyle(fontSize: 12, color: AppColors.subText),
                ),
                const Spacer(),
                Text(
                  '${(job.progress * 100).toInt()}%',
                  style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            if (job.status == 'completed' && job.modelName != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text(
                      '模型 ${job.modelName} 训练完成，可用于推理',
                      style: TextStyle(fontSize: 12, color: AppColors.success),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
