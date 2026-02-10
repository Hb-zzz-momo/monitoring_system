import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Simulate successful initialization
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  void _retry() {
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.monitor_heart,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            // App name
            Text(
              '设备监测系统',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 80),
            // Loading indicator or error
            if (_isLoading && !_hasError)
              Column(
                children: [
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '加载中...',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.subText,
                    ),
                  ),
                ],
              ),
            if (_hasError)
              Column(
                children: [
                  Text(
                    '加载失败',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _retry,
                    child: const Text('重试'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
