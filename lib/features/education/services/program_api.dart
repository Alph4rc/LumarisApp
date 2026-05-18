import 'package:ios_club_app/features/education/models/plan_course.dart';
import '../../../core/services/network_exception.dart';
import 'edu_http_client_manager.dart';

/// Program相关API
class ProgramApi {
  /// 获取培养方案
  static Future<List<PlanCourse>> getProgram(String studentId,
      {String? name, bool forceRefresh = false}) async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Program',
        queryParameters: {
          'id': studentId,
          'name': name,
        },
        bypassCache: forceRefresh,
      );
      if (response is! List<dynamic>) {
        throw NetworkException('培养方案返回格式错误', -1);
      }
      return response
          .map((item) => PlanCourse.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取培养方案字典
  static Future<Map<String, List<PlanCourse>>> getProgramDic(
    String studentId, {
    bool forceRefresh = false,
  }) async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Program/GetDic',
        queryParameters: {'id': studentId},
        bypassCache: forceRefresh,
      );
      if (response is! Map) {
        throw NetworkException('培养方案字典返回格式错误: ${response.runtimeType}', -1);
      }
      // 转换为 Map<String, dynamic> 以确保类型安全
      final Map<String, dynamic> typedResponse =
          Map<String, dynamic>.from(response);
      return typedResponse.map((key, value) {
        final courses = (value as List<dynamic>)
            .map((item) => PlanCourse.fromJson(Map<String, dynamic>.from(item)))
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
