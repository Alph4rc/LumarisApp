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
      return response.toString();
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
      return response.toString();
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
