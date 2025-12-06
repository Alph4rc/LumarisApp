import '../net/network_exception.dart';
import 'edu_http_client.dart';

/// Bus相关API
class BusApi {
  static final EduHttpClient _client = EduHttpClient();

  /// 获取校巴信息
  static Future<String> getBus({String? dayDate}) async {
    try {
      final response = await _client.get(
        '/Bus/${dayDate ?? ''}',
      );
      return response.toString();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取新的校巴数据
  static Future<String> getBusNewData(String time, {String loc = 'ALL'}) async {
    try {
      final response = await _client.get(
        '/Bus/NewData/$time',
        queryParameters: {'loc': loc},
      );
      return response.toString();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取旧的校巴数据
  static Future<String> getBusOldData(String time, {bool isShow = false}) async {
    try {
      final response = await _client.get(
        '/Bus/OldData/$time',
        queryParameters: {'isShow': isShow},
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
