import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/core/utils/sidebar_destination.dart';
import 'package:ios_club_app/features/system/notifications/task_executor.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/platform/android/download_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/ui/pages/agreement_page.dart';
import 'package:macos_ui/macos_ui.dart';

import 'bottom_navigation.dart';
import 'platform/macos/macos_ui_sidebar.dart';
import 'platform/windows/windows_sidebar.dart';
import 'platform/tablet/tablet_navigation.dart';
import 'core/services/git_service.dart';
import 'features/system/update/check_update_manager.dart';
import 'under_maintenance_screen.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _showBottomNav = true;
  final SettingsStore settingsStore = SettingsStore.to;

  static const _bottomNavRoutes = {'/', '/Schedule', '/Score', '/Profile'};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (PlatformUtils.isAndroid) {
      CheckUpdateManager.checkForUpdates().then((result) async {
        if (result.$1) {
          showUpdateDialog(result.$2);
        }
      });
    }

    // 延迟执行导航，确保GetMaterialApp已经初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = PrefsService.instance;
      setState(() {
        _currentIndex = prefs.getInt(PrefsKeys.PAGE_DATA) ?? 0;
        // 只有在不是默认首页时才导航
        if (_currentIndex != 0) {
          Get.toNamed(_routeMap[_currentIndex] ?? '/');
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App 回到前台时，刷新小组件并重新安排课程通知
      // 这对 iOS 尤其重要，因为后台 Timer 不会运行
      TaskExecutor.updateWidget();
      TaskExecutor.checkAndSendCourseReminder();
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
    0: '/',
    1: '/Schedule',
    2: '/Score',
    3: '/Profile',
    4: '/Electricity',
    5: '/SchoolBus',
    6: '/Payment',
  };

  Widget _app(bool isTablet) => GetMaterialApp(
        title: 'iOS Club App',
        debugShowCheckedModeBanner: false,
        defaultTransition: (kIsWeb)
            ? Transition.fadeIn
            : isTablet
                ? Transition.fadeIn
                : Transition.native,
        theme: ThemeData(
          fontFamily: SettingsStore.to.fontFamily.isEmpty
              ? PlatformUtils.getWindowsFontFamily()
              : PlatformUtils.getDesktopFontFamily(SettingsStore.to.fontFamily),
        ),
        darkTheme: ThemeData(
          fontFamily: SettingsStore.to.fontFamily.isEmpty
              ? PlatformUtils.getWindowsFontFamily()
              : PlatformUtils.getDesktopFontFamily(SettingsStore.to.fontFamily),
          brightness: Brightness.dark,
          appBarTheme: const AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        getPages: AppRouter.getPages,
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => UnderMaintenanceScreen(),
          );
        },
        // 添加路由监听，确保索引与路由同步
        routingCallback: (routing) {
          if (routing?.current != null) {
            final route = routing!.current;
            final index = _routeMap.entries
                .firstWhere((entry) => entry.value == route,
                    orElse: () => const MapEntry(0, '/'))
                .key;
            final showBottomNav = _bottomNavRoutes.contains(route);
            if (_currentIndex != index || _showBottomNav != showBottomNav) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _currentIndex = index;
                    _showBottomNav = showBottomNav;
                  });
                }
              });
            }
          }
        },
      );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!settingsStore.hasAcceptedAgreement) {
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
              setState(() {
                _currentIndex = index;
              });
              Get.toNamed(_routeMap[index] ?? '/');
            },
          ),
          titleBar: TitleBar(
            title: const Text('iOS Club App'),
            decoration: BoxDecoration(
              color: MacosTheme.of(context).canvasColor,
            ),
          ),
          child: _app(true),
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
                    setState(() {
                      _currentIndex = index;
                    });
                    Get.toNamed(_routeMap[index] ?? '/');
                  },
                ),
                Expanded(
                  child: _app(true),
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
            setState(() {
              _currentIndex = index;
            });
            Get.toNamed(_routeMap[index] ?? '/');
          },
          child: _app(true),
        );
      }

      // 平板竖屏 - 使用 Drawer
      if (isTabletPortrait) {
        return TabletDrawerNavigation(
          items: _destinations,
          selectedIndex: _currentIndex,
          onItemSelected: (int index) {
            setState(() {
              _currentIndex = index;
            });
            Get.toNamed(_routeMap[index] ?? '/');
          },
          child: _app(true),
        );
      }

      // 手机 - 使用底部导航栏（仅在四个主页面显示）
      return Scaffold(
        body: SafeArea(child: _app(false)),
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
                  setState(() {
                    _currentIndex = index;
                  });
                  Get.toNamed(_routeMap[index] ?? '/');
                },
                backgroundColor: Theme.of(context)
                    .scaffoldBackgroundColor
                    .withValues(alpha: 0.95),
              )
            : null,
      );
    });
  }
}
