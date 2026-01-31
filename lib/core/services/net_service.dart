import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:ios_club_app/core/utils/request_cache.dart';
import 'package:ios_club_app/core/services/retry_policy.dart';

class NetService {
  static final RequestCache _cache = RequestCache.instance;
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 3),
    receiveTimeout: const Duration(seconds: 3),
  ));

  static bool _initialized = false;

  static void _ensureInitialized() {
    if (!_initialized) {
      // 添加重试拦截器（使用快速重试策略，3次重试）
      _dio.interceptors.add(RetryInterceptor(
        dio: _dio,
        policy: RetryPolicy.fast,
      ));
      _initialized = true;
    }
  }

  static Future<Map<String, dynamic>> get() async {
    _ensureInitialized();

    const url = 'http://10.99.144.34/cgi-bin/rad_user_info?callback=json';

    // 尝试从缓存获取数据
    final cachedData = await _cache.get<Map<String, dynamic>>(url);
    if (cachedData != null) {
      return cachedData;
    }

    try {
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        var text = response.data.toString();
        text = text.substring(text.indexOf('{'), text.lastIndexOf('}') + 1);
        final res = jsonDecode(text) as Map<String, dynamic>;

        // 将数据存入缓存
        await _cache.set(url, res);

        return res;
      } else {
        DioErrorHandler.handleErrorResponse(
          response.statusCode ?? -1,
          response.statusMessage ?? '',
        );
      }
    } on DioException catch (e) {
      DioErrorHandler.handleError(e);
    }
  }
}
