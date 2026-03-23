class PaymentModel {
  final String turnoverType;
  final String datetimeStr;
  final String resume;
  final double amount;

  const PaymentModel({
    required this.turnoverType,
    required this.datetimeStr,
    required this.resume,
    required this.amount,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final tranamt = json['tranamt'];
    if (tranamt is! num && tranamt is! String) {
      throw ArgumentError.value(
          tranamt, 'tranamt', 'Expected number or string');
    }

    return PaymentModel(
      turnoverType: json['turnoverType'] as String,
      datetimeStr: json['datetimeStr'] as String,
      resume: json['resume'] as String,
      amount: double.parse(tranamt.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'turnoverType': turnoverType,
      'datetimeStr': datetimeStr,
      'resume': resume,
      'tranamt': amount,
    };
  }

  @override
  String toString() {
    return '$datetimeStr | $turnoverType | ${(amount / 100).toStringAsFixed(2)} 元 | ${resume.trim()}';
  }
}

class PaymentData {
  final List<PaymentModel> payments;
  final double total;

  const PaymentData(this.payments, this.total);

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    final rawRecords = json['records'] as List<dynamic>? ?? <dynamic>[];
    final rawTotal = json['total'];
    if (rawTotal is! num && rawTotal is! String) {
      throw ArgumentError.value(rawTotal, 'total', 'Expected number or string');
    }

    return PaymentData(
      rawRecords
          .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      double.parse(rawTotal.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'records': payments.map((payment) => payment.toJson()).toList(),
      'total': total,
    };
  }
}
