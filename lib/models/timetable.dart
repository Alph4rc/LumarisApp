class TimetableEntry {
  final String id;
  final String courseName;
  final String teacher;
  final String classroom;
  final int dayOfWeek; // 1=Mon, 7=Sun
  final int startPeriod;
  final int endPeriod;

  const TimetableEntry({
    required this.id,
    required this.courseName,
    required this.teacher,
    required this.classroom,
    required this.dayOfWeek,
    required this.startPeriod,
    required this.endPeriod,
  });

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      id: json['id'] as String,
      courseName: json['courseName'] as String,
      teacher: json['teacher'] as String,
      classroom: json['classroom'] as String,
      dayOfWeek: json['dayOfWeek'] as int,
      startPeriod: json['startPeriod'] as int,
      endPeriod: json['endPeriod'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseName': courseName,
        'teacher': teacher,
        'classroom': classroom,
        'dayOfWeek': dayOfWeek,
        'startPeriod': startPeriod,
        'endPeriod': endPeriod,
      };

  TimetableEntry copyWith({
    String? courseName,
    String? teacher,
    String? classroom,
  }) {
    return TimetableEntry(
      id: id,
      courseName: courseName ?? this.courseName,
      teacher: teacher ?? this.teacher,
      classroom: classroom ?? this.classroom,
      dayOfWeek: dayOfWeek,
      startPeriod: startPeriod,
      endPeriod: endPeriod,
    );
  }
}
