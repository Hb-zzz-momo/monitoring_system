part of '../3d_device_tab.dart';

extension _ThreeDDrawer on _ThreeDDeviceContentState {
  Widget _buildDrawer(ComponentModel component) {
    final hi = component.healthIndex;
    final hiPercent = (hi * 100).toInt();
    final hiColor = hi >= 0.8
        ? AppColors.success
        : (hi >= 0.6 ? AppColors.warning : AppColors.danger);

    return Material(
      elevation: 16,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(component.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: hiColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('健康度: $hiPercent%',
                                  style: TextStyle(fontSize: 12, color: hiColor, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _closeDrawer,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('HI (健康度)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: hi,
                        backgroundColor: AppColors.divider,
                        color: hiColor,
                        minHeight: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$hiPercent%',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: hiColor)),
                        Text(hi >= 0.8 ? '良好' : (hi >= 0.6 ? '注意' : '警告'),
                            style: TextStyle(fontSize: 12, color: hiColor)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('RUL (剩余寿命)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${component.rul}',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text('天', style: TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('预测区间: ${component.rulRange} 天',
                        style: TextStyle(fontSize: 12, color: AppColors.subText)),
                    const SizedBox(height: 24),
                    const Text('建议动作',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...component.suggestions.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
                              const SizedBox(width: 8),
                              Expanded(child: Text(s, style: const TextStyle(fontSize: 12))),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                    const Text('相关测点',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...component.metrics.map((metric) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(metric.name, style: const TextStyle(fontSize: 13)),
                              Text('${metric.value} ${metric.unit}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _closeDrawer();
                        widget.onViewCharts?.call();
                      },
                      child: const Text('查看曲线'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _createWorkOrderFromComponent(component),
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
}
