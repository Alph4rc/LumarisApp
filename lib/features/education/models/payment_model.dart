import 'package:json_annotation/json_annotation.dart';

part 'payment_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PaymentModel {
  final String turnoverType;
  final String datetimeStr;
  final String resume;
  @JsonKey(name: 'tranamt', fromJson: _amountFromJson)
  final double amount;

  const PaymentModel({
    required this.turnoverType,
    required this.datetimeStr,
    required this.resume,
    required this.amount,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    _amountFromJson(json['tranamt']);
    return _$PaymentModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);

  @override
  String toString() {
    return '$datetimeStr | $turnoverType | ${(amount / 100).toStringAsFixed(2)} 元 | ${resume.trim()}';
  }
}

@JsonSerializable(explicitToJson: true)
class PaymentData {
  @JsonKey(name: 'records', fromJson: _paymentsFromJson)
  final List<PaymentModel> payments;
  @JsonKey(fromJson: _totalFromJson)
  final double total;

  const PaymentData(this.payments, this.total);

  factory PaymentData.fromJson(Map<String, dynamic> json) =>
      _$PaymentDataFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentDataToJson(this);
}

double _amountFromJson(dynamic tranamt) {
  if (tranamt is! num && tranamt is! String) {
    throw ArgumentError.value(tranamt, 'tranamt', 'Expected number or string');
  }
  return double.parse(tranamt.toString());
}

double _totalFromJson(dynamic total) {
  if (total is! num && total is! String) {
    throw ArgumentError.value(total, 'total', 'Expected number or string');
  }
  return double.parse(total.toString());
}

List<PaymentModel> _paymentsFromJson(dynamic value) {
  return (value as List<dynamic>)
      .map((item) => PaymentModel.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}
