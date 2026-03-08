part of '../3d_device_tab.dart';

extension _ThreeDCards on _ThreeDDeviceContentState {
  Widget _buildKpiCard(String title, String value, String unit, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 11, color: AppColors.subText)),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(unit, style: TextStyle(fontSize: 11, color: AppColors.subText)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAlarmsCard() {
    final recentAlarms = _alarms.take(2).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, size: 16, color: AppColors.danger),
                const SizedBox(width: 8),
                const Text('最近告警',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${recentAlarms.length}条',
                    style: TextStyle(fontSize: 12, color: AppColors.subText)),
              ],
            ),
            const SizedBox(height: 12),
            ...recentAlarms.map((alarm) {
              return InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.alarmDetail,
                    arguments: AlarmDetailArgs(alarmId: alarm.id),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 32,
                        decoration: BoxDecoration(
                          color: alarm.isDanger ? AppColors.danger : AppColors.warning,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(alarm.title,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text('${alarm.component} · ${alarm.time}',
                                style: TextStyle(fontSize: 11, color: AppColors.subText)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 18, color: AppColors.subText),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
