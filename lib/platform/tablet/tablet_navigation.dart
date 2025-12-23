import 'package:flutter/material.dart';
import 'package:ios_club_app/modern_sidebar.dart';

/// 平板设备导航组件
///
/// 特点：
/// - 使用 NavigationRail 实现紧凑的侧边导航
/// - 支持展开/收起
/// - 优化触摸交互体验
/// - 适配横屏和竖屏模式
class TabletNavigation extends StatefulWidget {
  final List<SidebarDestination> items;
  final int selectedIndex;
  final Function(int) onItemSelected;
  final Widget child;

  const TabletNavigation({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.child,
  });

  @override
  State<TabletNavigation> createState() => _TabletNavigationState();
}

class _TabletNavigationState extends State<TabletNavigation> {
  bool _isExtended = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          // NavigationRail
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: NavigationRail(
              extended: _isExtended,
              backgroundColor: isDark
                  ? Colors.grey[900]?.withValues(alpha: 0.95)
                  : Colors.grey[50]?.withValues(alpha: 0.95),
              elevation: 2,
              selectedIndex: widget.selectedIndex,
              onDestinationSelected: widget.onItemSelected,
              labelType: _isExtended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              groupAlignment: -0.9,
              leading: Column(
                children: [
                  const SizedBox(height: 8),
                  // App Logo
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.dashboard_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 展开/收起按钮
                  IconButton(
                    icon: AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: _isExtended ? 0 : 0.5,
                      child: const Icon(Icons.chevron_left),
                    ),
                    onPressed: () {
                      setState(() {
                        _isExtended = !_isExtended;
                      });
                    },
                    tooltip: _isExtended ? '收起侧边栏' : '展开侧边栏',
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              destinations: widget.items.map((destination) {
                return NavigationRailDestination(
                  icon: Icon(destination.icon),
                  selectedIcon: Icon(destination.selectedIcon),
                  label: Text(
                    destination.label,
                    style: const TextStyle(
                      fontSize: 13,
                      letterSpacing: 0.2,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                );
              }).toList(),
              selectedIconTheme: IconThemeData(
                color: colorScheme.primary,
                size: 28,
              ),
              unselectedIconTheme: IconThemeData(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                size: 24,
              ),
              selectedLabelTextStyle: TextStyle(
                color: colorScheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.2,
              ),
              indicatorColor: colorScheme.primary.withValues(alpha: 0.15),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minWidth: 72,
              minExtendedWidth: 220,
            ),
          ),

          // 内容区域
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

/// 平板抽屉式导航（用于竖屏模式或更小的平板）
class TabletDrawerNavigation extends StatelessWidget {
  final List<SidebarDestination> items;
  final int selectedIndex;
  final Function(int) onItemSelected;
  final Widget child;

  const TabletDrawerNavigation({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('iOS Club App'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      ),
      drawer: Drawer(
        width: 280,
        child: Column(
          children: [
            // Drawer 头部
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.dashboard_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'iOS Club App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // 导航项
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = selectedIndex == index;

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(
                        isSelected ? item.selectedIcon : item.icon,
                        color: isSelected
                            ? colorScheme.primary
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? colorScheme.primary
                              : (isDark ? Colors.grey[300] : Colors.grey[800]),
                        ),
                      ),
                      selected: isSelected,
                      onTap: () {
                        onItemSelected(index);
                        Navigator.pop(context); // 关闭抽屉
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}
