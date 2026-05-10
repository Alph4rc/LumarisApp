import 'dart:async';
import 'dart:io';

import 'package:display_mode/display_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/features/basic/services/basic_http_client_manager.dart';
import 'package:ios_club_app/state/auth_state_notifier.dart';
import 'package:ios_club_app/core/services/hive_manager.dart';
import 'package:ios_club_app/core/services/permission_service.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/core/utils/request_cache.dart';
import 'package:ios_club_app/features/education/services/auth_service.dart';
import 'package:ios_club_app/features/education/services/edu_http_client.dart';
import 'package:ios_club_app/features/education/services/edu_http_client_manager.dart';
import 'package:ios_club_app/features/education/services/education_refresh_service.dart';
import 'package:ios_club_app/features/system/notifications/notification_service.dart';
import 'package:ios_club_app/features/system/notifications/task_executor.dart';
import 'package:ios_club_app/features/system/widget_service.dart';
import 'package:ios_club_app/platform/android/background_service.dart';
import 'package:ios_club_app/platform/ios/background_service.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/ui/components/platform_dialog.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/services/app_locale_service.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';

import 'main_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.info('光序 启动中...');

  // Hive 和 SharedPreferences 互相独立，并行初始化
  await Future.wait([
    HiveManager.init(),
    PrefsService.init(),
  ]);

  if (PlatformUtils.isIOS) {
    await WidgetService.initialize();
  }

  final providerContainer = ProviderContainer();
  final settingsStore = providerContainer.read(settingsStoreProvider.notifier);
  final authStateNotifier =
      providerContainer.read(authStateNotifierProvider.notifier);
  final courseStore = providerContainer.read(courseStoreProvider.notifier);

  EduHttpClientManager.initialize(
    school: settingsStore.currentSchool,
    authStateCallbacks: AuthStateCallbacks(
      onRelogging: authStateNotifier.startRelogging,
      onRelogSuccess: authStateNotifier.relogSuccess,
      onRelogFailed: authStateNotifier.relogFailed,
    ),
  );
  BasicHttpClientManager.initialize();
  EducationRefreshService.setCourseRefreshCallback(courseStore.loadCourses);

  if (!PlatformUtils.isMacOS) {
    requestPermissions();
  }

  if (PlatformUtils.isDesktop) {
    await windowManager.ensureInitialized();

    if (PlatformUtils.isMacOS) {
      WindowOptions windowOptions = const WindowOptions(
        minimumSize: Size(800, 600),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
        title: '光序',
      );

      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    } else {
      WindowOptions windowOptions = const WindowOptions(
        minimumSize: Size(800, 600),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
      );

      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }
  } else if (PlatformUtils.isIOS) {
    await IOSBackgroundService.initializeService();
    await IOSBackgroundService.startService();
  }

  if (PlatformUtils.isMacOS) {
    await _configureMacosWindowUtils();
  }

  // 先渲染 UI，再执行非关键初始化
  initApp(providerContainer);

  // 延后到首帧渲染之后：凭证迁移、请求缓存、后台服务等
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _deferredInit();
  });
}

/// 延后执行的非关键初始化，避免阻塞首帧渲染
Future<void> _deferredInit() async {
  // 凭证迁移（SecureStorage 在安卓上可能较慢）和请求缓存并行执行
  await Future.wait([
    AuthService.migrateCredentials(),
    RequestCache().initialize(),
  ]);

  if (PlatformUtils.isAndroid) {
    await FlutterDisplayMode.setHighRefreshRate();
    await BackgroundService.initializeService();
    await BackgroundService.startService();
  }

  if (PlatformUtils.isMobile) {
    await NotificationService.instance.initialize();
    Future.delayed(const Duration(seconds: 2), () async {
      await TaskExecutor.checkAndSendCourseReminder();
      await TaskExecutor.updateWidget();
    });
  }
}

/// 配置macOS窗口样式
Future<void> _configureMacosWindowUtils() async {
  const config = MacosWindowUtilsConfig();
  await config.apply();
}

void initApp(ProviderContainer container) {
  runApp(UncontrolledProviderScope(
    container: container,
    child: const _AppLauncher(),
  ));
}

class _AppLauncher extends ConsumerWidget {
  const _AppLauncher();

  Widget _buildAppShell(Widget child) {
    if (PlatformUtils.isWindows) {
      return WindowPage(child: child);
    }

    return MainApp(child: child);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsStore = ref.watch(settingsStoreProvider);
    final router = ref.watch(appRouterProvider);
    final locale = AppLocaleService.localeOf(settingsStore.localeCode);
    // 直接从 settingsStore 获取需要的字体信息
    final fontFamily = settingsStore.fontFamily.isEmpty
        ? PlatformUtils.getWindowsFontFamily()
        : PlatformUtils.getDesktopFontFamily(settingsStore.fontFamily);

    if (PlatformUtils.isMacOS) {
      return MacosApp.router(
        title: '光序',
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocaleService.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        theme: ClubTheme.macosLightTheme(),
        darkTheme: ClubTheme.macosDarkTheme(),
        themeMode: settingsStore.themeMode,
        routerConfig: router,
        builder: (context, child) => ClubMaterialThemeBridge(
          fontFamily: fontFamily,
          locale: locale,
          child: _buildAppShell(child ?? const SizedBox.shrink()),
        ),
      );
    }

    return MaterialApp.router(
      title: '光序',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocaleService.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ClubTheme.lightTheme(fontFamily: fontFamily, locale: locale),
      darkTheme: ClubTheme.darkTheme(fontFamily: fontFamily, locale: locale),
      themeMode: settingsStore.themeMode,
      routerConfig: router,
      builder: (context, child) =>
          _buildAppShell(child ?? const SizedBox.shrink()),
    );
  }
}

void requestPermissions() async {
  if (PlatformUtils.isWeb || PlatformUtils.isMacOS) {
    return;
  }

  await PermissionService.requestMultiple([
    Permission.notification,
    Permission.backgroundRefresh,
    Permission.storage,
  ]);
}

class WindowPage extends StatefulWidget {
  const WindowPage({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<WindowPage> createState() => _WindowPageState();
}

class _WindowPageState extends State<WindowPage>
    with WindowListener, TrayListener {
  bool _isPreventClose = true;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    trayManager.addListener(this);
    _init();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  void _init() async {
    await windowManager.setPreventClose(true);

    await trayManager.setIcon(
      PlatformUtils.isWindows ? 'assets/icon.ico' : 'assets/icon.webp',
    );
  }

  // 优化的退出方法
  Future<void> _exitApp() async {
    _isPreventClose = false;
    await windowManager.setPreventClose(false);
    // 使用 window_manager 的 destroy 方法代替 exit
    exit(0);
  }

  @override
  Widget build(BuildContext context) => MainApp(child: widget.child);

  @override
  void onWindowClose() async {
    if (_isPreventClose && mounted) {
      final l10n = context.l10n;
      // 显示退出选项
      PlatformDialog.showCustomDialog<void>(
        context,
        title: l10n.closeWindow,
        content: Text(l10n.closeWindowChoice),
        actions: [
          PlatformDialogAction<void>(label: l10n.cancel),
          PlatformDialogAction<void>(
            label: l10n.minimizeToTray,
            onPressed: () async {
              await windowManager.hide();
            },
          ),
          PlatformDialogAction<void>(
            label: l10n.quitApp,
            isDestructiveAction: true,
            onPressed: _exitApp,
          ),
        ],
      );
    }
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
  }
}
