import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/core/utils/sidebar_destination.dart';
import 'package:ios_club_app/core/services/app_service.dart';
import 'package:ios_club_app/features/system/notifications/task_executor.dart';
import 'package:ios_club_app/features/system/update/check_update_manager.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/ui/components/platform_dialog.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';
import 'package:ios_club_app/ui/pages/agreement_page.dart';
import 'package:macos_ui/macos_ui.dart';

import 'platform/mobile/bottom_navigation.dart';
import 'platform/tablet/tablet_navigation.dart';
import 'platform/macos/macos_ui_sidebar.dart';
import 'platform/windows/windows_sidebar.dart';

class MainApp extends ConsumerStatefulWidget {
  const MainApp({
    super.key,
    required this.child,
  });

  final Widget child;

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForUpdatesOnStartup();
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
    _updateSystemUIOverlayStyle();
  }

  void _updateSystemUIOverlayStyle() {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: brightness,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  Future<void> _checkForUpdatesOnStartup() async {
    final result = await CheckUpdateManager.checkForUpdates();
    if (!mounted || !result.$1) {
      return;
    }

    final navigatorReady = await _waitForNavigatorContext();
    if (navigatorReady == null || !mounted) {
      return;
    }

    _showUpdateDialog(result.$2);
  }

  Future<BuildContext?> _waitForNavigatorContext() async {
    for (var attempt = 0; attempt < 10; attempt++) {
      if (!mounted) {
        return null;
      }

      final navigatorContext = AppRouter.rootNavigatorKey.currentContext;
      if (navigatorContext != null) {
        return navigatorContext;
      }

      await Future<void>.delayed(const Duration(milliseconds: 16));
    }

    return null;
  }

  BuildContext? _currentNavigatorContext() {
    return AppRouter.rootNavigatorKey.currentContext;
  }

  void _showUpdateDialog(ReleaseModel model) {
    final navigatorContext = _currentNavigatorContext();
    if (navigatorContext == null) {
      return;
    }

    PlatformDialog.showCustomDialog<void>(
      navigatorContext,
      title: navigatorContext.l10n.updateAvailable,
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
        PlatformDialogAction<void>(
          label: navigatorContext.l10n.ignoreThisUpdate,
        ),
        PlatformDialogAction<void>(
          label: navigatorContext.l10n.ignoreAllUpdates,
          onPressed: () async {
            final prefs = PrefsService.instance;
            prefs.setBool(PrefsKeys.UPDATE_IGNORED, true);
          },
        ),
        PlatformDialogAction<void>(
          label: navigatorContext.l10n.goToBrowserUpdate,
          isDefaultAction: true,
          onPressed: () async {
            try {
              await AppService.updateApp(model);
              final currentNavigatorContext = _currentNavigatorContext();
              if (!mounted ||
                  currentNavigatorContext == null ||
                  !currentNavigatorContext.mounted) {
                return;
              }
              showClubSnackBar(
                currentNavigatorContext,
                Text(currentNavigatorContext.l10n.updateOpened),
              );
            } catch (e) {
              final currentNavigatorContext = _currentNavigatorContext();
              if (!mounted ||
                  currentNavigatorContext == null ||
                  !currentNavigatorContext.mounted) {
                return;
              }
              showClubSnackBar(
                currentNavigatorContext,
                Text('${currentNavigatorContext.l10n.openUpdateFailed}: $e'),
              );
            }
          },
        ),
      ],
    );
  }

  List<SidebarDestination> _buildDestinations(BuildContext context) {
    final l10n = context.l10n;

    return [
      SidebarDestination(
        icon: CupertinoIcons.house,
        selectedIcon: CupertinoIcons.house_fill,
        label: l10n.home,
      ),
      SidebarDestination(
        icon: Icons.schedule_outlined,
        selectedIcon: Icons.schedule,
        label: l10n.schedule,
      ),
      SidebarDestination(
        icon: CupertinoIcons.creditcard,
        selectedIcon: CupertinoIcons.creditcard_fill,
        label: l10n.score,
      ),
      SidebarDestination(
        icon: CupertinoIcons.person_alt_circle,
        selectedIcon: CupertinoIcons.person_crop_circle_fill,
        label: l10n.profile,
      ),
      SidebarDestination(
        icon: CupertinoIcons.bolt,
        selectedIcon: CupertinoIcons.bolt_fill,
        label: l10n.electricity,
      ),
      SidebarDestination(
        icon: Icons.directions_bus_outlined,
        selectedIcon: Icons.directions_bus_rounded,
        label: l10n.schoolBus,
      ),
      SidebarDestination(
        icon: CupertinoIcons.money_dollar,
        selectedIcon: CupertinoIcons.money_dollar_circle_fill,
        label: l10n.payment,
      ),
      SidebarDestination(
        icon: CupertinoIcons.map,
        selectedIcon: CupertinoIcons.map_fill,
        label: l10n.map,
      ),
    ];
  }

  List<NavigationDestination> _buildPrimaryNavigationDestinations(
    BuildContext context,
  ) {
    return _buildDestinations(context).take(4).map((destination) {
      return NavigationDestination(
        icon: Icon(destination.icon),
        selectedIcon: Icon(destination.selectedIcon),
        label: destination.label,
      );
    }).toList();
  }

  static const Map<int, String> _routeMap = {
    0: AppRoutes.home,
    1: AppRoutes.schedule,
    2: AppRoutes.score,
    3: AppRoutes.profile,
    4: AppRoutes.electricity,
    5: AppRoutes.schoolBus,
    6: AppRoutes.payment,
    7: AppRoutes.campusMap,
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

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsStoreProvider);
    final routedChild = widget.child;
    final destinations = _buildDestinations(context);
    final primaryDestinations = _buildPrimaryNavigationDestinations(context);

    final screenWidth = MediaQuery.of(context).size.width;
    // 判断设备类型
    final isMacOS = PlatformUtils.isMacOS;
    final isWindows = PlatformUtils.isWindows;
    final isLinux = !isMacOS && !isWindows && PlatformUtils.isDesktop;

    // 平板判断：宽度 > 600 且不是桌面平台
    final isTablet = screenWidth > 600 && !PlatformUtils.isDesktop;

    // macOS - 使用原生 macOS UI
    late final Widget shell;

    if (isMacOS) {
      shell = MacosWindow(
        sidebar: macosUISidebar(
          items: destinations,
          selectedIndex: _currentIndex,
          onItemSelected: (int index) {
            _navigateToMainRoute(index);
          },
        ),
        titleBar: TitleBar(
          title: Text(context.l10n.appName),
          decoration: BoxDecoration(
            color: MacosTheme.of(context).canvasColor,
          ),
        ),
        child: routedChild,
      );
    } else if (isWindows || isLinux) {
      // Windows/Linux - 使用 Windows 11 Fluent Design 风格侧边栏
      shell = Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              WindowsSidebar(
                items: destinations,
                selectedIndex: _currentIndex,
                onItemSelected: (int index) {
                  _navigateToMainRoute(index);
                },
              ),
              Expanded(
                child: routedChild,
              ),
            ],
          ),
        ),
      );
    } else if (isTablet) {
      // 平板 - 使用 NavigationRail，并与手机端主导航保持一致
      shell = TabletNavigation(
        destinations: primaryDestinations,
        selectedIndex: _currentIndex,
        onItemSelected: (int index) {
          _navigateToMainRoute(index);
        },
        child: routedChild,
      );
    } else {
      // 手机 - 使用底部导航栏（仅在四个主页面显示）
      shell = Scaffold(
        body: SafeArea(child: routedChild),
        bottomNavigationBar: _showBottomNav
            ? BottomNavigation(
                destinations: primaryDestinations,
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

    if (settings.hasAcceptedAgreement) {
      return shell;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        shell,
        const AgreementPage(),
      ],
    );
  }
}
