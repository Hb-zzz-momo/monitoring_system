import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'tabs/alarm_work_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/ai_tab.dart';
import 'device_list_screen.dart';

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

  void _switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  late final List<Widget> _tabs = [
    const DeviceListScreen(),
    const AlarmWorkTab(),
    const AiTab(),
    ProfileTab(onSwitchToDevices: () => _switchToTab(0)),
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
            icon: Icon(Icons.devices),
            label: '设备',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: '告警/工单',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'AI助手',
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
