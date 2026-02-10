import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum PageState { loading, empty, error, content }

class StateWidget extends StatelessWidget {
  final PageState state;
  final Widget child;
  final VoidCallback? onRetry;
  final String? emptyMessage;
  final String? errorMessage;

  const StateWidget({
    super.key,
    required this.state,
    required this.child,
    this.onRetry,
    this.emptyMessage,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case PageState.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case PageState.empty:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 80,
                color: AppColors.subText,
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage ?? '暂无数据',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.subText,
                ),
              ),
            ],
          ),
        );
      case PageState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: AppColors.danger,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage ?? '加载失败',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.subText,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('重试'),
                ),
              ],
            ],
          ),
        );
      case PageState.content:
        return child;
    }
  }
}

class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height = 20,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool isSelected;

  const StatusChip({
    super.key,
    required this.label,
    this.color,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? (color ?? AppColors.primary).withOpacity(0.1)
            : AppColors.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isSelected ? (color ?? AppColors.primary) : AppColors.divider,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? (color ?? AppColors.primary) : AppColors.text,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}

class StatusDot extends StatelessWidget {
  final bool isOnline;
  final double size;

  const StatusDot({
    super.key,
    required this.isOnline,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isOnline ? AppColors.success : AppColors.subText,
        shape: BoxShape.circle,
      ),
    );
  }
}

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String? subtitle;
  final Color? color;
  final IconData? icon;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    this.subtitle,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: AppColors.subText),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.subText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color ?? AppColors.text,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.subText,
                    ),
                  ),
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.subText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
