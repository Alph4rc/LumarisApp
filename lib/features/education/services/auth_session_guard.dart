/// 登录代际守卫
///
/// 登出（或任何清空教务会话的操作）会递增代际号。所有网络登录在写回
/// `USER_DATA` 前必须确认代际未变，避免登出瞬间仍在途的登录请求把
/// 登录态重新写回本地。
class AuthSessionGuard {
  AuthSessionGuard._();

  static int _epoch = 0;

  /// 当前登录代际。
  static int get epoch => _epoch;

  /// 使所有在途登录结果失效。
  ///
  /// 必须在清空用户数据之前调用，让后续写入无法通过代际校验。
  static void invalidate() {
    _epoch++;
  }

  /// [capturedEpoch] 是否仍对应当前会话。
  static bool isCurrent(int capturedEpoch) => capturedEpoch == _epoch;
}
