import 'dart:convert';
import '../../../core/services/network_exception.dart';
import 'edu_http_client.dart';

/// App相关API
class AppApi {
  static final EduHttpClient _client = EduHttpClient();

  /// 获取App相关信息
  static Future<String> getAppInfo({String? token}) async {
    try {
      final response = await _client.get(
        '/App',
        queryParameters: {'token': token},
      );
      // 如果response已经是Map或List，使用jsonEncode转换为标准JSON字符串
      return response is Map || response is List ? jsonEncode(response) : response.toString();
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
