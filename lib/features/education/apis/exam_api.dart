import 'package:ios_club_app/features/education/models/api_response.dart';
import 'package:ios_club_app/features/education/models/edu_api_models.dart';
import '../../../core/services/network_exception.dart';
import '../services/edu_http_client_manager.dart';

/// Exam相关API — v1.yaml tag: ExamV1
class ExamApi {
  /// GET /v1/exam → ApiResponseOfExamResponse
  static Future<ExamResponse> getExam(
    String studentId, {
    bool forceRefresh = false,
  }) async {
    try {
      final rawResponse = await EduHttpClientManager.instance.get(
        '/Exam',
        queryParameters: {'studentId': studentId},
        bypassCache: forceRefresh,
      );
      final apiResponse = ApiResponse<ExamResponse>.parsed(
        rawResponse,
        (data) => ExamResponse.fromJson(Map<String, dynamic>.from(data as Map)),
      );
      if (!apiResponse.isSuccess) {
        throw NetworkException(
          apiResponse.message ?? '考试请求失败',
          -1,
        );
      }
      return apiResponse.data ?? const ExamResponse(exams: [], canClick: false);
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
