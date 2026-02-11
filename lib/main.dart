import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'services/ai_chat_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AIChatProvider()),
      ],
      child: const MonitoringSystemApp(),
    ),
  );
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
