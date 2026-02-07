import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import '../../../state/prefs_keys.dart';
import '../../../core/utils/request_cache.dart';
import '../../../core/services/retry_policy.dart';
import '../../../core/config/api_config.dart';
import 'login_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

class EduHttpClient {
  final Dio _dio;
  String _baseUrl;

  /// 全局登录锁，确保同一时间只有一个登录请求
  static Completer<bool>? _loginCompleter;

  /// 最后一次登录失败的时间戳，用于防止频繁重试
  static int? _lastLoginFailTime;

  /// 登录失败后的冷却时间（毫秒）
  static const int _loginCooldownMs = 5000;

  EduHttpClient({Dio? dio, String? baseUrl})
      : _dio = dio ?? Dio(),
        _baseUrl = baseUrl ?? ApiConfig.getDefaultSchool().eduApiBaseUrl {
    _setupDio();
  }

  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      contentType: 'application/json',
    );

    // 添加重试拦截器（使用统一的重试策略）
    _dio.interceptors.add(RetryInterceptor(
      dio: _dio,
      policy: const RetryPolicy(maxRetries: 2),
    ));

    // 添加缓存拦截器
    _dio.interceptors.add(CacheInterceptor());

    // 添加认证拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 自动添加认证cookie
        final cookie = await _getCookie();
        if (cookie != null) {
          options.headers['Cookie'] = cookie;
          options.headers['xauat'] = cookie;
        }
        handler.next(options);
      },
      onError: (DioException e, handler) async {
        final statusCode = e.response?.statusCode;

        // 只在认证相关错误（401/403）时尝试重登录
        if (statusCode == 401 || statusCode == 403) {
          try {
            // 使用全局登录锁，确保同一时间只有一个登录请求
            if (await _reLoginWithLock()) {
              // 重登录成功，重新发送请求
              final cookie = await _getCookie();
              if (cookie != null) {
                e.requestOptions.headers['Cookie'] = cookie;
                e.requestOptions.headers['xauat'] = cookie;
              }
              final response = await _dio.request(
                e.requestOptions.path,
                options: Options(
                  method: e.requestOptions.method,
                  headers: e.requestOptions.headers,
                  contentType: e.requestOptions.contentType,
                ),
                data: e.requestOptions.data,
                queryParameters: e.requestOptions.queryParameters,
              );
              return handler.resolve(response);
            }
          } catch (retryError) {
            // 重新请求失败，继续处理原错误
            AppLogger.debug('重登录后请求失败: $retryError');
          }
        }

        // 处理其他错误
        handler.next(e);
      },
    ));
  }

  /// 获取当前基础 URL
  String get baseUrl => _baseUrl;

  /// 更新基础 URL
  ///
  /// 用于切换学校时更新 API 地址
  void updateBaseUrl(String newBaseUrl) {
    _baseUrl = newBaseUrl;
    _dio.options.baseUrl = newBaseUrl;
  }

  Future<String?> _getCookie() async {
    final prefs = PrefsService.instance;
    final userDataJson = prefs.getString(PrefsKeys.USER_DATA);
    if (userDataJson != null) {
      final userData = jsonDecode(userDataJson);
      return userData['cookie'];
    }
    return null;
  }

  /// 带全局锁的重登录方法
  ///
  /// 确保同一时间只有一个登录请求在执行，其他请求等待并复用结果
  Future<bool> _reLoginWithLock() async {
    // 检查是否在冷却期内（防止频繁重试）
    if (_lastLoginFailTime != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastLoginFailTime! < _loginCooldownMs) {
        AppLogger.debug('登录冷却中，跳过重登录');
        return false;
      }
    }

    // 如果已有登录请求在进行中，等待其完成
    if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
      AppLogger.debug('等待其他登录请求完成...');
      return await _loginCompleter!.future;
    }

    // 创建新的登录 Completer
    _loginCompleter = Completer<bool>();
    AppLogger.debug('开始重登录...');

    try {
      final success = await _reLogin();

      if (success) {
        AppLogger.debug('重登录成功');
        _lastLoginFailTime = null; // 清除失败时间戳
      } else {
        AppLogger.debug('重登录失败');
        _lastLoginFailTime = DateTime.now().millisecondsSinceEpoch;
      }

      // 完成 Completer，通知所有等待的请求
      _loginCompleter!.complete(success);
      return success;
    } catch (e) {
      AppLogger.error('重登录异常', error: e);
      _lastLoginFailTime = DateTime.now().millisecondsSinceEpoch;
      _loginCompleter!.complete(false);
      return false;
    } finally {
      // 延迟清理 Completer，给其他等待的请求一点时间获取结果
      Future.delayed(const Duration(milliseconds: 100), () {
        _loginCompleter = null;
      });
    }
  }

  Future<bool> _reLogin() async {
    try {
      final prefs = PrefsService.instance;
      final username = prefs.getString(PrefsKeys.USERNAME);
      final password = prefs.getString(PrefsKeys.PASSWORD);

      if (username == null || password == null) {
        return false;
      }

      final loginResult = await LoginService.login(username, password);

      if (loginResult['success'] == true) {
        await prefs.setString(PrefsKeys.USER_DATA, jsonEncode(loginResult));
        return true;
      }

      return false;
    } catch (e) {
      AppLogger.debug('重登录失败: $e');
      return false;
    }
  }

  // 通用GET请求方法
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      DioErrorHandler.handleError(e);
    }
  }

  // 通用POST请求方法
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      DioErrorHandler.handleError(e);
    }
  }

  void dispose() {
    _dio.close();
  }
}
