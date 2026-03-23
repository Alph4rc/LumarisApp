import 'package:ios_club_app/features/education/models/raw_string_response.dart';
import '../../../core/services/network_exception.dart';
import 'edu_http_client_manager.dart';

/// App相关API
class AppApi {
  /// 获取App相关信息
  static Future<RawStringResponse> getAppInfo({String? token}) async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/App',
        queryParameters: {'token': token},
      );
      return RawStringResponse.fromResponse(response);
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
