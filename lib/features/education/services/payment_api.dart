import 'package:ios_club_app/features/education/models/payment_model.dart';
import 'package:ios_club_app/features/education/models/raw_string_response.dart';
import '../../../core/services/network_exception.dart';
import 'edu_http_client_manager.dart';

/// Payment相关API
class PaymentApi {
  /// 获取缴费信息
  static Future<RawStringResponse> getPayment(String id) async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Payment/$id',
      );
      return RawStringResponse.fromResponse(response);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取缴费流水
  static Future<PaymentData> getPaymentTurnover(String id) async {
    try {
      final response = await EduHttpClientManager.instance.get(
        '/Payment/$id/turnover',
      );

      if (response is! Map) {
        throw NetworkException('缴费流水返回格式错误: ${response.runtimeType}', -1);
      }
      // 转换为 Map<String, dynamic> 以确保类型安全
      final Map<String, dynamic> typedResponse = Map<String, dynamic>.from(response);
      return PaymentData.fromJson(typedResponse);
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
