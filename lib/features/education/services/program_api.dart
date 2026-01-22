import 'dart:convert';
import '../../../core/services/network_exception.dart';
import 'edu_http_client_manager.dart';

/// Program相关API
class ProgramApi {
  /// 获取培养方案
  static Future<String> getProgram(String studentId, {String? name}) async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Program',
        queryParameters: {
          'id': studentId,
          'name': name,
        },
      );
      // 如果response已经是Map或List，使用jsonEncode转换为标准JSON字符串
      return response is Map || response is List ? jsonEncode(response) : response.toString();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取培养方案字典
  static Future<String> getProgramDic(String studentId) async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Program/GetDic',
        queryParameters: {'id': studentId},
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
