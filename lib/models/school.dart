/// 学校支持级别
enum SupportLevel {
  /// 基础级别：只能查看课表（只读）
  basic,

  /// 高级级别：支持查看、编辑、导出课表、通知等功能
  advanced,
}

/// 功能权限标识
enum Feature {
  viewTimetable,
  editTimetable,
  exportTimetable,
  notifications,
  calendarSync,
}

/// 根据支持级别返回可用功能列表
List<Feature> featuresForLevel(SupportLevel level) {
  switch (level) {
    case SupportLevel.basic:
      return [Feature.viewTimetable];
    case SupportLevel.advanced:
      return [
        Feature.viewTimetable,
        Feature.editTimetable,
        Feature.exportTimetable,
        Feature.notifications,
        Feature.calendarSync,
      ];
  }
}

/// 学校数据模型
class School {
  final String id;
  final String name;
  final String shortName;
  final SupportLevel supportLevel;

  const School({
    required this.id,
    required this.name,
    required this.shortName,
    required this.supportLevel,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String,
      supportLevel: SupportLevel.values.firstWhere(
        (e) => e.name == json['supportLevel'],
        orElse: () => SupportLevel.basic,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'shortName': shortName,
        'supportLevel': supportLevel.name,
      };

  List<Feature> get availableFeatures => featuresForLevel(supportLevel);

  bool supports(Feature feature) => availableFeatures.contains(feature);
}
