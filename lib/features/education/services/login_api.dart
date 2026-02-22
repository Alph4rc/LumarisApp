import 'dart:convert';

import '../../../core/services/network_exception.dart';
import '../models/login_response.dart';
import 'edu_http_client_manager.dart';

/// Login相关API
class LoginApi {
  /// 登录
  static Future<LoginResponse> login(String username, String password) async {
    try {
      final response = await EduHttpClientManager.instance.post(
        '/Login',
        data: {
          'username': username,
          'password': password,
        },
      );
      Map<String, dynamic> responseData;
      if (response is String) {
        responseData = jsonDecode(response);
      } else if (response is Map<String, dynamic>) {
        responseData = response;
      } else {
        throw NetworkException('登录返回格式错误', -1);
      }
      return LoginResponse.fromJson(responseData);
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
