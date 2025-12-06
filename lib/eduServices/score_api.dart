import '../net/network_exception.dart';
import 'edu_http_client.dart';

/// Score相关API
class ScoreApi {
  static final EduHttpClient _client = EduHttpClient();

  /// 获取学期信息
  static Future<String> getSemester(String studentId) async {
    try {
      final response = await _client.get(
        '/Score/Semester',
        queryParameters: {'studentId': studentId},
      );
      return response.toString();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取成绩信息
  static Future<String> getScore(String studentId, String semester) async {
    try {
      final response = await _client.get(
        '/Score',
        queryParameters: {
          'studentId': studentId,
          'semester': semester,
        },
      );
      return response.toString();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取本学期成绩
  static Future<String> getThisSemester() async {
    try {
      final response = await _client.get(
        '/Score/ThisSemester',
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
