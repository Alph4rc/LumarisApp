import 'package:flutter/foundation.dart';

// 在 web 环境中不导入 dart:io
// 创建一个安全的 Platform 访问方式
class _PlatformCheck {
  static bool _safeCheck(bool Function() check) {
    if (kIsWeb) return false;
    try {
      return check();
    } catch (e) {
      return false;
    }
  }
}

/// 统一的平台判断工具类
class PlatformUtils {
  static bool get isWeb => kIsWeb;

  static bool get isMacOS {
    return _PlatformCheck._safeCheck(() {
      // 动态导入以避免在 web 环境中出错
      if (kIsWeb) return false;
      // 在非 web 环境中，dart:io 是可用的
      // 使用字符串来避免编译时检查
      return _platformIsMacOS();
    });
  }

  static bool get isWindows {
    return _PlatformCheck._safeCheck(() {
      if (kIsWeb) return false;
      return _platformIsWindows();
    });
  }

  static bool get isLinux {
    return _PlatformCheck._safeCheck(() {
      if (kIsWeb) return false;
      return _platformIsLinux();
    });
  }

  static bool get isAndroid {
    return _PlatformCheck._safeCheck(() {
      if (kIsWeb) return false;
      return _platformIsAndroid();
    });
  }

  static bool get isIOS {
    return _PlatformCheck._safeCheck(() {
      if (kIsWeb) return false;
      return _platformIsIOS();
    });
  }

  static bool get isDesktop => isMacOS || isWindows || isLinux;
  static bool get isMobile => isAndroid || isIOS;

  /// 桌面平台的字体设置
  static String? getDesktopFontFamily(String? fontFamily) {
    if (!isDesktop) return null;
    return fontFamily?.isEmpty == true ? null : fontFamily;
  }

  /// Windows 平台的默认字体
  static String? getWindowsFontFamily() {
    return isWindows ? '微软雅黑' : null;
  }
}

// 这些函数使用动态导入来访问 Platform
// 在 web 环境中不会被调用
bool _platformIsMacOS() {
  // 这个函数只在非 web 环境中被调用
  // 使用 external 来延迟绑定
  try {
    // ignore: undefined_prefixed_name
    return _checkPlatform('macos');
  } catch (e) {
    return false;
  }
}

bool _platformIsWindows() {
  try {
    return _checkPlatform('windows');
  } catch (e) {
    return false;
  }
}

bool _platformIsLinux() {
  try {
    return _checkPlatform('linux');
  } catch (e) {
    return false;
  }
}

bool _platformIsAndroid() {
  try {
    return _checkPlatform('android');
  } catch (e) {
    return false;
  }
}

bool _platformIsIOS() {
  try {
    return _checkPlatform('ios');
  } catch (e) {
    return false;
  }
}

// 使用 Flutter 的 TargetPlatform 枚举来准确判断平台
bool _checkPlatform(String platform) {
  if (kIsWeb) return false;

  // 直接使用 Flutter 的 defaultTargetPlatform 枚举进行平台判断
  switch (platform) {
    case 'macos':
      return defaultTargetPlatform == TargetPlatform.macOS;
    case 'windows':
      return defaultTargetPlatform == TargetPlatform.windows;
    case 'linux':
      return defaultTargetPlatform == TargetPlatform.linux;
    case 'android':
      return defaultTargetPlatform == TargetPlatform.android;
    case 'ios':
      return defaultTargetPlatform == TargetPlatform.iOS;
    default:
      return false;
  }
}
