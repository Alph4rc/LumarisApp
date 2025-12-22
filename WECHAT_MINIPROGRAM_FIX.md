# 微信小程序平台兼容性修复

## 问题描述

在将 Flutter 应用编译为微信小程序时，遇到以下错误：

```
TypeError: Cannot read property 'toString' of undefined
```

## 根本原因

微信小程序基于 web 环境运行（使用 MPFlutter），但不支持 Dart 的 `dart:io` 库。应用中直接使用 `Platform.isX` 会导致运行时错误，因为：

1. `dart:io` 库在 web 编译目标中不可用
2. 直接导入 `dart:io` 会导致编译或运行时错误
3. `Platform` 对象在微信小程序环境中为 `undefined`

## 解决方案

### 1. 创建统一的平台检测工具类

创建了 `lib/core/utils/platform_utils.dart`，提供所有平台检测功能：

```dart
import 'package:flutter/foundation.dart';

class PlatformUtils {
  static bool get isWeb => kIsWeb;
  static bool get isMPFlutter => _isMPFlutter;

  static bool get isMacOS => _checkPlatform('macos');
  static bool get isWindows => _checkPlatform('windows');
  static bool get isLinux => _checkPlatform('linux');
  static bool get isAndroid => _checkPlatform('android');
  static bool get isIOS => _checkPlatform('ios');

  static bool get isDesktop => isMacOS || isWindows || isLinux;
  static bool get isMobile => isAndroid || isIOS;
}

// 使用 defaultTargetPlatform 而不是 Platform 来检测平台
bool _checkPlatform(String platform) {
  if (kIsWeb) return false;
  final targetPlatform = defaultTargetPlatform.toString().toLowerCase();
  return targetPlatform.contains(platform);
}
```

**关键设计决策：**
- 完全避免导入 `dart:io`
- 使用 `defaultTargetPlatform`（来自 `package:flutter/foundation.dart`）进行平台检测
- 在所有环境（包括 web 和微信小程序）中都能安全工作
- 通过 `bool.fromEnvironment('MPFLUTTER')` 检测微信小程序环境

### 2. 替换所有 Platform 引用

将所有直接使用 `Platform.isX` 或 `kIsWeb` 的代码替换为 `PlatformUtils`：

**修复前：**
```dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

if (!kIsWeb && Platform.isAndroid) {
  // Android 特定代码
}
```

**修复后：**
```dart
import 'package:ios_club_app/core/utils/platform_utils.dart';

if (PlatformUtils.isAndroid) {
  // Android 特定代码
}
```

### 3. 修复的文件列表

以下文件已更新为使用 `PlatformUtils`：

1. **lib/main.dart**
   - 移除 `dart:io` 导入
   - 使用 `windowManager.destroy()` 代替 `exit(0)`
   - 从 MPFlutter 包导入 `runMPApp` 和 `wx`

2. **lib/main_app.dart**
   - 移除未使用的 `dart:io` 导入

3. **lib/core/utils/platform_utils.dart**
   - 使用 `defaultTargetPlatform` 代替 `Platform`
   - 完全移除 `dart:io` 依赖

4. **lib/ui/pages/schedule_list_page.dart**
   - 替换所有平台检测为 `PlatformUtils`

5. **lib/ui/pages/schedule_setting_page.dart**
   - 替换平台检测

6. **lib/ui/pages/setting_page.dart**
   - 移除未使用的 `dart:io` 导入

7. **lib/ui/components/homePages/schedule_widget.dart**
   - 替换平台检测

8. **lib/ui/components/settingPages/version_setting.dart**
   - 替换平台检测

9. **lib/ui/components/platform_dialog.dart**
   - 替换所有平台检测

10. **lib/features/system/update/check_update_manager.dart**
    - 替换平台检测
    - 移除 `Platform.environment` 访问

### 4. 构建脚本更新

修改 `scripts/build_wechat.dart` 添加 `--no-tree-shake-icons` 标志：

