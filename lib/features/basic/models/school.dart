enum Feature {
  timetable('timetable'),
  gradeQuery('grade_query'),
  gpaCalculation('gpa_calculation'),
  courseSelection('course_selection'),
  examSchedule('exam_schedule'),
  login('login'),
  busSchedule('bus_schedule'),
  program('program'),
  studyProgress('study_progress'),
  semesterInfo('semester_info');

  const Feature(this.value);
  final String value;

  static Feature fromValue(String value) {
    return Feature.values.firstWhere(
      (f) => f.value == value,
      orElse: () => throw ArgumentError('Invalid feature: $value'),
    );
  }
}

class School {
  final String code;
  final String name;
  final String website;
  final List<Feature> features;
  final bool enabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  School({
    required this.code,
    required this.name,
    required this.website,
    required this.features,
    this.enabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory School.fromJson(Map<String, dynamic> json) => School(
    code: json['code'] as String,
    name: json['name'] as String,
    website: json['website'] as String,
    features: (json['features'] as List<dynamic>)
        .map((f) => Feature.fromValue(f as String))
        .toList(),
    enabled: json['enabled'] as bool? ?? true,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'website': website,
    'features': features.map((f) => f.value).toList(),
    'enabled': enabled,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

class SchoolListData {
  final int total;
  final List<School> items;

  SchoolListData({required this.total, required this.items});

  factory SchoolListData.fromJson(Map<String, dynamic> json) => SchoolListData(
    total: json['total'] as int,
    items: (json['items'] as List<dynamic>)
        .map((e) => School.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}