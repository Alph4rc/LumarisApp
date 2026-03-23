import 'package:ios_club_app/features/education/models/edu_api_models.dart';
import '../../../core/services/network_exception.dart';
import 'edu_http_client_manager.dart';

/// Exam相关API
class ExamApi {
  /// 获取考试信息
  static Future<ExamResponse> getExam(String studentId) async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Exam',
        queryParameters: {'studentId': studentId},
      );
      if (response is! Map<String, dynamic>) {
        throw NetworkException('考试返回格式错误', -1);
      }
      return ExamResponse.fromJson(response);
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
