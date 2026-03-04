class YearCount {
  final String year;
  final int value;

  YearCount({
    required this.year,
    required this.value,
  });

  factory YearCount.fromJson(Map<String, dynamic> json) {
    return YearCount(
      year: json['year'] as String,
      value: json['value'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'value': value,
    };
  }
}
