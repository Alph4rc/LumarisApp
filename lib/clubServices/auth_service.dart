import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ios_club_app/stores/prefs_keys.dart';
import 'package:ios_club_app/clubServices/api_client.dart';
import 'package:ios_club_app/clubModels/student_model.dart';

class AuthService {
  /// 用户登录
  static Future<String?> login(String userId, String password, {String clientId = '', String scope = ''}) async {
    try {
      final Map<String, String> finalHeaders = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        Uri.parse('https://api.xauat.site/Auth/login'),
        headers: finalHeaders,
        body: jsonEncode({
          'userId': userId,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final jwt = response.body.replaceAll('"', '');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(PrefsKeys.MEMBER_JWT, jwt);
        return jwt;
      } else {
        if (kDebugMode) {
          print('Login failed with status: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during login: $e');
      }
    }
    return null;
  }

  /// 用户注册
  static Future<bool> signup(StudentModel studentData) async {
    try {
      final response = await ApiClient.post('/Auth/signup', body: studentData.toJson());
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during signup: $e');
      }
    }
    return false;
  }

  /// 用户登出
  static Future<bool> logout(String userId, {String clientId = ''}) async {
    try {
      final response = await ApiClient.post('/Auth/logout?userId=$userId');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during logout: $e');
      }
    }
    return false;
  }

  /// 验证用户
  static Future<bool> validate(String userId) async {
    try {
      final response = await ApiClient.get('/Auth/validate?userId=$userId');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during validation: $e');
      }
    }
    return false;
  }

  /// 更改密码
  static Future<bool> changePassword(String userId, String oldPassword, String newPassword) async {
    try {
      final response = await ApiClient.put(
        '/Auth/change-password?userId=$userId&oldPassword=$oldPassword&newPassword=$newPassword');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error changing password: $e');
      }
    }
    return false;
  }

  /// 请求密码重置
  static Future<bool> requestPasswordReset(String userId) async {
    try {
      final response = await ApiClient.post('/Auth/request-password-reset?userId=$userId');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting password reset: $e');
      }
    }
    return false;
  }

  /// 重置密码
  static Future<bool> resetPassword(String userId, String code, String newPassword) async {
    try {
      final response = await ApiClient.post(
        '/Auth/reset-password?userId=$userId&code=$code&newPassword=$newPassword');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting password: $e');
      }
    }
    return false;
  }
}