class GenderCount {
  final String type;
  final int value;

  GenderCount({
    required this.type,
    required this.value,
  });

  factory GenderCount.fromJson(Map<String, dynamic> json) {
    return GenderCount(
      type: json['type'] as String,
      value: json['value'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
    };
  }
}
