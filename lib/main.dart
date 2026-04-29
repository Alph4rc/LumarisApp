import 'dart:async';
import 'dart:io';

import 'package:display_mode/display_mode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/services/auth_state_notifier.dart';
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
import 'package:ios_club_app/features/system/notifications/task_executor.dart';
import 'package:ios_club_app/features/system/widget_service.dart';
import 'package:ios_club_app/platform/android/background_service.dart';
import 'package:ios_club_app/platform/ios/background_service.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'main_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.info('iOS Club App 启动中...');

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
        title: 'iOS Club App',
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

String? _getFontFamily(ProviderContainer container) {
  if (PlatformUtils.isDesktop) {
    final settingsStore = container.read(settingsStoreProvider.notifier);
    // 如果设置了自定义字体，则使用自定义字体，否则使用系统默认字体
    return PlatformUtils.getDesktopFontFamily(settingsStore.fontFamily);
  }
  // Windows 平台返回默认字体
  return PlatformUtils.getWindowsFontFamily();
}

Widget _getHomePage() {
  // Windows 平台返回 WindowPage
  if (PlatformUtils.isWindows) {
    return const WindowPage();
  }

  return const MainApp();
}

void initApp(ProviderContainer container) {
  if (PlatformUtils.isMacOS) {
    runApp(UncontrolledProviderScope(
      container: container,
      child: MacosApp(
        title: 'iOS Club App',
        debugShowCheckedModeBanner: false,
        theme: MacosThemeData.light().copyWith(
          primaryColor: CupertinoColors.systemBlue,
          pushButtonTheme: const PushButtonThemeData(
            color: CupertinoColors.systemBlue,
            secondaryColor: CupertinoColors.systemGrey,
          ),
          // 帮助按钮主题
          helpButtonTheme: const HelpButtonThemeData(
            color: CupertinoColors.systemBlue,
          ),
        ),
        darkTheme: MacosThemeData.dark().copyWith(
          primaryColor: CupertinoColors.systemBlue,
          brightness: Brightness.dark,
          pushButtonTheme: const PushButtonThemeData(
            color: CupertinoColors.systemBlue,
            secondaryColor: CupertinoColors.systemGrey,
          ),
          helpButtonTheme: const HelpButtonThemeData(
            color: CupertinoColors.systemBlue,
          ),
        ),
        // 跟随系统设置自动切换亮暗模式
        themeMode: ThemeMode.system,
        home: const MainApp(),
      ),
    ));
    return;
  }

  runApp(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      title: 'iOS Club App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: _getFontFamily(container),
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        fontFamily: _getFontFamily(container),
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: _getHomePage(),
    ),
  ));
}

void requestPermissions() async {
  if (PlatformUtils.isWeb || PlatformUtils.isMacOS) {
    return;
  }

  await PermissionService.requestMultiple([
    Permission.notification,
    Permission.backgroundRefresh,
    Permission.storage,
    Permission.requestInstallPackages,
  ]);
}

class WindowPage extends StatefulWidget {
  const WindowPage({super.key});

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
  Widget build(BuildContext context) => const MainApp();

  @override
  void onWindowClose() async {
    if (_isPreventClose && mounted) {
      // 显示退出选项
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('关闭窗口'),
            content: const Text('选择您要执行的操作'),
            actions: [
              TextButton(
                child: const Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('最小化到任务栏'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await windowManager.hide();
                },
              ),
              TextButton(
                child: const Text('退出程序'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _exitApp();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
  }
}
