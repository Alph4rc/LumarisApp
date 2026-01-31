import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:ios_club_app/core/utils/request_cache.dart';
import 'package:ios_club_app/core/services/network_exception.dart';

class NetService {
  static final RequestCache _cache = RequestCache.instance;
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 3),
    receiveTimeout: const Duration(seconds: 3),
  ));

  static Future<Map<String, dynamic>> get() async {
    const url = 'http://10.99.144.34/cgi-bin/rad_user_info?callback=json';
    const maxRetries = 3;

    // 尝试从缓存获取数据
    final cachedData = await _cache.get<Map<String, dynamic>>(url);
    if (cachedData != null) {
      return cachedData;
    }

    for (int attempt = 0; attempt < maxRetries; attempt++) {
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
          throw NetworkException('HTTP ${response.statusCode}: ${response.statusMessage}', response.statusCode);
        }
      } on DioException catch (e) {
        if (attempt == maxRetries - 1) {
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            throw TimeoutException();
          }
          throw NetworkException('网络连接失败: ${e.message}', -1);
        }
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      } catch (e) {
        if (attempt == maxRetries - 1) {
          throw NetworkException('请求失败: $e', -1);
        }
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      }
    }

    throw NetworkException('获取数据失败', -1);
  }
}
