import 'package:flutter/material.dart';
import 'package:ios_club_app/core/utils/animations/app_animations.dart';

/// Shimmer闪光加载效果
///
/// 仿照苹果风格的骨架屏加载动画
///
/// 示例：
/// ```dart
/// ShimmerLoading(
///   isLoading: true,
///   child: YourActualContent(),
/// )
/// ```
class ShimmerLoading extends StatefulWidget {
  /// 是否处于加载状态
  final bool isLoading;

  /// 加载时显示的骨架屏，不提供则使用默认骨架
  final Widget? skeleton;

  /// 实际内容
  final Widget child;

  /// 动画时长
  final Duration duration;

  const ShimmerLoading({
    super.key,
    required this.isLoading,
    required this.child,
    this.skeleton,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return AnimatedSwitcher(
        duration: AppAnimations.standard,
        child: widget.child,
      );
    }

    return AnimatedSwitcher(
      duration: AppAnimations.standard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: const [
                  Color(0xFFEBEBF4),
                  Color(0xFFF4F4F4),
                  Color(0xFFEBEBF4),
                ],
                stops: [
                  _animation.value - 0.3,
                  _animation.value,
                  _animation.value + 0.3,
                ].map((e) => e.clamp(0.0, 1.0)).toList(),
              ).createShader(bounds);
            },
            child: widget.skeleton ?? child,
          );
        },
        child: widget.skeleton ?? _buildDefaultSkeleton(),
      ),
    );
  }

  Widget _buildDefaultSkeleton() {
    return Container(
      color: Colors.white,
    );
  }
}

/// 骨架屏组件 - 用于创建各种形状的占位符
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }
}

/// 骨架屏圆形组件
class SkeletonCircle extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry? margin;

  const SkeletonCircle({
    super.key,
    required this.size,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: margin,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// 骨架屏文本行
class SkeletonLine extends StatelessWidget {
  final double? width;
  final double height;
  final EdgeInsetsGeometry? margin;

  const SkeletonLine({
    super.key,
    this.width,
    this.height = 12,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}

/// 预设的列表项骨架屏
class ListItemSkeleton extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;
  final int lines;

  const ListItemSkeleton({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.lines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (hasLeading)
            const SkeletonCircle(
              size: 48,
              margin: EdgeInsets.only(right: 12),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLine(
                  width: double.infinity,
                  height: 14,
                  margin: EdgeInsets.only(bottom: 8),
                ),
                if (lines > 1)
                  SkeletonLine(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 12,
                  ),
              ],
            ),
          ),
          if (hasTrailing)
            const SkeletonBox(
              width: 60,
              height: 30,
              margin: EdgeInsets.only(left: 12),
            ),
        ],
      ),
    );
  }
}

/// 预设的卡片骨架屏
class CardSkeleton extends StatelessWidget {
  final double? height;

  const CardSkeleton({
    super.key,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 200,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonCircle(size: 40, margin: EdgeInsets.only(right: 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLine(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 16,
                      margin: const EdgeInsets.only(bottom: 6),
                    ),
                    SkeletonLine(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          const SkeletonLine(width: double.infinity, height: 14, margin: EdgeInsets.only(bottom: 8)),
          SkeletonLine(width: MediaQuery.of(context).size.width * 0.7, height: 14),
        ],
      ),
    );
  }
}
