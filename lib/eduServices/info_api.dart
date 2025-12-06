import 'dart:convert';
import '../net/network_exception.dart';
import 'edu_http_client.dart';

/// Info相关API
class InfoApi {
  static final EduHttpClient _client = EduHttpClient();

  /// 获取学生信息完成度
  static Future<String> getInfoCompletion() async {
    try {
      final response = await _client.get(
        '/Info/Completion',
      );
      // 如果response已经是Map或List，使用jsonEncode转换为标准JSON字符串
      return response is Map || response is List ? jsonEncode(response) : response.toString();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取时间信息
  static Future<String> getTime() async {
    try {
      final response = await _client.get(
        '/Info/Time',
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
