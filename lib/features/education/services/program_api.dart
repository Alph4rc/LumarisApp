import 'package:ios_club_app/features/education/models/plan_course.dart';
import '../../../core/services/network_exception.dart';
import 'edu_http_client_manager.dart';

/// Program相关API
class ProgramApi {
  /// 获取培养方案
  static Future<List<PlanCourse>> getProgram(String studentId,
      {String? name}) async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Program',
        queryParameters: {
          'id': studentId,
          'name': name,
        },
      );
      if (response is! List<dynamic>) {
        throw NetworkException('培养方案返回格式错误', -1);
      }
      return response
          .map((item) => PlanCourse.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取培养方案字典
  static Future<Map<String, List<PlanCourse>>> getProgramDic(
      String studentId) async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Program/GetDic',
        queryParameters: {'id': studentId},
      );
      if (response is! Map<String, dynamic>) {
        throw NetworkException('培养方案字典返回格式错误', -1);
      }
      return response.map((key, value) {
        final courses = (value as List<dynamic>)
            .map((item) => PlanCourse.fromJson(item as Map<String, dynamic>))
            .toList();
        return MapEntry(key, courses);
      });
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
