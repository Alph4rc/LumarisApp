import 'package:ios_club_app/features/education/models/info_model.dart';
import 'package:ios_club_app/features/education/models/time_info.dart';
import '../../../core/services/network_exception.dart';
import 'edu_http_client_manager.dart';

/// Info相关API
class InfoApi {
  /// 获取学生信息完成度
  static Future<List<InfoModel>> getInfoCompletion() async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Info/Completion',
      );
      if (response is! List<dynamic>) {
        throw NetworkException('信息完成度返回格式错误', -1);
      }
      return response
          .map((item) => InfoModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取时间信息
  static Future<TimeInfo> getTime() async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Info/Time',
      );
      if (response is! Map<String, dynamic>) {
        throw NetworkException('时间返回格式错误', -1);
      }
      return TimeInfo.fromJson(response);
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
