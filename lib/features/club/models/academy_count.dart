class AcademyCount {
  final String type;
  final int value;

  AcademyCount({
    required this.type,
    required this.value,
  });

  factory AcademyCount.fromJson(Map<String, dynamic> json) {
    return AcademyCount(
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
