import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/utils/sidebar_destination.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/user_store.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:macos_ui/macos_ui.dart';

import 'package:ios_club_app/core/services/secure_storage_service.dart';

Sidebar macosUISidebar({
  required List<SidebarDestination> items,
  required int selectedIndex,
  required Function(int) onItemSelected,
  double width = 220,
}) {
  return Sidebar(
    // 启用可调整大小的侧边栏，更符合 macOS 原生体验
    isResizable: true,
    minWidth: 180,
    maxWidth: 280,
    startWidth: width,
    builder: (context, scrollController) {
      // 添加顶部内边距，为标题栏和交通灯按钮留出空间
      return Column(
        children: [
          const SizedBox(height: 8),
          // 侧边栏导航项
          Expanded(
            child: SidebarItems(
              currentIndex: selectedIndex,
              scrollController: scrollController,
              itemSize: SidebarItemSize.large,
              onChanged: (index) {
                onItemSelected(index);
              },
              items: items.map((destination) {
                final isSelected = selectedIndex == items.indexOf(destination);
                return SidebarItem(
                  label: Text(
                    destination.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  leading: MacosIcon(
                    isSelected ? destination.selectedIcon : destination.icon,
                    size: 20,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    },
    // 底部用户信息卡片
    bottom: Consumer(
      builder: (context, ref, child) {
        final userState = ref.watch(userStoreProvider);
        final colors = context.clubColors;

        return Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: colors.separator,
                width: 0.5,
              ),
            ),
          ),
          padding: const EdgeInsets.only(top: 8),
          child: MacosListTile(
            onClick: () {
              AppRouter.go(AppRoutes.profile);
            },
            leading: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
              child: MacosIcon(
                CupertinoIcons.person_fill,
                size: 18,
                color: colors.onAccent,
              ),
            ),
            title: FutureBuilder(
              future: _getUsername(userState.isLogin),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Text(
                    snapshot.data!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  );
                }
                return const Text(
                  '未登录',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
            subtitle: Text(
              userState.isLogin ? '教务系统' : '点击登录',
              style: TextStyle(
                fontSize: 11,
                color: colors.secondaryLabel,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
          ),
        );
      },
    ),
  );
}

Future<String> _getUsername(bool isLogin) async {
  final prefs = PrefsService.instance;
  final secureStorage = SecureStorageService.instance;
  var name = '未登录';

  if (isLogin) {
    final iosName = await secureStorage.read(key: PrefsKeys.USERNAME) ??
        prefs.getString(PrefsKeys.USERNAME);
    if (iosName != null) {
      name = iosName;
    }
  }
  return name;
}
