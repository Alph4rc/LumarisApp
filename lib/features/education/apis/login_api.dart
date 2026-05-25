import 'dart:convert';

import '../../../core/services/network_exception.dart';
import '../models/api_response.dart';
import '../models/login_response.dart';
import '../services/edu_http_client_manager.dart';

/// Login相关API — v1.yaml tag: LoginV1
class LoginApi {
  /// POST /v1/login → ApiResponseOfLoginResponse
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

      final apiResponse = ApiResponse<LoginResponse>.parsed(
        responseData,
        (data) => LoginResponse.fromJson(Map<String, dynamic>.from(data as Map)),
      );
      if (!apiResponse.isSuccess) {
        throw NetworkException(
          apiResponse.message ?? '登录失败',
          -1,
        );
      }
      return apiResponse.data ?? LoginResponse();
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
