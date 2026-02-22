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
import 'package:ios_club_app/features/system/update/check_update_manager.dart';
import 'package:ios_club_app/platform/ios/background_service.dart';
import 'package:ios_club_app/core/utils/performance_monitor.dart';
import 'package:ios_club_app/core/utils/request_cache.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'main_app.dart';
import 'package:ios_club_app/features/education/services/edu_service.dart';
import 'package:ios_club_app/state/settings_store.dart';

import 'package:mpflutter_core/mpflutter_core.dart' show runMPApp;
import 'package:mpflutter_wechat_api/mpflutter_wechat_api.dart' show wx;

void main() async {
  // 确保在所有平台上都初始化 WidgetsFlutterBinding
  WidgetsFlutterBinding.ensureInitialized();

  // 日志系统已就绪（AppLogger 是静态类，无需初始化）
  AppLogger.info('iOS Club App 启动中...');

  // 在微信小程序环境中，跳过大部分平台特定的初始化
  if (PlatformUtils.isMPFlutter) {
    // 初始化 SharedPreferences
    await PrefsService.init();
    // 只初始化必要的 Stores
    initStores();
    // 直接启动应用
    initApp();
    return;
  }

  // 以下代码只在非微信小程序环境中执行

  // 初始化 SharedPreferences（最先初始化，其他服务可能依赖它）
  await PrefsService.init();

  // 尝试迁移旧的凭证数据到安全存储
  await EduService.migrateCredentials();

  // 初始化性能监控
  PerformanceMonitor().initialize();

  // 初始化请求缓存
  await RequestCache().initialize();

  // 初始化Stores
  initStores();

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

  // 初始化更新管理器
  await CheckUpdateManager.init();

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
  // 在微信小程序环境中，直接返回 MainApp
  if (PlatformUtils.isMPFlutter) {
    return const MainApp();
  }

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

  if (PlatformUtils.isMPFlutter) {
    try {
      wx.$$context$$;
      runMPApp(MaterialApp(
        title: 'iOS Club App',
        debugShowCheckedModeBanner: false,
        home: const MainApp(),
      ));
      return;
    } catch (e) {
      //
    }
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
  // 在 Web、微信小程序和 macOS 平台中不请求权限，避免 MissingPluginException
  if (PlatformUtils.isWeb ||
      PlatformUtils.isMPFlutter ||
      PlatformUtils.isMacOS) {
    return;
  }

  List<Permission> permissions = [
    Permission.notification,
    Permission.backgroundRefresh,
    Permission.storage,
    Permission.requestInstallPackages,
  ];

  // 只请求尚未授予的权限
  List<Permission> permissionsToRequest = [];
  for (var permission in permissions) {
    PermissionStatus status = await permission.status;
    if (status != PermissionStatus.granted) {
      permissionsToRequest.add(permission);
    }
  }

  if (permissionsToRequest.isNotEmpty) {
    await permissionsToRequest.request();
  }
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
