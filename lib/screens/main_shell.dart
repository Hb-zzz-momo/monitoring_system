import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'tabs/3d_device_tab.dart';
import 'tabs/realtime_tab.dart';
import 'tabs/alarm_work_tab.dart';
import 'tabs/profile_tab.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _tabs = const [
    ThreeDDeviceTab(),
    RealtimeTab(),
    AlarmWorkTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.subText,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.view_in_ar),
            label: '3D设备',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '实时监测',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: '告警/工单',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
