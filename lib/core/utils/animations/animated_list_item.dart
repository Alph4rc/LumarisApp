import 'package:flutter/material.dart';
import 'package:ios_club_app/core/utils/animations/app_animations.dart';

/// 带有瀑布流进入动画的列表项
///
/// 使用苹果风格的动画：从下往上滑入 + 淡入效果
///
/// 示例：
/// ```dart
/// ListView.builder(
///   itemBuilder: (context, index) {
///     return AnimatedListItem(
///       index: index,
///       child: YourListTile(),
///     );
///   },
/// )
/// ```
class AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration? duration;
  final Duration? delay;
  final Curve? curve;
  final double? slideOffset;

  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
    this.duration,
    this.delay,
    this.curve,
    this.slideOffset,
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curved;
  late final double _offset;

  @override
  void initState() {
    super.initState();
    final animDuration = widget.duration ?? AppAnimations.listItemDuration;
    final animCurve = widget.curve ?? AppAnimations.easeOut;
    _offset = widget.slideOffset ?? AppAnimations.slideOffset;

    _controller = AnimationController(duration: animDuration, vsync: this);
    _curved = CurvedAnimation(parent: _controller, curve: animCurve);

    final animDelay =
        widget.delay ?? AppAnimations.getListItemDelay(widget.index);
    if (animDelay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(animDelay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curved,
      child: AnimatedBuilder(
        animation: _curved,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _offset * (1 - _curved.value)),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// 带有从左滑入动画的列表项
class AnimatedListItemSlideLeft extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration? duration;
  final Duration? delay;
  final Curve? curve;

  const AnimatedListItemSlideLeft({
    super.key,
    required this.index,
    required this.child,
    this.duration,
    this.delay,
    this.curve,
  });

  @override
  State<AnimatedListItemSlideLeft> createState() =>
      _AnimatedListItemSlideLeftState();
}

class _AnimatedListItemSlideLeftState extends State<AnimatedListItemSlideLeft>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curved;

  @override
  void initState() {
    super.initState();
    final animDuration = widget.duration ?? AppAnimations.listItemDuration;
    final animCurve = widget.curve ?? AppAnimations.easeOut;

    _controller = AnimationController(duration: animDuration, vsync: this);
    _curved = CurvedAnimation(parent: _controller, curve: animCurve);

    final animDelay =
        widget.delay ?? AppAnimations.getListItemDelay(widget.index);
    if (animDelay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(animDelay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curved,
      child: AnimatedBuilder(
        animation: _curved,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(-30 * (1 - _curved.value), 0),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// 带有缩放进入动画的列表项
class AnimatedListItemScale extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration? duration;
  final Duration? delay;
  final Curve? curve;

  const AnimatedListItemScale({
    super.key,
    required this.index,
    required this.child,
    this.duration,
    this.delay,
    this.curve,
  });

  @override
  State<AnimatedListItemScale> createState() => _AnimatedListItemScaleState();
}

class _AnimatedListItemScaleState extends State<AnimatedListItemScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curved;

  @override
  void initState() {
    super.initState();
    final animDuration = widget.duration ?? AppAnimations.listItemDuration;
    final animCurve = widget.curve ?? AppAnimations.easeOut;

    _controller = AnimationController(duration: animDuration, vsync: this);
    _curved = CurvedAnimation(parent: _controller, curve: animCurve);

    final animDelay =
        widget.delay ?? AppAnimations.getListItemDelay(widget.index);
    if (animDelay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(animDelay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(_curved),
        child: widget.child,
      ),
    );
  }
}
