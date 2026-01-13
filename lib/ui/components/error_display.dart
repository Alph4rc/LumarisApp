import 'package:flutter/material.dart';

/// 统一的错误显示组件
///
/// 提供多种错误显示方式：
/// - ErrorBanner: 内联错误横幅
/// - ErrorDialog: 错误对话框
/// - RetryableErrorWidget: 带重试按钮的完整错误页面

/// 内联错误横幅组件
///
/// 用于在页面中显示错误信息，不阻塞用户操作
///
/// 使用示例：
/// ```dart
/// if (controller.hasError) {
///   return ErrorBanner(
///     message: controller.errorMessage.value,
///     onRetry: () => controller.loadData(),
///   );
/// }
/// ```
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    super.key,
    required this.message,
    this.onRetry,
    this.showIcon = true,
  });

  final String message;
  final VoidCallback? onRetry;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? Colors.red.shade900.withValues(alpha: 0.3)
        : Colors.red.shade50;
    final textColor = isDarkMode ? Colors.red.shade200 : Colors.red.shade900;
    final iconColor = isDarkMode ? Colors.red.shade300 : Colors.red.shade700;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (showIcon) ...[
            Icon(
              Icons.error_outline,
              color: iconColor,
              size: 24,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: iconColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('重试'),
            ),
          ],
        ],
      ),
    );
  }
}

/// 带重试按钮的完整错误页面组件
///
/// 用于替代整个页面内容，显示错误信息和重试按钮
///
/// 使用示例：
/// ```dart
/// Obx(() {
///   if (controller.isLoading.value) {
///     return LoadingWidget();
///   }
///   if (controller.errorMessage.value.isNotEmpty) {
///     return RetryableErrorWidget(
///       message: controller.errorMessage.value,
///       onRetry: () => controller.loadData(),
///     );
///   }
///   return DataWidget(data: controller.data);
/// })
/// ```
class RetryableErrorWidget extends StatelessWidget {
  const RetryableErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDarkMode ? Colors.red.shade300 : Colors.red.shade700;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '出错了',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: subtextColor,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
