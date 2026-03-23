class WeekInfo {
  final int week;
  final int maxWeek;

  WeekInfo({
    required this.week,
    required this.maxWeek,
  });

  factory WeekInfo.fromJson(Map<String, dynamic> json) {
    return WeekInfo(
      week: json['week'] as int? ?? 0,
      maxWeek: json['maxWeek'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week': week,
      'maxWeek': maxWeek,
    };
  }
}
