import 'dart:convert';
import '../../../core/services/network_exception.dart';
import 'edu_http_client_manager.dart';

/// Exam相关API
class ExamApi {
  /// 获取考试信息
  static Future<String> getExam(String studentId) async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Exam',
        queryParameters: {'studentId': studentId},
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
