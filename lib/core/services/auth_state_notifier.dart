import 'package:get/get.dart';

/// 认证状态
enum AuthState {
  /// 正常状态
  normal,

  /// 正在重新登录
  relogging,

  /// 重新登录成功
  relogSuccess,

  /// 重新登录失败
  relogFailed,
}

/// 全局认证状态通知器
///
/// 用于在401错误触发重登录时通知UI层，让用户知道正在重新登录
/// 避免用户误以为应用卡住了
class AuthStateNotifier extends GetxController {
  static AuthStateNotifier get to => Get.find();

  final _authState = AuthState.normal.obs;
  final _relogMessage = ''.obs;

  AuthState get authState => _authState.value;
  String get relogMessage => _relogMessage.value;

  /// 是否正在重新登录
  bool get isRelogging => _authState.value == AuthState.relogging;

  /// 开始重新登录
  void startRelogging() {
    _authState.value = AuthState.relogging;
    _relogMessage.value = '登录已过期，正在重新登录...';
  }

  /// 重新登录成功
  void relogSuccess() {
    _authState.value = AuthState.relogSuccess;
    _relogMessage.value = '重新登录成功';

    // 2秒后恢复正常状态
    Future.delayed(const Duration(seconds: 2), () {
      if (_authState.value == AuthState.relogSuccess) {
        _authState.value = AuthState.normal;
        _relogMessage.value = '';
      }
    });
  }

  /// 重新登录失败
  void relogFailed(String reason) {
    _authState.value = AuthState.relogFailed;
    _relogMessage.value = '重新登录失败: $reason';

    // 5秒后恢复正常状态
    Future.delayed(const Duration(seconds: 5), () {
      if (_authState.value == AuthState.relogFailed) {
        _authState.value = AuthState.normal;
        _relogMessage.value = '';
      }
    });
  }

  /// 重置状态
  void reset() {
    _authState.value = AuthState.normal;
    _relogMessage.value = '';
  }
}
