import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

/// 安全存储服务
///
/// 使用 flutter_secure_storage 存储敏感信息（如密码、Token等）
class SecureStorageService {
  SecureStorageService._();

  static final SecureStorageService _instance = SecureStorageService._();

  static SecureStorageService get instance => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  /// 保存字符串
  Future<void> write({required String key, required String? value}) async {
    try {
      if (value == null) {
        await _storage.delete(key: key);
      } else {
        await _storage.write(key: key, value: value);
      }
    } catch (e, stackTrace) {
      AppLogger.error('SecureStorage write error',
          error: e, stackTrace: stackTrace);
    }
  }

  /// 读取字符串
  Future<String?> read({required String key}) async {
    try {
      return await _storage.read(key: key);
    } catch (e, stackTrace) {
      AppLogger.error('SecureStorage read error',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// 删除
  Future<void> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
    } catch (e, stackTrace) {
      AppLogger.error('SecureStorage delete error',
          error: e, stackTrace: stackTrace);
    }
  }

  /// 清除所有
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e, stackTrace) {
      AppLogger.error('SecureStorage deleteAll error',
          error: e, stackTrace: stackTrace);
    }
  }
}
