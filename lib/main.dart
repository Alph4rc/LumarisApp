import 'dart:async';
import 'dart:io';

import 'package:display_mode/display_mode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/platform/android/background_service.dart';
import 'package:ios_club_app/state/init.dart';
import 'package:ios_club_app/platform/ios/background_service.dart';
import 'package:ios_club_app/core/utils/request_cache.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/system/widget_service.dart';
import 'package:ios_club_app/features/system/notifications/task_executor.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:ios_club_app/core/services/permission_service.dart';
import 'package:ios_club_app/core/services/auth_state_notifier.dart';
import 'package:ios_club_app/features/education/services/edu_http_client.dart';
import 'package:ios_club_app/features/education/services/edu_http_client_manager.dart';
import 'package:ios_club_app/features/education/services/education_refresh_service.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'main_app.dart';
import 'package:ios_club_app/core/services/hive_manager.dart';
import 'package:ios_club_app/features/education/services/auth_service.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:ios_club_app/state/settings_store.dart';

void main() async {
  // 确保在所有平台上都初始化 WidgetsFlutterBinding
  WidgetsFlutterBinding.ensureInitialized();

  // 日志系统已就绪（AppLogger 是静态类，无需初始化）
  AppLogger.info('iOS Club App 启动中...');

  // 初始化 Hive 数据库
  await HiveManager.init();

  // 初始化 SharedPreferences（最先初始化，其他服务可能依赖它）
  await PrefsService.init();

  if (PlatformUtils.isIOS) {
    await WidgetService.initialize();
  }

  // 尝试迁移旧的凭证数据到安全存储
  await AuthService.migrateCredentials();

  // 初始化请求缓存
  await RequestCache().initialize();

  // 初始化Stores
  initStores();
  EduHttpClientManager.initialize(
    school: SettingsStore.to.currentSchool,
    authStateCallbacks: AuthStateCallbacks(
      onRelogging: AuthStateNotifier.to.startRelogging,
      onRelogSuccess: AuthStateNotifier.to.relogSuccess,
      onRelogFailed: AuthStateNotifier.to.relogFailed,
    ),
  );
  EducationRefreshService.setCourseRefreshCallback(CourseStore.to.loadCourses);

  // 平台特定初始化 - 使用统一的平台判断
  if (!PlatformUtils.isMacOS) {
    requestPermissions();
  }

  if (PlatformUtils.isDesktop) {
    // 初始化 window_manager
    await windowManager.ensureInitialized();

    // 根据平台配置不同的窗口选项
    if (PlatformUtils.isMacOS) {
      // macOS 专用窗口配置
      WindowOptions windowOptions = const WindowOptions(
        minimumSize: Size(800, 600),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
        // 隐藏标题栏以使用原生macOS样式
        title: 'iOS Club App',
      );

      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    } else {
      // 其他桌面平台的窗口配置
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
  } else if (PlatformUtils.isAndroid) {
    // 只在Android平台调用FlutterDisplayMode
    await FlutterDisplayMode.setHighRefreshRate();
    await BackgroundService.initializeService();
    await BackgroundService.startService();
  } else if (PlatformUtils.isIOS) {
    await IOSBackgroundService.initializeService();
    await IOSBackgroundService.startService();
  }

  if (PlatformUtils.isMacOS) {
    await _configureMacosWindowUtils();
  }

  // 在所有初始化完成后，预先安排今日课程通知和刷新小组件
  // 注意：不依赖后台执行，flutter_local_notifications.zonedSchedule 是 OS 级别调度
  // 延迟执行，确保所有 Store 和 Service 完全就绪
  if (PlatformUtils.isMobile) {
    Future.delayed(const Duration(seconds: 2), () async {
      await TaskExecutor.checkAndSendCourseReminder();
      await TaskExecutor.updateWidget();
    });
  }

  initApp();
}

/// 配置macOS窗口样式
Future<void> _configureMacosWindowUtils() async {
  const config = MacosWindowUtilsConfig();
  await config.apply();
}

String? _getFontFamily() {
  if (PlatformUtils.isDesktop) {
    // 获取设置存储实例
    final settingsStore = SettingsStore.to;
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

void initApp() {
  if (PlatformUtils.isMacOS) {
    runApp(MacosApp(
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
    ));
    return;
  }

  runApp(MaterialApp(
    title: 'iOS Club App',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: _getFontFamily(),
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
    ),
    darkTheme: ThemeData(
      fontFamily: _getFontFamily(),
      brightness: Brightness.dark,
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    ),
    home: _getHomePage(),
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
