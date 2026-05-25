import 'package:ios_club_app/features/education/models/payment_model.dart';
import 'package:ios_club_app/features/education/apis/payment_api.dart';

/// 支付数据分析器类
///
/// 负责获取、存储和处理用户的支付数据
class PaymentService {
  /// 根据指定卡号获取支付数据
  ///
  /// [cardId] 卡号
  static Future<PaymentData> fetchData(String cardId) async {
    try {
      return await PaymentApi.getPaymentTurnover(cardId);
    } catch (_) {
      return PaymentData([], 0);
    }
  }
}
