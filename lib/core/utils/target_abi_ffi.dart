import 'dart:ffi';

/// 返回当前运行环境的 Android ABI 名称，非 Android 平台返回 null。
///
/// 名字与 split-per-abi 产物的文件名一致（`app-<abi>-release.apk`）。
String? currentTargetAbi() {
  final abi = Abi.current();
  if (abi == Abi.androidArm64) return 'arm64-v8a';
  if (abi == Abi.androidArm) return 'armeabi-v7a';
  if (abi == Abi.androidX64) return 'x86_64';
  if (abi == Abi.androidIA32) return 'x86';
  return null;
}
