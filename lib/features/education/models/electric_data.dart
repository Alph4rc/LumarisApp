import 'package:json_annotation/json_annotation.dart';

part 'electric_data.g.dart';

@JsonSerializable()
class ElectricData {
  @JsonKey(readValue: _readTimestamp, fromJson: _timestampFromJson)
  final DateTime timestamp;
  @JsonKey(readValue: _readValue, fromJson: _valueFromJson)
  double value;

  ElectricData({required this.timestamp, required this.value});

  factory ElectricData.fromJson(Map<String, dynamic> json) =>
      _$ElectricDataFromJson(json);

  Map<String, dynamic> toJson() => _$ElectricDataToJson(this);
}

Object? _readTimestamp(Map<dynamic, dynamic> json, String key) {
  return json[key] ?? json['Timestamp'];
}

DateTime _timestampFromJson(dynamic rawTimestamp) {
  if (rawTimestamp is! String) {
    throw ArgumentError.value(
      rawTimestamp,
      'timestamp',
      'Expected timestamp string',
    );
  }

  final timestamp = DateTime.tryParse(rawTimestamp);
  if (timestamp == null) {
    throw ArgumentError.value(
      rawTimestamp,
      'timestamp',
      'Invalid timestamp format',
    );
  }

  return timestamp;
}

Object? _readValue(Map<dynamic, dynamic> json, String key) {
  return json[key] ?? json['Value'];
}

double _valueFromJson(dynamic rawValue) {
  if (rawValue is! num && rawValue is! String) {
    throw ArgumentError.value(rawValue, 'value', 'Expected number or string');
  }

  return double.parse(rawValue.toString());
}
