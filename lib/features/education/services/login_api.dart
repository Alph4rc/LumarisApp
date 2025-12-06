import 'dart:convert';

import '../../../core/services/network_exception.dart';
import 'edu_http_client.dart';

/// Login相关API
class LoginApi {
  static final EduHttpClient _client = EduHttpClient();

  /// 登录
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _client.post(
        '/Login',
        data: {
          'username': username,
          'password': password,
        },
      );
      if (response is String) {
        return jsonDecode(response);
      } else if (response is Map<String, dynamic>) {
        return response;
      } else {
        throw NetworkException('登录返回格式错误', -1);
      }
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  static void _handleError(dynamic e) {
    if (e is! NetworkException) {
      throw NetworkException('未知错误', -1);
    }
  }
}
