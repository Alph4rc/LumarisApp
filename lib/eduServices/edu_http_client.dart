import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../stores/prefs_keys.dart';
import '../net/network_exception.dart';
import 'login_service.dart';

class EduHttpClient {
  static const String baseUrl = 'https://xauatapi.xauat.site';
  final Dio _dio;
  final int _maxRetryCount = 3;
  
  EduHttpClient({Dio? dio}) : _dio = dio ?? Dio() {
    _setupDio();
  }

  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      contentType: 'application/json',
    );
    
    // 添加拦截器
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
        if (e.response?.statusCode != 200) {
          // 认证失败，尝试重登录
          if (await _reLogin()) {
            // 重登录成功，重新发送请求
            try {
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
            } catch (retryError) {
              // 重新请求失败，继续处理原错误
              return handler.next(e);
            }
          }
        }
        
        // 处理其他错误
        handler.next(e);
      },
    ));
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
      
      final loginResult = await LoginService.login(username, password);
      
      if (loginResult['success'] == true) {
        await prefs.setString(PrefsKeys.USER_DATA, jsonEncode(loginResult));
        return true;
      }
      
      return false;
    } catch (e) {
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
      if (retryCount < _maxRetryCount) {
        // 重试请求
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
      if (retryCount < _maxRetryCount) {
        // 重试请求
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
