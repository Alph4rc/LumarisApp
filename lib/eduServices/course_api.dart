import '../net/network_exception.dart';
import 'edu_http_client.dart';

/// Course相关API
class CourseApi {
  static final EduHttpClient _client = EduHttpClient();

  /// 获取课程信息
  static Future<String> getCourse(String studentId) async {
    try {
      final response = await _client.get(
        '/Course',
        queryParameters: {'studentId': studentId},
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
