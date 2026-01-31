import 'package:flutter/foundation.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/features/club/services/api_client.dart';
import 'package:ios_club_app/features/club/models/student_model.dart';
import 'package:ios_club_app/features/club/utils/api_response_helper.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

/// 认证服务类
///
/// 负责处理用户的登录、注册、登出、密码重置等认证相关功能。
/// 与后端API交互，处理认证流程和用户凭据管理。
class AuthService {
  /// 用户登录
  ///
  /// 向服务器发送登录请求，验证用户凭据并获取JWT令牌。
  /// 如果登录成功，将JWT令牌保存到本地存储。
  ///
  /// @param userId 用户ID（通常是学号）
  /// @param password 用户密码
  /// @param clientId 客户端ID（可选，用于OAuth2认证）
  /// @param scope 权限范围（可选，用于OAuth2认证）
  /// @return 登录成功返回JWT令牌，失败返回null
  static Future<String?> login(String userId, String password, {String clientId = '', String scope = ''}) async {
    try {
      final response = await ApiClient.post(
        '/Auth/login',
        body: {
          'userId': userId,
          'password': password,
        },
        withAuth: false,
      );

      final jwt = ApiResponseHelper.parseString(
        response,
        errorMessage: 'Login failed',
      );
      if (jwt != null) {
        final prefs = PrefsService.instance;
        await prefs.setString(PrefsKeys.MEMBER_JWT, jwt);
        return jwt;
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error during login: $e');
      }
    }
    return null;
  }

  /// 用户注册
  ///
  /// 向服务器发送注册请求，创建新用户账户。
  ///
  /// @param studentData 学生数据模型，包含注册所需的用户信息
  /// @return 注册成功返回true，失败返回false
  static Future<bool> signup(StudentModel studentData) async {
    try {
      final response = await ApiClient.post('/Auth/signup', body: studentData.toJson());
      return ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error during signup',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error during signup: $e');
      }
      return false;
    }
  }

  /// 用户登出
  ///
  /// 向服务器发送登出请求，清除用户的认证状态。
  ///
  /// @param userId 用户ID
  /// @param clientId 客户端ID（可选）
  /// @return 登出成功返回true，失败返回false
  static Future<bool> logout(String userId, {String clientId = ''}) async {
    try {
      final response = await ApiClient.post('/Auth/logout?userId=$userId');
      return ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error during logout',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error during logout: $e');
      }
      return false;
    }
  }

  /// 验证用户
  ///
  /// 向服务器发送请求，验证用户是否存在或是否有效。
  ///
  /// @param userId 用户ID
  /// @return 验证成功返回true，失败返回false
  static Future<bool> validate(String userId) async {
    try {
      final response = await ApiClient.get('/Auth/validate?userId=$userId');
      return ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error during validation',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error during validation: $e');
      }
      return false;
    }
  }

  /// 更改密码
  ///
  /// 向服务器发送请求，更改用户密码。
  ///
  /// @param userId 用户ID
  /// @param oldPassword 旧密码
  /// @param newPassword 新密码
  /// @return 密码更改成功返回true，失败返回false
  static Future<bool> changePassword(String userId, String oldPassword, String newPassword) async {
    try {
      final response = await ApiClient.put(
        '/Auth/change-password?userId=$userId&oldPassword=$oldPassword&newPassword=$newPassword');
      return ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error changing password',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error changing password: $e');
      }
      return false;
    }
  }

  /// 请求密码重置
  ///
  /// 向服务器发送请求，请求重置用户密码。
  /// 通常会向用户注册的邮箱或手机发送验证码。
  ///
  /// @param userId 用户ID
  /// @return 请求成功返回true，失败返回false
  static Future<bool> requestPasswordReset(String userId) async {
    try {
      final response = await ApiClient.post('/Auth/request-password-reset?userId=$userId');
      return ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error requesting password reset',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error requesting password reset: $e');
      }
      return false;
    }
  }

  /// 重置密码
  ///
  /// 使用验证码重置用户密码。
  /// 验证码通常通过请求密码重置时发送到用户的邮箱或手机。
  ///
  /// @param userId 用户ID
  /// @param code 验证码
  /// @param newPassword 新密码
  /// @return 密码重置成功返回true，失败返回false
  static Future<bool> resetPassword(String userId, String code, String newPassword) async {
    try {
      final response = await ApiClient.post(
        '/Auth/reset-password?userId=$userId&code=$code&newPassword=$newPassword');
      return ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error resetting password',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error resetting password: $e');
      }
      return false;
    }
  }

  /// 刷新令牌
  ///
  /// 使用刷新令牌获取新的访问令牌。
  ///
  /// @param userId 用户ID
  /// @param refreshToken 刷新令牌
  /// @param clientId 客户端ID（可选）
  /// @param scope 权限范围（可选）
  /// @return 刷新成功返回新的JWT令牌，失败返回null
  static Future<String?> refreshToken(String userId, String refreshToken, {String clientId = '', String scope = ''}) async {
    try {
      final response = await ApiClient.post(
        '/Auth/refresh-token?userId=$userId&refreshToken=$refreshToken&clientId=$clientId&scope=$scope');
      final jwt = ApiResponseHelper.parseString(
        response,
        errorMessage: 'Error refreshing token',
      );
      if (jwt != null) {
        final prefs = PrefsService.instance;
        await prefs.setString(PrefsKeys.MEMBER_JWT, jwt);
      }
      return jwt;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error refreshing token: $e');
      }
      return null;
    }
  }
}
