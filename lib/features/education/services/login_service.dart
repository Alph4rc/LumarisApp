import 'dart:convert';

import '../../../core/services/network_exception.dart';
import 'edu_http_client.dart';

/// 登录服务
class LoginService {
  static final EduHttpClient _client = EduHttpClient();

  /// 登录
  /// [username] 用户名
  /// [password] 密码
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _client.post(
        '/Login',
        data: {
          'username': username,
          'password': password,
        },
      );
      if (response is Map<String, dynamic>) {
        return response;
      } else if (response is String) {
        return jsonDecode(response);
      } else {
        throw NetworkException('登录返回格式错误', -1);
      }
    } catch (e) {
      if (e is NetworkException) {
        rethrow;
      } else {
        throw NetworkException('登录失败: $e', -1);
      }
    }
  }
}