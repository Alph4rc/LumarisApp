import 'package:flutter/material.dart';
import 'package:ios_club_app/modern_sidebar.dart';

/// Windows 11 Fluent Design 风格侧边栏
///
/// 特点：
/// - Acrylic 毛玻璃效果背景
/// - 流畅的悬停和选中动画
/// - 符合 Windows 11 设计语言
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
    this.width = 280,
  });

  @override
  State<WindowsSidebar> createState() => _WindowsSidebarState();
}

class _WindowsSidebarState extends State<WindowsSidebar> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: widget.width,
      decoration: BoxDecoration(
        // Windows 11 风格背景
        color: isDark
            ? const Color(0xFF202020).withValues(alpha: 0.95)
            : const Color(0xFFF3F3F3).withValues(alpha: 0.95),
        border: Border(
          right: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // 顶部标题区域（Windows 11 风格）
          _buildHeader(isDark, colorScheme),

          const SizedBox(height: 8),

          // 导航项列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // App 图标
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          // App 名称
          Expanded(
            child: Text(
              'iOS Club App',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                letterSpacing: 0.3,
              ),
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          onHover: onHover,
          borderRadius: BorderRadius.circular(6),
          splashColor: colorScheme.primary.withValues(alpha: 0.1),
          highlightColor: colorScheme.primary.withValues(alpha: 0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              // Windows 11 选中效果
              color: isSelected
                  ? (isDark
                      ? colorScheme.primary.withValues(alpha: 0.15)
                      : colorScheme.primary.withValues(alpha: 0.12))
                  : isHovered
                      ? (isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.04))
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              // 选中时左侧高亮条
              border: isSelected
                  ? Border(
                      left: BorderSide(
                        color: colorScheme.primary,
                        width: 3,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                // 图标
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? item.selectedIcon : item.icon,
                    size: 20,
                    color: isSelected
                        ? colorScheme.primary
                        : (isDark ? Colors.grey[300] : Colors.grey[700]),
                  ),
                ),
                const SizedBox(width: 16),
                // 标签
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? (isDark ? Colors.white : const Color(0xFF1F1F1F))
                          : (isDark ? Colors.grey[300] : Colors.grey[700]),
                      letterSpacing: 0.2,
                    ),
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                // Badge（如果有）
                if (item.badge != null)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item.badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
