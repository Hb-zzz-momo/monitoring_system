import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/device_list_screen.dart';
import '../screens/device_detail_shell.dart';
import '../screens/alarm_detail_screen.dart';
import '../screens/work_order_detail_screen.dart';
import '../screens/main_shell.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String deviceList = '/device-list';
  static const String mainShell = '/main';
  static const String deviceDetail = '/device-detail';
  static const String alarmDetail = '/alarm-detail';
  static const String workOrderDetail = '/work-order-detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case deviceList:
        return MaterialPageRoute(builder: (_) => const DeviceListScreen());
      case mainShell:
        final args = settings.arguments as Map<String, dynamic>?;
        final initialIndex = args?['initialIndex'] ?? 0;
        return MaterialPageRoute(
          builder: (_) => MainShell(initialIndex: initialIndex),
        );
      case deviceDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => DeviceDetailShell(
            deviceId: args['deviceId'],
            deviceName: args['deviceName'],
          ),
        );
      case alarmDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AlarmDetailScreen(alarmId: args['alarmId']),
        );
      case workOrderDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => WorkOrderDetailScreen(orderId: args['orderId']),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for \${settings.name}'),
            ),
          ),
        );
    }
  }
}
