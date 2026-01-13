import 'package:flutter/animation.dart';

/// 应用统一动画配置
/// 遵循苹果设计规范的动画时长和曲线
class AppAnimations {
  AppAnimations._();

  // ==================== 动画时长 ====================

  /// 快速动画 - 用于微交互（按钮按压、开关切换）
  static const Duration fast = Duration(milliseconds: 200);

  /// 标准动画 - 用于大多数UI转换（卡片展开、列表项出现）
  static const Duration standard = Duration(milliseconds: 300);

  /// 中等动画 - 用于复杂的过渡（页面内容切换）
  static const Duration medium = Duration(milliseconds: 400);

  /// 慢速动画 - 用于引人注目的效果（进度条、加载完成）
  static const Duration slow = Duration(milliseconds: 600);

  /// 超慢动画 - 用于数值变化等持续性动画
  static const Duration extraSlow = Duration(milliseconds: 1000);

  // ==================== 动画曲线 ====================

  /// 标准缓入缓出 - 苹果推荐的默认曲线
  static const Curve defaultCurve = Curves.easeInOut;

  /// 缓出 - 用于进入动画（元素出现）
  static const Curve easeOut = Curves.easeOutCubic;

  /// 缓入 - 用于退出动画（元素消失）
  static const Curve easeIn = Curves.easeInCubic;

  /// 弹性 - 用于强调性动画
  static const Curve spring = Curves.elasticOut;

  /// 平滑 - 用于连续变化的动画
  static const Curve smooth = Curves.easeOutQuart;

  // ==================== 列表动画配置 ====================

  /// 列表项基础延迟（每项）
  static const Duration listItemDelay = Duration(milliseconds: 50);

  /// 列表项最大延迟时间
  static const Duration listItemMaxDelay = Duration(milliseconds: 400);

  /// 列表项动画时长
  static const Duration listItemDuration = Duration(milliseconds: 400);

  /// 计算列表项延迟（索引 * 延迟，但不超过最大延迟）
  static Duration getListItemDelay(int index) {
    final delay = listItemDelay * index;
    return delay > listItemMaxDelay ? listItemMaxDelay : delay;
  }

  // ==================== 偏移量 ====================

  /// 列表项滑入的垂直偏移量
  static const double slideOffset = 20.0;

  /// 卡片滑入的垂直偏移量
  static const double cardSlideOffset = 30.0;

  // ==================== 缩放比例 ====================

  /// 按压时的缩放比例
  static const double pressScale = 0.95;

  /// 卡片初始缩放比例
  static const double cardInitialScale = 0.9;

  /// 悬停时的缩放比例
  static const double hoverScale = 1.02;

  // ==================== 不透明度 ====================

  /// 禁用状态不透明度
  static const double disabledOpacity = 0.4;

  /// 次要元素不透明度
  static const double secondaryOpacity = 0.6;
}
