class ElectricData {
  final DateTime timestamp;
  double value;

  ElectricData({required this.timestamp, required this.value});

  factory ElectricData.fromJson(Map<String, dynamic> json) {
    final rawTimestamp = json['timestamp'] ?? json['Timestamp'];
    final rawValue = json['value'] ?? json['Value'];

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

    if (rawValue is! num && rawValue is! String) {
      throw ArgumentError.value(rawValue, 'value', 'Expected number or string');
    }

    return ElectricData(
      timestamp: timestamp,
      value: double.parse(rawValue.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'timestamp': timestamp.toIso8601String(),
      'value': value,
    };
  }
}
