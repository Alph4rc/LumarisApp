import 'package:ios_club_app/features/education/models/api_response.dart';
import 'package:ios_club_app/features/education/models/payment_model.dart';
import 'package:ios_club_app/features/education/models/raw_string_response.dart';
import '../../../core/services/network_exception.dart';
import '../services/edu_http_client_manager.dart';

/// Payment相关API
class PaymentApi {
  static Map<String, dynamic>? _passwordQueryParameters(String? password) {
    final normalizedPassword = password?.trim();
    if (normalizedPassword == null || normalizedPassword.isEmpty) {
      return null;
    }
    return {'password': normalizedPassword};
  }

  /// 获取缴费信息
  static Future<RawStringResponse> getPayment(
    String id, [
    String? password,
  ]) async {
    try {
      final rawResponse = await EduHttpClientManager.instance.get(
        '/Payment/$id',
        queryParameters: _passwordQueryParameters(password),
      );
      final apiResponse = ApiResponse<String>.parsed(
        rawResponse,
        (data) => data?.toString() ?? '',
      );
      if (!apiResponse.isSuccess) {
        throw NetworkException(
          apiResponse.message ?? '缴费信息请求失败',
          -1,
        );
      }
      return RawStringResponse(apiResponse.data ?? '');
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 获取缴费流水
  static Future<PaymentData> getPaymentTurnover(
    String id, [
    String? password,
  ]) async {
    try {
      final rawResponse = await EduHttpClientManager.instance.get(
        '/Payment/$id/turnover',
        queryParameters: _passwordQueryParameters(password),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.parsed(
        rawResponse,
        (data) => Map<String, dynamic>.from(data as Map),
      );
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        throw NetworkException(
          apiResponse.message ?? '缴费流水请求失败',
          -1,
        );
      }

      final turnoverData = apiResponse.data!;
      final records = (turnoverData['records'] as List<dynamic>? ?? [])
          .map((e) => PaymentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      final balance =
          double.tryParse(turnoverData['balance']?.toString() ?? '0') ?? 0;
      return PaymentData(records, balance);
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
