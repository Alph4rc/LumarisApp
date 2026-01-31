import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../state/prefs_keys.dart';
import '../../../core/utils/request_cache.dart';
import '../../../core/services/network_exception.dart';
import '../../../core/config/api_config.dart';
import 'login_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

class EduHttpClient {
  final Dio _dio;
  final int _maxRetryCount = 2;
  String _baseUrl;

  /// 标记是否正在重登录，避免重复触发
  bool _isRelogging = false;

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

        // 只在认证相关错误（401/403）且未在重登录中时尝试重登录
        if ((statusCode == 401 || statusCode == 403) && !_isRelogging) {
          _isRelogging = true;
          try {
            if (await _reLogin()) {
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
              _isRelogging = false;
              return handler.resolve(response);
            }
          } catch (retryError) {
            // 重新请求失败，继续处理原错误
            AppLogger.debug('重登录后请求失败: $retryError');
          } finally {
            _isRelogging = false;
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
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString(PrefsKeys.USER_DATA);
    if (userDataJson != null) {
      final userData = jsonDecode(userDataJson);
      return userData['cookie'];
    }
    return null;
  }

  Future<bool> _reLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString(PrefsKeys.USERNAME);
      final password = prefs.getString(PrefsKeys.PASSWORD);
      
      if (username == null || password == null) {
        return false;
      }
      
      // 注意：LoginService是一个类，需要实例化或使用静态方法
      // 这里假设LoginService.login是一个静态方法
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
    String path,
    {Map<String, dynamic>? queryParameters,
    Options? options,
    int retryCount = 0}
  ) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      // 如果response.data已经是Map或List，直接返回，否则返回原始数据
      return response.data;
    } on DioException catch (e) {
      // 只在网络超时等临时错误时重试，认证错误由拦截器处理
      if (retryCount < _maxRetryCount && _shouldRetry(e)) {
        return get(
          path,
          queryParameters: queryParameters,
          options: options,
          retryCount: retryCount + 1,
        );
      }
      _handleDioError(e);
    }
  }

  // 通用POST请求方法
  Future<dynamic> post(
    String path,
    {dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    int retryCount = 0}
  ) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      // 如果response.data已经是Map或List，直接返回，否则返回原始数据
      return response.data;
    } on DioException catch (e) {
      // 只在网络超时等临时错误时重试，认证错误由拦截器处理
      if (retryCount < _maxRetryCount && _shouldRetry(e)) {
        return post(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          retryCount: retryCount + 1,
        );
      }
      _handleDioError(e);
    }
  }

  /// 判断是否应该重试
  /// 只在网络超时、连接错误等临时性错误时重试
  /// 认证错误（401/403）由拦截器处理，不在这里重试
  bool _shouldRetry(DioException e) {
    // 网络超时，应该重试
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return true;
    }

    // 服务器错误（5xx），可能是临时问题，应该重试
    final statusCode = e.response?.statusCode;
    if (statusCode != null && statusCode >= 500) {
      return true;
    }

    // 认证错误（401/403）由拦截器处理，不重试
    // 其他客户端错误（4xx）通常是请求本身的问题，不重试
    return false;
  }

  void _handleDioError(DioException e) {
    if (e.response != null) {
      _handleErrorResponse(e.response!.statusCode ?? -1, e.response!.data?.toString() ?? '');
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw TimeoutException();
    } else {
      throw NetworkException('网络连接失败', -1);
    }
  }

  void _handleErrorResponse(int statusCode, String body) {
    switch (statusCode) {
      case 401:
        throw AuthenticationException('认证失败');
      case 403:
        throw AuthorizationException('权限不足');
      case 404:
        throw NotFoundException('资源未找到');
      case 500:
        throw ServerException('服务器内部错误');
      default:
        throw NetworkException('请求失败: $body', statusCode);
    }
  }

  void dispose() {
    _dio.close();
  }
}
