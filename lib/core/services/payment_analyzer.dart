import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/features/education/models/payment_model.dart';
import 'package:ios_club_app/core/services/base_http_client.dart';
import 'package:ios_club_app/core/services/secure_storage_service.dart';

abstract class PaymentStorage {
  Future<void> write(String key, String? value);
  Future<String?> read(String key);
}

class SecurePaymentStorage implements PaymentStorage {
  final SecureStorageService _secureStorage;

  SecurePaymentStorage(this._secureStorage);

  @override
  Future<void> write(String key, String? value) {
    return _secureStorage.write(key: key, value: value);
  }

  @override
  Future<String?> read(String key) {
    return _secureStorage.read(key: key);
  }
}

/// 支付数据分析器类
///
/// 负责获取、存储和处理用户的支付数据
class PaymentAnalyzer {
  static final BaseHttpClient _client = BaseHttpClient(
    baseUrl: 'https://xauatapi.xauat.site',
    enableCache: true,
  );
  static PaymentStorage _storage =
      SecurePaymentStorage(SecureStorageService.instance);

  /// Test-only storage injection.
  static void setStorageForTest(PaymentStorage storage) {
    _storage = storage;
  }

  /// Reset storage to production implementation.
  static void resetStorage() {
    _storage = SecurePaymentStorage(SecureStorageService.instance);
  }

  /// 获取支付数据
  /// 如果本地没有存储卡号，则返回空数据
  /// 否则从服务器获取该卡号对应的交易记录
  static Future<PaymentData> getData() async {
    final cardId = await PaymentAnalyzer.getPayment();
    if (cardId.isEmpty) {
      return PaymentData([], 0);
    }

    try {
      final response = await _client.get('/Payment/$cardId/turnover');
      if (response != null && response is Map<String, dynamic>) {
        return PaymentData.fromJson(response);
      }
    } catch (_) {
      // 忽略错误，返回空数据
    }

    return PaymentData([], 0);
  }

  /// 根据指定卡号获取支付数据
  ///
  /// [cardId] 卡号
  static Future<PaymentData> fetchData(String cardId) async {
    try {
      final response = await _client.get('/Payment/$cardId/turnover');
      if (response != null && response is Map<String, dynamic>) {
        return PaymentData.fromJson(response);
      }
    } catch (_) {
      // 忽略错误，返回空数据
    }

    return PaymentData([], 0);
  }

  /// 存储支付卡号到本地
  ///
  /// [a] 卡号
  static Future<void> setPayment(String a) async {
    await _storage.write(PrefsKeys.PAYMENT_NUM, a);
  }

  /// 从本地获取已存储的支付卡号
  ///
  /// 返回存储的卡号，如果未存储则返回空字符串
  static Future<String> getPayment() async {
    return await _storage.read(PrefsKeys.PAYMENT_NUM) ?? '';
  }
}
