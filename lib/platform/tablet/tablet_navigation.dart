import 'package:flutter/material.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/theme/club_smooth_corners.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

/// 平板设备导航组件
///
/// 特点：
/// - 使用 NavigationRail 统一平板导航体验
/// - 复用手机端同一套主导航项
/// - 保持选中态与配色风格一致
class TabletNavigation extends StatelessWidget {
  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final Widget child;

  const TabletNavigation({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = context.clubColors;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              backgroundColor: colors.groupedBackground,
              selectedIndex: selectedIndex,
              onDestinationSelected: onItemSelected,
              labelType: NavigationRailLabelType.all,
              groupAlignment: 0,
              useIndicator: true,
              destinations: destinations.map((destination) {
                return NavigationRailDestination(
                  icon: destination.icon,
                  selectedIcon: destination.selectedIcon,
                  label: Text(
                    destination.label,
                    style: const TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.2,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                );
              }).toList(),
              selectedIconTheme: IconThemeData(
                color: colorScheme.primary,
                size: 24,
              ),
              unselectedIconTheme: IconThemeData(
                color: colors.secondaryLabel,
                size: 24,
              ),
              selectedLabelTextStyle: TextStyle(
                color: colorScheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: colors.secondaryLabel,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.2,
              ),
              indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
              indicatorShape: ClubSmoothCorners.shape(ClubRadii.navigation),
              minWidth: 88,
            ),
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
