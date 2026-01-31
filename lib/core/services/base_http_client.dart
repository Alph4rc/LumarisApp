import 'package:dio/dio.dart';
import 'package:ios_club_app/core/utils/request_cache.dart';
import 'package:ios_club_app/core/services/network_exception.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

/// 基础 HTTP 客户端
///
/// 提供统一的 HTTP 请求功能，包括：
/// - 自动重试（网络超时、连接错误、5xx 错误）
/// - 缓存支持（通过 CacheInterceptor）
/// - 统一的错误处理
class BaseHttpClient {
  final Dio _dio;
  final int _maxRetryCount;
  final bool _enableCache;

  BaseHttpClient({
    String? baseUrl,
    int maxRetryCount = 2,
    bool enableCache = true,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 10),
    Map<String, dynamic>? defaultHeaders,
  })  : _maxRetryCount = maxRetryCount,
        _enableCache = enableCache,
        _dio = Dio() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl ?? '',
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      headers: defaultHeaders ??
          {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
    );

    if (_enableCache) {
      _dio.interceptors.add(CacheInterceptor());
    }
  }

  /// 获取 Dio 实例（用于添加自定义拦截器）
  Dio get dio => _dio;

  /// GET 请求
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    int retryCount = 0,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      if (retryCount < _maxRetryCount && _shouldRetry(e)) {
        await Future.delayed(Duration(milliseconds: 500 * (retryCount + 1)));
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

  /// POST 请求
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    int retryCount = 0,
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
      if (retryCount < _maxRetryCount && _shouldRetry(e)) {
        await Future.delayed(Duration(milliseconds: 500 * (retryCount + 1)));
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

  /// PUT 请求
  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    int retryCount = 0,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      if (retryCount < _maxRetryCount && _shouldRetry(e)) {
        await Future.delayed(Duration(milliseconds: 500 * (retryCount + 1)));
        return put(
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

  /// DELETE 请求
  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    int retryCount = 0,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      if (retryCount < _maxRetryCount && _shouldRetry(e)) {
        await Future.delayed(Duration(milliseconds: 500 * (retryCount + 1)));
        return delete(
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

  /// 下载文件（返回字节数据）
  Future<List<int>> downloadBytes(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    int retryCount = 0,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        url,
        queryParameters: queryParameters,
        options: (options ?? Options()).copyWith(
          responseType: ResponseType.bytes,
        ),
      );
      return response.data ?? [];
    } on DioException catch (e) {
      if (retryCount < _maxRetryCount && _shouldRetry(e)) {
        await Future.delayed(Duration(milliseconds: 500 * (retryCount + 1)));
        return downloadBytes(
          url,
          queryParameters: queryParameters,
          options: options,
          retryCount: retryCount + 1,
        );
      }
      _handleDioError(e);
    }
  }

  /// 判断是否应该重试
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

    return false;
  }

  /// 处理 Dio 错误
  Never _handleDioError(DioException e) {
    AppLogger.error('HTTP Error: ${e.message}');

    if (e.response != null) {
      _handleErrorResponse(
        e.response!.statusCode ?? -1,
        e.response!.data?.toString() ?? '',
      );
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw TimeoutException();
    } else {
      throw NetworkException('网络连接失败: ${e.message}', -1);
    }
  }

  /// 处理错误响应
  Never _handleErrorResponse(int statusCode, String body) {
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

  /// 关闭客户端
  void dispose() {
    _dio.close();
  }
}
