import 'dart:convert';
import '../../../core/services/network_exception.dart';
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
      // 如果response已经是Map或List，使用jsonEncode转换为标准JSON字符串
      return response is Map || response is List ? jsonEncode(response) : response.toString();
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
