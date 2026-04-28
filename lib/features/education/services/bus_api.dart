import 'package:ios_club_app/features/education/models/bus_model.dart';
import '../../../core/services/network_exception.dart';
import 'edu_http_client_manager.dart';

/// Bus相关API
class BusApi {
  /// 获取校巴信息
  static Future<BusModel> getBus({String? dayDate}) async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Bus/${dayDate ?? ''}',
      );
      if (response is! Map) {
        throw NetworkException('校巴返回格式错误: ${response.runtimeType}', -1);
      }
      // 转换为 Map<String, dynamic> 以确保类型安全
      final Map<String, dynamic> typedResponse = Map<String, dynamic>.from(response);
      return BusModel.fromJson(typedResponse);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取新的校巴数据
  static Future<BusModel> getBusNewData(String time,
      {String loc = 'ALL'}) async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Bus/NewData/$time',
        queryParameters: {'loc': loc},
      );
      if (response is! Map) {
        throw NetworkException('新校巴返回格式错误: ${response.runtimeType}', -1);
      }
      // 转换为 Map<String, dynamic> 以确保类型安全
      final Map<String, dynamic> typedResponse = Map<String, dynamic>.from(response);
      return BusModel.fromJson(typedResponse);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取旧的校巴数据
  static Future<BusModel> getBusOldData(String time,
      {bool isShow = false}) async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Bus/OldData/$time',
        queryParameters: {'isShow': isShow},
      );
      if (response is! Map) {
        throw NetworkException('旧校巴返回格式错误: ${response.runtimeType}', -1);
      }
      // 转换为 Map<String, dynamic> 以确保类型安全
      final Map<String, dynamic> typedResponse = Map<String, dynamic>.from(response);
      return BusModel.fromJson(typedResponse);
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
