import 'dart:convert';
import '../../../core/services/network_exception.dart';
import 'edu_http_client_manager.dart';

/// Score相关API
class ScoreApi {
  /// 获取学期信息
  static Future<String> getSemester(String studentId) async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Score/Semester',
        queryParameters: {'studentId': studentId},
      );
      // 如果response已经是Map或List，使用jsonEncode转换为标准JSON字符串
      return response is Map || response is List ? jsonEncode(response) : response.toString();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取成绩信息
  static Future<String> getScore(String studentId, String semester) async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Score',
        queryParameters: {
          'studentId': studentId,
          'semester': semester,
        },
      );
      // 如果response已经是Map或List，使用jsonEncode转换为标准JSON字符串
      return response is Map || response is List ? jsonEncode(response) : response.toString();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取本学期成绩
  static Future<String> getThisSemester() async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Score/ThisSemester',
      );
      // 如果response已经是Map或List，使用jsonEncode转换为标准JSON字符串
      return response is Map || response is List ? jsonEncode(response) : response.toString();
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
