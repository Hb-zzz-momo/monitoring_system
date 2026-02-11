import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  runApp(const MonitoringSystemApp());
}

class MonitoringSystemApp extends StatelessWidget {
  const MonitoringSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '设备监测系统',
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRoutes.generateRoute,
      initialRoute: AppRoutes.splash,
      debugShowCheckedModeBanner: false,
    );
  }
}
