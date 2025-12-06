import '../net/network_exception.dart';
import 'edu_http_client.dart';

/// Program相关API
class ProgramApi {
  static final EduHttpClient _client = EduHttpClient();

  /// 获取培养方案
  static Future<String> getProgram(String studentId, {String? name}) async {
    try {
      final response = await _client.get(
        '/Program',
        queryParameters: {
          'id': studentId,
          'name': name,
        },
      );
      return response.toString();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取培养方案字典
  static Future<String> getProgramDic(String studentId) async {
    try {
      final response = await _client.get(
        '/Program/GetDic',
        queryParameters: {'id': studentId},
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
