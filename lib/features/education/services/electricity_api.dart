import '../models/electric_data.dart';
import '../models/edu_api_models.dart';
import '../../../core/services/network_exception.dart';
import 'edu_http_client_manager.dart';

/// Electricity 相关 API
class ElectricityApi {
  /// 获取当前电费余额
  static Future<double?> getCurrentBalance({String? url}) async {
    try {
      final trimmedUrl = url?.trim();
      final response = await EduHttpClientManager.instance.get(
        '/Electricity',
        queryParameters: trimmedUrl == null || trimmedUrl.isEmpty
            ? null
            : <String, dynamic>{'url': trimmedUrl},
      );

      if (response is num) {
        return response.toDouble();
      }
      if (response is String) {
        return double.parse(response);
      }

      throw NetworkException('电费余额返回格式错误: ${response.runtimeType}', -1);
    } on NotFoundException {
      return null;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取按小时聚合的周用电明细
  static Future<List<ElectricData>> getWeeklyData({String? url}) async {
    try {
      final trimmedUrl = url?.trim();

      final response = await EduHttpClientManager.instance.get(
        '/Electricity/WeeklyData',
        queryParameters: trimmedUrl == null || trimmedUrl.isEmpty
            ? null
            : <String, dynamic>{'url': trimmedUrl},
      );

      if (response is! List) {
        throw NetworkException('电费周明细返回格式错误: ${response.runtimeType}', -1);
      }

      return response.map((item) {
        if (item is! Map) {
          throw NetworkException(
            '电费周明细项格式错误: ${item.runtimeType}',
            -1,
          );
        }
        return ElectricData.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取电费充值页面地址
  static Future<String?> getRechargeUrl({String? url}) async {
    try {
      final trimmedUrl = url?.trim();

      final response = await EduHttpClientManager.instance.get(
        '/Electricity/RechargeUrl',
        queryParameters: trimmedUrl == null || trimmedUrl.isEmpty
            ? null
            : <String, dynamic>{'url': trimmedUrl},
      );

      if (response is String) {
        return response;
      }

      throw NetworkException('电费充值地址返回格式错误: ${response.runtimeType}', -1);
    } on NotFoundException {
      return null;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 创建电费订阅
  static Future<ElectricitySubscriptionResponse> createSubscription(
    CreateElectricitySubscriptionRequest request,
  ) async {
    try {
      final response = await EduHttpClientManager.instance.post(
        '/Electricity/Subscriptions',
        data: request.toJson(),
      );

      if (response is! Map) {
        throw NetworkException('电费订阅创建返回格式错误: ${response.runtimeType}', -1);
      }

      return ElectricitySubscriptionResponse.fromJson(
        Map<String, dynamic>.from(response),
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 查询电费订阅状态
  static Future<ElectricitySubscriptionQueryResponse> getSubscription(
    String email,
  ) async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Electricity/Subscriptions',
        queryParameters: <String, dynamic>{'email': email.trim()},
      );

      if (response is! Map) {
        throw NetworkException('电费订阅查询返回格式错误: ${response.runtimeType}', -1);
      }

      return ElectricitySubscriptionQueryResponse.fromJson(
        Map<String, dynamic>.from(response),
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 删除电费订阅
  static Future<void> deleteSubscription(String id) async {
    try {
      await EduHttpClientManager.instance.delete(
        '/Electricity/Subscriptions/${id.trim()}',
      );
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
