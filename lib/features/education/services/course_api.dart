import 'package:ios_club_app/features/education/models/edu_api_models.dart';
import '../../../core/services/network_exception.dart';
import 'edu_http_client_manager.dart';

/// Course相关API
class CourseApi {
  /// 获取课程信息
  static Future<CourseResultResponse> getCourse(
    String studentId, {
    bool forceRefresh = false,
  }) async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Course',
        queryParameters: {'studentId': studentId},
        bypassCache: forceRefresh,
      );
      if (response is! Map<String, dynamic>) {
        throw NetworkException('课程返回格式错误', -1);
      }
      return CourseResultResponse.fromJson(response);
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
