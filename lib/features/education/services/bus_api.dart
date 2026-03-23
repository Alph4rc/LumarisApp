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
      if (response is! Map<String, dynamic>) {
        throw NetworkException('校巴返回格式错误', -1);
      }
      return BusModel.fromJson(response);
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
      if (response is! Map<String, dynamic>) {
        throw NetworkException('新校巴返回格式错误', -1);
      }
      return BusModel.fromJson(response);
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
      if (response is! Map<String, dynamic>) {
        throw NetworkException('旧校巴返回格式错误', -1);
      }
      return BusModel.fromJson(response);
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
