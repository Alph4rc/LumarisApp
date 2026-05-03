import 'package:flutter/material.dart';
import 'package:ios_club_app/core/utils/sidebar_destination.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

/// Apple 风格侧边栏 (参考 iCloud / App Store 设计)
///
/// 特点：
/// - 极简设计，大圆角选中态
/// - 适配亮色/暗黑模式
/// - 更加通透的视觉效果
class WindowsSidebar extends StatefulWidget {
  final List<SidebarDestination> items;
  final int selectedIndex;
  final Function(int) onItemSelected;
  final double width;

  const WindowsSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.width = 260, // Apple 风格侧边栏通常稍窄
  });

  @override
  State<WindowsSidebar> createState() => _WindowsSidebarState();
}

class _WindowsSidebarState extends State<WindowsSidebar> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final colors = context.clubColors;

    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: colors.groupedBackground,
        border: Border(
          right: BorderSide(
            color: colors.separator,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // 顶部标题区域
          _buildHeader(isDark, colorScheme),

          const SizedBox(height: 10),

          // 导航项列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final isSelected = widget.selectedIndex == index;
                final isHovered = _hoveredIndex == index;

                return _buildNavItem(
                  item: item,
                  isSelected: isSelected,
                  isHovered: isHovered,
                  onTap: () => widget.onItemSelected(index),
                  onHover: (hovering) {
                    setState(() {
                      _hoveredIndex = hovering ? index : null;
                    });
                  },
                  isDark: isDark,
                  colorScheme: colorScheme,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, ColorScheme colorScheme) {
    return Container(
      height: 60, // 稍微增加高度
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          // App 图标 - 更加圆润
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: ClubRadii.control, // Apple 风格圆角
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.apple, // 使用 Apple 图标或保持 dashboard
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          // App 名称
          Text(
            'iOS Club',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.clubColors.label,
              letterSpacing: -0.5, // 紧凑的字间距
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required SidebarDestination item,
    required bool isSelected,
    required bool isHovered,
    required VoidCallback onTap,
    required Function(bool) onHover,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    // 选中态颜色 - 模仿 macOS 强调色
    final selectedBgColor = colorScheme.primary;
    final selectedTextColor = Colors.white;

    // 悬停态颜色
    final hoverBgColor = isDark
        ? context.clubColors.selectionFill
        : colorScheme.primary.withValues(alpha: 0.08);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          onEnter: (_) => onHover(true),
          onExit: (_) => onHover(false),
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? selectedBgColor
                  : isHovered
                      ? hoverBgColor
                      : Colors.transparent,
              borderRadius: ClubRadii.navigation, // Apple 风格大圆角
            ),
            child: Row(
              children: [
                // 图标
                Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  size: 20,
                  color: isSelected
                      ? selectedTextColor
                      : context.clubColors.secondaryLabel,
                ),
                const SizedBox(width: 12),
                // 标签
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                      color: isSelected
                          ? selectedTextColor
                          : context.clubColors.label,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Badge (如果有)
                if (item.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.2)
                          : context.clubColors.cardOverlay,
                      borderRadius: ClubRadii.navigation,
                    ),
                    child: Text(
                      item.badge!,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : context.clubColors.label,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
