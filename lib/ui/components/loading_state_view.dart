import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ios_club_app/core/utils/animations/app_animations.dart';

class LoadingStateView extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool compact;
  final bool showCard;
  final EdgeInsetsGeometry padding;

  const LoadingStateView({
    super.key,
    this.title = '正在同步数据',
    this.subtitle = '网络较慢时可能需要几秒，请稍等一下',
    this.compact = false,
    this.showCard = false,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget content = AnimatedSwitcher(
      duration: AppAnimations.standard,
      child: compact ? _buildCompact(context) : _buildFull(context),
    );

    if (showCard) {
      content = _GlassContainer(
        compact: compact,
        isDark: isDark,
        child: content,
      );
    }

    return Padding(
      padding: padding,
      child: Center(
        child: content,
      ),
    );
  }

  Widget _buildFull(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      key: const ValueKey('loading_full'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const CupertinoActivityIndicator(radius: 16),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6), // 提升文字对比度
              height: 1.4,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompact(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      key: const ValueKey('loading_compact'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const CupertinoActivityIndicator(radius: 10),
        const SizedBox(width: 14),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final bool compact;
  final bool isDark;

  const _GlassContainer({
    required this.child,
    required this.compact,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // 现代毛玻璃效果：大幅增加模糊半径（VisionOS 风格），优化边框和背景
    return ClipRRect(
      borderRadius: BorderRadius.circular(compact ? 100 : 28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30), // 深度模糊
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 20 : 36,
            vertical: compact ? 12 : 36,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08) // 极简半透灰
                : Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(compact ? 100 : 28),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15) // 极细高光描边
                  : Colors.white.withValues(alpha: 0.8),
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
