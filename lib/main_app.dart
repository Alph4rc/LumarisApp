import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/core/utils/sidebar_destination.dart';
import 'package:ios_club_app/features/system/notifications/task_executor.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/platform/android/download_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:ios_club_app/ui/pages/agreement_page.dart';
import 'package:macos_ui/macos_ui.dart';

import 'bottom_navigation.dart';
import 'platform/macos/macos_ui_sidebar.dart';
import 'platform/windows/windows_sidebar.dart';
import 'platform/tablet/tablet_navigation.dart';
import 'core/services/git_service.dart';
import 'features/system/update/check_update_manager.dart';

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _showBottomNav = true;

  static const _bottomNavRoutes = {
    AppRoutes.home,
    AppRoutes.schedule,
    AppRoutes.score,
    AppRoutes.profile,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppRouter.router.routerDelegate.addListener(_syncNavigationState);

    if (PlatformUtils.isAndroid) {
      CheckUpdateManager.checkForUpdates().then((result) async {
        if (result.$1) {
          showUpdateDialog(result.$2);
        }
      });
    }

    // 延迟执行导航，确保路由器已经初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final prefs = PrefsService.instance;
      final initialIndex = prefs.getInt(PrefsKeys.PAGE_DATA) ?? 0;
      final initialRoute = _routeMap[initialIndex] ?? AppRoutes.home;

      if (initialIndex != 0) {
        _navigateToMainRoute(initialIndex);
        return;
      }

      setState(() {
        _currentIndex = initialIndex;
        _showBottomNav = _bottomNavRoutes.contains(initialRoute);
      });
    });
  }

  @override
  void dispose() {
    AppRouter.router.routerDelegate.removeListener(_syncNavigationState);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App 回到前台时，延迟刷新小组件并重新安排课程通知
      // 避免在恢复动画期间进行重度操作导致卡顿
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          TaskExecutor.updateWidget();
          TaskExecutor.checkAndSendCourseReminder();
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final brightness = Theme.of(context).brightness;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarIconBrightness: brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light),
    );
  }

  void showUpdateDialog(ReleaseModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('有新版本了！'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(model.name),
              const SizedBox(height: 16),
              Text(model.body),
              const SizedBox(height: 16),
            ],
          ),
        ),
        actions: [
          Wrap(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('忽略本次更新'),
              ),
              TextButton(
                onPressed: () async {
                  final prefs = PrefsService.instance;
                  prefs.setBool(PrefsKeys.UPDATE_IGNORED, true);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('忽略所有更新'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  UpdateManager.showUpdateWithProgress(context, model.name);
                },
                child: const Text('现在就更新'),
              ),
            ],
          )
        ],
      ),
    );
  }

  final List<SidebarDestination> _destinations = const [
    SidebarDestination(
      icon: (CupertinoIcons.house),
      selectedIcon: (CupertinoIcons.house_fill),
      label: '首页',
    ),
    SidebarDestination(
      icon: (Icons.schedule_outlined),
      selectedIcon: (Icons.schedule),
      label: '课表',
    ),
    SidebarDestination(
      icon: (CupertinoIcons.creditcard),
      selectedIcon: (CupertinoIcons.creditcard_fill),
      label: '成绩',
    ),
    SidebarDestination(
      icon: (CupertinoIcons.person_alt_circle),
      selectedIcon: (CupertinoIcons.person_crop_circle_fill),
      label: '我的',
    ),
    SidebarDestination(
      icon: (CupertinoIcons.bolt),
      selectedIcon: (CupertinoIcons.bolt_fill),
      label: '电费',
    ),
    SidebarDestination(
      icon: (Icons.directions_bus_outlined),
      selectedIcon: (Icons.directions_bus_rounded),
      label: '校车',
    ),
    SidebarDestination(
      icon: (CupertinoIcons.money_dollar),
      selectedIcon: (CupertinoIcons.money_dollar_circle_fill),
      label: '饭卡',
    ),
  ];

  static const Map<int, String> _routeMap = {
    0: AppRoutes.home,
    1: AppRoutes.schedule,
    2: AppRoutes.score,
    3: AppRoutes.profile,
    4: AppRoutes.electricity,
    5: AppRoutes.schoolBus,
    6: AppRoutes.payment,
  };

  void _syncNavigationState() {
    final route = AppRouter.currentLocation;
    final index = _routeMap.entries
        .firstWhere(
          (entry) => entry.value == route,
          orElse: () => const MapEntry(0, AppRoutes.home),
        )
        .key;
    final showBottomNav = _bottomNavRoutes.contains(route);

    if (_currentIndex == index && _showBottomNav == showBottomNav) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _currentIndex = index;
        _showBottomNav = showBottomNav;
      });
    });
  }

  void _navigateToMainRoute(int index) {
    final route = _routeMap[index] ?? AppRoutes.home;
    setState(() {
      _currentIndex = index;
      _showBottomNav = _bottomNavRoutes.contains(route);
    });
    AppRouter.go(route);
  }

  Widget _app() {
    final settings = ref.watch(settingsStoreProvider);
    final router = ref.watch(appRouterProvider);
    final fontFamily = settings.fontFamily.isEmpty
        ? PlatformUtils.getWindowsFontFamily()
        : PlatformUtils.getDesktopFontFamily(settings.fontFamily);

    return MaterialApp.router(
      title: 'iOS Club App',
      debugShowCheckedModeBanner: false,
      theme: ClubTheme.lightTheme(fontFamily: fontFamily),
      darkTheme: ClubTheme.darkTheme(fontFamily: fontFamily),
      themeMode: settings.themeMode,
      routerConfig: router,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsStoreProvider);

    if (!settings.hasAcceptedAgreement) {
      return const AgreementPage();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 判断设备类型
    final isMacOS = PlatformUtils.isMacOS;
    final isWindows = PlatformUtils.isWindows;
    final isLinux = !isMacOS && !isWindows && PlatformUtils.isDesktop;

    // 平板判断：宽度 > 600 且不是桌面平台
    final isTablet = screenWidth > 600 && !PlatformUtils.isDesktop;

    // 平板横屏判断（使用 NavigationRail）
    final isTabletLandscape = isTablet && screenWidth > screenHeight;

    // 平板竖屏判断（使用 Drawer）
    final isTabletPortrait = isTablet && screenWidth <= screenHeight;

    // macOS - 使用原生 macOS UI
    if (isMacOS) {
      return MacosWindow(
        sidebar: macosUISidebar(
          items: _destinations,
          selectedIndex: _currentIndex,
          onItemSelected: (int index) {
            _navigateToMainRoute(index);
          },
        ),
        titleBar: TitleBar(
          title: const Text('iOS Club App'),
          decoration: BoxDecoration(
            color: MacosTheme.of(context).canvasColor,
          ),
        ),
        child: _app(),
      );
    }

    // Windows/Linux - 使用 Windows 11 Fluent Design 风格侧边栏
    if (isWindows || isLinux) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              WindowsSidebar(
                items: _destinations,
                selectedIndex: _currentIndex,
                onItemSelected: (int index) {
                  _navigateToMainRoute(index);
                },
              ),
              Expanded(
                child: _app(),
              ),
            ],
          ),
        ),
      );
    }

    // 平板横屏 - 使用 NavigationRail
    if (isTabletLandscape) {
      return TabletNavigation(
        items: _destinations,
        selectedIndex: _currentIndex,
        onItemSelected: (int index) {
          _navigateToMainRoute(index);
        },
        child: _app(),
      );
    }

    // 平板竖屏 - 使用 Drawer
    if (isTabletPortrait) {
      return TabletDrawerNavigation(
        items: _destinations,
        selectedIndex: _currentIndex,
        onItemSelected: (int index) {
          _navigateToMainRoute(index);
        },
        child: _app(),
      );
    }

    // 手机 - 使用底部导航栏（仅在四个主页面显示）
    return Scaffold(
      body: SafeArea(child: _app()),
      bottomNavigationBar: _showBottomNav
          ? BottomNavigation(
              destinations: _destinations.sublist(0, 4).map((destination) {
                return NavigationDestination(
                  icon: Icon(destination.icon),
                  selectedIcon: Icon(destination.selectedIcon),
                  label: destination.label,
                );
              }).toList(),
              selectedIndex: _currentIndex,
              onDestinationSelected: (int index) {
                _navigateToMainRoute(index);
              },
              backgroundColor: Theme.of(context)
                  .scaffoldBackgroundColor
                  .withValues(alpha: 0.95),
            )
          : null,
    );
  }
}
