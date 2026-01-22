import 'dart:convert';
import '../../../core/services/network_exception.dart';
import 'edu_http_client_manager.dart';

/// Bus相关API
class BusApi {
  /// 获取校巴信息
  static Future<String> getBus({String? dayDate}) async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Bus/${dayDate ?? ''}',
      );
      // 如果response已经是Map或List，使用jsonEncode转换为标准JSON字符串
      return response is Map || response is List ? jsonEncode(response) : response.toString();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取新的校巴数据
  static Future<String> getBusNewData(String time, {String loc = 'ALL'}) async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Bus/NewData/$time',
        queryParameters: {'loc': loc},
      );
      // 如果response已经是Map或List，使用jsonEncode转换为标准JSON字符串
      return response is Map || response is List ? jsonEncode(response) : response.toString();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取旧的校巴数据
  static Future<String> getBusOldData(String time, {bool isShow = false}) async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Bus/OldData/$time',
        queryParameters: {'isShow': isShow},
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
