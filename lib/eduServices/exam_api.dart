import '../net/network_exception.dart';
import 'edu_http_client.dart';

/// Exam相关API
class ExamApi {
  static final EduHttpClient _client = EduHttpClient();

  /// 获取考试信息
  static Future<String> getExam(String studentId) async {
    try {
      final response = await _client.get(
        '/Exam',
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
