import '../net/network_exception.dart';
import 'edu_http_client.dart';

/// Payment相关API
class PaymentApi {
  static final EduHttpClient _client = EduHttpClient();

  /// 获取缴费信息
  static Future<String> getPayment(String id) async {
    try {
      final response = await _client.get(
        '/Payment/$id',
      );
      return response.toString();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取缴费流水
  static Future<String> getPaymentTurnover(String id) async {
    try {
      final response = await _client.get(
        '/Payment/$id/turnover',
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