```dart
import 'package:mpflutter_build_tools/main.dart' as build_tools;

void main(List<String> arguments) async {
  final buildArgs = List<String>.from(arguments)
    ..add('--wechat')
    ..add('--no-tree-shake-icons');  // 避免图标字体问题
  build_tools.main(buildArgs);
}
```

## 使用指南

### 开发新功能时

**✅ 正确做法：**
```dart
import 'package:ios_club_app/core/utils/platform_utils.dart';

// 检查特定平台
if (PlatformUtils.isAndroid) { }
if (PlatformUtils.isIOS) { }
if (PlatformUtils.isWindows) { }
if (PlatformUtils.isMacOS) { }
if (PlatformUtils.isLinux) { }
if (PlatformUtils.isWeb) { }
if (PlatformUtils.isMPFlutter) { }

// 检查平台类别
if (PlatformUtils.isDesktop) { }  // Windows || macOS || Linux
if (PlatformUtils.isMobile) { }   // Android || iOS

// 桌面字体设置
fontFamily: PlatformUtils.getWindowsFontFamily()
fontFamily: PlatformUtils.getDesktopFontFamily(customFont)
```

**❌ 错误做法：**
```dart
import 'dart:io';
import 'package:flutter/foundation.dart';

// 这会在微信小程序中导致 TypeError
if (!kIsWeb && Platform.isWindows) { }
if (Platform.isAndroid) { }
```

### 构建微信小程序

```bash
# 标准构建
dart scripts/build_wechat.dart

# 调试构建（包含源码映射，可在微信开发者工具中调试 Dart 源码）
dart scripts/build_wechat.dart --debug
```

## 技术细节

### 为什么 Platform.isX 会失败？

1. **编译时问题：** `dart:io` 在 web 编译目标中不可用
2. **运行时问题：** 即使通过某些方式编译通过，`Platform` 对象在 web 环境中为 `undefined`
3. **微信小程序环境：** MPFlutter 将 Flutter 编译为 web，但微信小程序有更严格的限制

### defaultTargetPlatform 的优势

`defaultTargetPlatform` 是 Flutter 框架提供的跨平台 API：
- 在所有环境中都可用（包括 web）
- 返回 `TargetPlatform` 枚举值
- 在 web 环境中返回正确的平台标识
- 不依赖于 `dart:io`

### 微信小程序检测

使用编译时常量：
```dart
const bool kIsMPFlutter = bool.fromEnvironment('MPFLUTTER', defaultValue: false);
```

MPFlutter 构建工具会自动设置此环境变量。

## 验证

运行以下命令确保没有残留的 `Platform.isX` 引用：

```bash
# 搜索直接使用 Platform 的代码（应该为空）
grep -r "Platform\.is" lib/ --exclude-dir=platform_utils.dart

# 运行静态分析
flutter analyze

# 构建微信小程序
dart scripts/build_wechat.dart
```

## 测试结果

✅ **构建成功**
- Flutter web 编译通过
- 微信小程序产物生成成功
- 产物位置：`build/wechat`

✅ **代码质量**
- 静态分析通过
- 只有预期的 linter 警告
- 所有 Platform 引用已替换

## 相关文档

- [MPFlutter 官方文档](https://mpflutter.com/)
- [Flutter Web 平台](https://docs.flutter.dev/platform-integration/web)
- [Flutter Platform Integration](https://docs.flutter.dev/platform-integration)

## 更新日志

- **2025-01-23:** 完全移除 `dart:io` 依赖，使用 `defaultTargetPlatform` 进行平台检测
- **2025-01-23:** 修复所有文件中的 `Platform.isX` 引用（共10个文件）
- **2025-01-23:** 更新构建脚本添加 `--no-tree-shake-icons`
- **2025-01-23:** 使用 MPFlutter 包提供的 `runMPApp` 和 `wx`
- **2025-01-23:** 成功构建并验证微信小程序版本
