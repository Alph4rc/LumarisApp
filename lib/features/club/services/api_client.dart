import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/core/services/base_http_client.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

/// 俱乐部 API 客户端
///
/// 提供与俱乐部后端 API 的通信功能，支持：
/// - 自动添加认证头
/// - 请求缓存
/// - 统一的错误处理和重试机制
class ApiClient {
  static const String _baseUrl = 'https://api.xauat.site';
  static final BaseHttpClient _client = BaseHttpClient(
    baseUrl: _baseUrl,
    enableCache: true,
  );

  /// 获取请求头
  static Future<Map<String, dynamic>> _getAuthHeaders() async {
    final headers = <String, dynamic>{};
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString(PrefsKeys.MEMBER_JWT);
    if (jwt != null) {
      headers['Authorization'] = 'Bearer $jwt';
    }
    return headers;
  }

  /// GET 请求
  static Future<dynamic> get(
    String path, {
    bool withAuth = true,
    bool useCache = true,
  }) async {
    if (kDebugMode) {
      AppLogger.debug('GET $_baseUrl$path');
    }

    Options? options;
    if (withAuth) {
      final authHeaders = await _getAuthHeaders();
      options = Options(headers: authHeaders);
    }

    return _client.get(path, options: options);
  }

  /// POST 请求
  static Future<dynamic> post(
    String path, {
    dynamic body,
    bool withAuth = true,
  }) async {
    if (kDebugMode) {
      AppLogger.debug('POST $_baseUrl$path');
      if (body != null) {
        AppLogger.debug('Body: $body');
      }
    }

    Options? options;
    if (withAuth) {
      final authHeaders = await _getAuthHeaders();
      options = Options(headers: authHeaders);
    }

    return _client.post(path, data: body, options: options);
  }

  /// PUT 请求
  static Future<dynamic> put(
    String path, {
    dynamic body,
    bool withAuth = true,
  }) async {
    if (kDebugMode) {
      AppLogger.debug('PUT $_baseUrl$path');
      if (body != null) {
        AppLogger.debug('Body: $body');
      }
    }

    Options? options;
    if (withAuth) {
      final authHeaders = await _getAuthHeaders();
      options = Options(headers: authHeaders);
    }

    return _client.put(path, data: body, options: options);
  }

  /// DELETE 请求
  static Future<dynamic> delete(String path, {bool withAuth = true}) async {
    if (kDebugMode) {
      AppLogger.debug('DELETE $_baseUrl$path');
    }

    Options? options;
    if (withAuth) {
      final authHeaders = await _getAuthHeaders();
      options = Options(headers: authHeaders);
    }

    return _client.delete(path, options: options);
  }
}
