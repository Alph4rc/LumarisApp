class LandscapeCount {
  final String type;
  final int sales;

  LandscapeCount({
    required this.type,
    required this.sales,
  });

  factory LandscapeCount.fromJson(Map<String, dynamic> json) {
    return LandscapeCount(
      type: json['type'] as String,
      sales: json['sales'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'sales': sales,
    };
  }
}