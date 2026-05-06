import 'package:ios_club_app/features/education/models/edu_api_models.dart';
import 'package:ios_club_app/features/education/models/score_model.dart';
import 'package:ios_club_app/features/education/models/semester_model.dart';
import '../../../core/services/network_exception.dart';
import 'edu_http_client_manager.dart';

/// Score相关API
class ScoreApi {
  /// 获取学期信息
  static Future<SemesterResult> getSemester(
    String studentId, {
    bool forceRefresh = false,
  }) async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Score/Semester',
        queryParameters: {'studentId': studentId},
        bypassCache: forceRefresh,
      );
      if (response is! Map) {
        throw NetworkException('学期返回格式错误: ${response.runtimeType}', -1);
      }
      // 转换为 Map<String, dynamic> 以确保类型安全
      final Map<String, dynamic> typedResponse =
          Map<String, dynamic>.from(response);
      return SemesterResult.fromJson(typedResponse);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取成绩信息
  static Future<List<ScoreModel>> getScore(
    String studentId,
    String semester, {
    bool forceRefresh = false,
  }) async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Score',
        queryParameters: {
          'studentId': studentId,
          'semester': semester,
        },
        bypassCache: forceRefresh,
      );
      if (response is! List<dynamic>) {
        throw NetworkException('成绩返回格式错误', -1);
      }
      return response
          .map((item) => ScoreModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取本学期成绩
  static Future<SemesterModel> getThisSemester(
      {bool forceRefresh = false}) async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Score/ThisSemester',
        bypassCache: forceRefresh,
      );
      if (response is! Map) {
        throw NetworkException('当前学期返回格式错误: ${response.runtimeType}', -1);
      }
      // 转换为 Map<String, dynamic> 以确保类型安全
      final Map<String, dynamic> typedResponse =
          Map<String, dynamic>.from(response);
      return SemesterModel.fromJson(typedResponse);
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
