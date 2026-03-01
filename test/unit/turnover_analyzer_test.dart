import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/payment_analyzer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _InMemoryPaymentStorage implements PaymentStorage {
  final Map<String, String?> _memory = <String, String?>{};

  @override
  Future<String?> read(String key) async => _memory[key];

  @override
  Future<void> write(String key, String? value) async {
    if (value == null) {
      _memory.remove(key);
      return;
    }
    _memory[key] = value;
  }
}

void main() {
  group('PaymentModel', () {
    test('should create instance with provided values', () {
      final payment = PaymentModel(
        turnoverType: '消费',
        datetimeStr: '2023-01-01 12:00:00',
        resume: '食堂午餐',
        amount: 15.50,
      );

      expect(payment.turnoverType, '消费');
      expect(payment.datetimeStr, '2023-01-01 12:00:00');
      expect(payment.resume, '食堂午餐');
      expect(payment.amount, 15.50);
    });

    test('should create instance from JSON', () {
      final json = {
        'turnoverType': '充值',
        'datetimeStr': '2023-01-01 10:00:00',
        'resume': '支付宝充值',
        'tranamt': 100,
      };

      final payment = PaymentModel.fromJson(json);

      expect(payment.turnoverType, '充值');
      expect(payment.datetimeStr, '2023-01-01 10:00:00');
      expect(payment.resume, '支付宝充值');
      expect(payment.amount, 100.0);
    });

    test('should handle missing fields in JSON gracefully', () {
      final json = {
        'turnoverType': '消费',
        'datetimeStr': '2023-01-01 12:00:00',
        // 'resume' field missing
        // 'tranamt' field missing
      };

      expect(() => PaymentModel.fromJson(json), throwsA(isA<TypeError>()));
    });

    test('should handle empty string values in JSON', () {
      final json = {
        'turnoverType': '',
        'datetimeStr': '',
        'resume': '',
        'tranamt': 0,
      };

      final payment = PaymentModel.fromJson(json);

      expect(payment.turnoverType, '');
      expect(payment.datetimeStr, '');
      expect(payment.resume, '');
      expect(payment.amount, 0.0);
    });

    test('should format toString correctly with different turnover types', () {
      final payment1 = PaymentModel(
        turnoverType: '消费',
        datetimeStr: '2023-01-01 12:00:00',
        resume: '食堂午餐',
        amount: 15.50,
      );

      final payment2 = PaymentModel(
        turnoverType: '充值',
        datetimeStr: '2023-01-01 10:00:00',
        resume: '支付宝充值',
        amount: 10000,
      );

      expect(
        payment1.toString(),
        '2023-01-01 12:00:00 | 消费 | 0.15 元 | 食堂午餐',
      );
      expect(
        payment2.toString(),
        '2023-01-01 10:00:00 | 充值 | 100.00 元 | 支付宝充值',
      );
    });

    test('should handle zero amount correctly', () {
      final payment = PaymentModel(
        turnoverType: '消费',
        datetimeStr: '2023-01-01 12:00:00',
        resume: '免费餐',
        amount: 0,
      );

      expect(
        payment.toString(),
        '2023-01-01 12:00:00 | 消费 | 0.00 元 | 免费餐',
      );
    });

    test('should handle large amount correctly', () {
      final payment = PaymentModel(
        turnoverType: '充值',
        datetimeStr: '2023-01-01 10:00:00',
        resume: '大额充值',
        amount: 1000000,
      );

      expect(
        payment.toString(),
        '2023-01-01 10:00:00 | 充值 | 10000.00 元 | 大额充值',
      );
    });

    test('should trim resume whitespace in toString', () {
      final payment = PaymentModel(
        turnoverType: '消费',
        datetimeStr: '2023-01-01 12:00:00',
        resume: '  食堂午餐  ',
        amount: 15.50,
      );

      expect(
        payment.toString(),
        '2023-01-01 12:00:00 | 消费 | 0.15 元 | 食堂午餐',
      );
    });

    test('should handle negative amount correctly', () {
      final payment = PaymentModel(
        turnoverType: '消费',
        datetimeStr: '2023-01-01 12:00:00',
        resume: '退款',
        amount: -15.50,
      );

      expect(
        payment.toString(),
        '2023-01-01 12:00:00 | 消费 | -0.15 元 | 退款',
      );
    });
  });

  group('PaymentData', () {
    test('should create instance with provided values', () {
      final payments = [
        PaymentModel(
          turnoverType: '消费',
          datetimeStr: '2023-01-01 12:00:00',
          resume: '食堂午餐',
          amount: 15.50,
        )
      ];
      final paymentData = PaymentData(payments, 100.0);

      expect(paymentData.payments, payments);
      expect(paymentData.total, 100.0);
    });

    test('should create instance from JSON', () {
      final json = {
        'records': [
          {
            'turnoverType': '消费',
            'datetimeStr': '2023-01-01 12:00:00',
            'resume': '食堂午餐',
            'tranamt': 15.50,
          }
        ],
        'total': 100.0,
      };

      final paymentData = PaymentData.fromJson(json);

      expect(paymentData.payments, isNotEmpty);
      expect(paymentData.payments.length, 1);
      expect(paymentData.payments[0].turnoverType, '消费');
      expect(paymentData.total, 100.0);
    });

    test('should handle empty records list in JSON', () {
      final json = {
        'records': [],
        'total': 0.0,
      };

      final paymentData = PaymentData.fromJson(json);

      expect(paymentData.payments, isEmpty);
      expect(paymentData.total, 0.0);
    });

    test('should handle large number of records in JSON', () {
      final records = List.generate(
          100,
          (index) => {
                'turnoverType': index % 2 == 0 ? '消费' : '充值',
                'datetimeStr': '2023-01-01 12:00:00',
                'resume': '交易$index',
                'tranamt': index * 10,
              });

      final json = {
        'records': records,
        'total': 1000.0,
      };

      final paymentData = PaymentData.fromJson(json);

      expect(paymentData.payments.length, 100);
      expect(paymentData.total, 1000.0);
      expect(paymentData.payments[0].resume, '交易0');
      expect(paymentData.payments[99].resume, '交易99');
    });

    test('should handle extreme record count in JSON', () {
      final records = List.generate(
          10000,
          (index) => {
                'turnoverType': index.isEven ? '消费' : '充值',
                'datetimeStr': '2023-01-01 12:00:00',
                'resume': '极限交易$index',
                'tranamt': index,
              });

      final json = {
        'records': records,
        'total': 49995000.0,
      };

      final paymentData = PaymentData.fromJson(json);
      expect(paymentData.payments.length, 10000);
      expect(paymentData.payments.first.resume, '极限交易0');
      expect(paymentData.payments.last.resume, '极限交易9999');
    });

    test('should handle missing total field in JSON', () {
      final json = {
        'records': [
          {
            'turnoverType': '消费',
            'datetimeStr': '2023-01-01 12:00:00',
            'resume': '食堂午餐',
            'tranamt': 15.50,
          }
        ],
        // 'total' field missing
      };

      expect(() => PaymentData.fromJson(json), throwsA(isA<TypeError>()));
    });

    test('should handle non-numeric total in JSON', () {
      final json = {
        'records': [
          {
            'turnoverType': '消费',
            'datetimeStr': '2023-01-01 12:00:00',
            'resume': '食堂午餐',
            'tranamt': 15.50,
          }
        ],
        'total': 'not_a_number',
      };

      expect(() => PaymentData.fromJson(json), throwsA(isA<TypeError>()));
    });

    test('should throw when records type is invalid', () {
      final json = {
        'records': 'invalid-records',
        'total': 1.0,
      };

      expect(() => PaymentData.fromJson(json), throwsA(isA<TypeError>()));
    });

    test('should handle zero total correctly', () {
      final json = {
        'records': [],
        'total': 0.0,
      };

      final paymentData = PaymentData.fromJson(json);
      expect(paymentData.total, 0.0);
      expect(paymentData.payments, isEmpty);
    });

    test('should handle negative total correctly', () {
      final json = {
        'records': [],
        'total': -100.0,
      };

      final paymentData = PaymentData.fromJson(json);
      expect(paymentData.total, -100.0);
    });
  });

  group('PaymentAnalyzer', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      PaymentAnalyzer.setStorageForTest(_InMemoryPaymentStorage());
    });

    tearDown(() {
      PaymentAnalyzer.resetStorage();
    });

    test('should set and get payment number correctly', () async {
      const testCardId = '123456789';

      // Set payment number
      await PaymentAnalyzer.setPayment(testCardId);

      // Get payment number
      final cardId = await PaymentAnalyzer.getPayment();

      // Verify the payment number was saved and retrieved correctly
      expect(cardId, testCardId);
    });

    test('should return empty string for non-existent payment number',
        () async {
      // Clear any existing payment number
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('payment_num');

      // Get payment number (should return empty string)
      final cardId = await PaymentAnalyzer.getPayment();

      // Verify returns empty string
      expect(cardId, '');
    });

    test('should handle empty payment number', () async {
      // Set empty payment number
      await PaymentAnalyzer.setPayment('');

      // Get payment number
      final cardId = await PaymentAnalyzer.getPayment();

      // Verify returns empty string
      expect(cardId, '');
    });

    test('should handle large payment number', () async {
      const largeCardId = '12345678901234567890';

      // Set large payment number
      await PaymentAnalyzer.setPayment(largeCardId);

      // Get payment number
      final cardId = await PaymentAnalyzer.getPayment();

      // Verify returns the large card id
      expect(cardId, largeCardId);
    });

    test('should overwrite payment number correctly', () async {
      await PaymentAnalyzer.setPayment('first');
      await PaymentAnalyzer.setPayment('second');
      expect(await PaymentAnalyzer.getPayment(), 'second');
    });
  });
}
