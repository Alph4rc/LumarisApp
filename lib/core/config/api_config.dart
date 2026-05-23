/// 学校支持级别
enum SupportLevel {
  /// 基础支持：仅可查看课表
  basic,

  /// 高级支持：可查看、编辑、导出课表，接收通知
  advanced;
}

/// 应用功能（用于权限控制）
enum AppFeature {
  viewTimetable,
  editTimetable,
  exportTimetable,
  notifications,
  calendarSync;
}

/// 根据支持级别获取可用功能列表
List<AppFeature> featuresForLevel(SupportLevel level) {
  switch (level) {
    case SupportLevel.basic:
      return [AppFeature.viewTimetable];
    case SupportLevel.advanced:
      return AppFeature.values;
  }
}

/// 学校 API 配置
class SchoolConfig {
  /// 学校唯一标识
  final String id;

  /// 学校全称
  final String name;

  /// 学校简称
  final String shortName;

  /// 教务系统 API 基础 URL
  final String eduApiBaseUrl;

  /// 支持级别
  final SupportLevel supportLevel;

  const SchoolConfig({
    required this.id,
    required this.name,
    required this.shortName,
    required this.eduApiBaseUrl,
    this.supportLevel = SupportLevel.basic,
  });

  /// 可用功能列表（根据支持级别自动派生）
  List<AppFeature> get features => featuresForLevel(supportLevel);

  /// 是否支持指定功能
  bool supports(AppFeature feature) => features.contains(feature);

  /// 从 JSON 创建
  factory SchoolConfig.fromJson(Map<String, dynamic> json) {
    final levelStr = json['supportLevel'] as String?;
    final level = levelStr != null
        ? SupportLevel.values.firstWhere((e) => e.name == levelStr)
        : SupportLevel.basic;
    return SchoolConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String? ?? json['name'] as String,
      eduApiBaseUrl: json['eduApiBaseUrl'] as String,
      supportLevel: level,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'eduApiBaseUrl': eduApiBaseUrl,
      'supportLevel': supportLevel.name,
    };
  }
}

/// API 配置管理类
class ApiConfig {
  /// 预定义的学校配置列表
  static const List<SchoolConfig> schools = [
    SchoolConfig(
      id: 'xauat',
      name: '西安建筑科技大学',
      shortName: '西建大',
      eduApiBaseUrl: 'https://xauatapi.xauat.site',
      supportLevel: SupportLevel.advanced,
    ),
    SchoolConfig(
      id: 'snnu',
      name: '陕西师范大学',
      shortName: '陕师大',
      eduApiBaseUrl: 'https://snnuapi.example.edu.cn',
      supportLevel: SupportLevel.advanced,
    ),
    SchoolConfig(
      id: 'xidian',
      name: '西安电子科技大学',
      shortName: '西电',
      eduApiBaseUrl: 'https://xidianapi.example.edu.cn',
      supportLevel: SupportLevel.advanced,
    ),
    SchoolConfig(
      id: 'nwu',
      name: '西北大学',
      shortName: '西大',
      eduApiBaseUrl: 'https://nwuapi.example.edu.cn',
      supportLevel: SupportLevel.basic,
    ),
    SchoolConfig(
      id: 'xaut',
      name: '西安理工大学',
      shortName: '西安理工',
      eduApiBaseUrl: 'https://xautapi.example.edu.cn',
      supportLevel: SupportLevel.basic,
    ),
  ];

  /// 默认学校 ID
  static const String defaultSchoolId = 'xauat';

  /// 根据学校 ID 获取配置
  static SchoolConfig? getSchoolById(String schoolId) {
    try {
      return schools.firstWhere((school) => school.id == schoolId);
    } catch (e) {
      return null;
    }
  }

  /// 获取默认学校配置
  static SchoolConfig getDefaultSchool() {
    return getSchoolById(defaultSchoolId) ?? schools.first;
  }

  /// 获取所有学校列表
  static List<SchoolConfig> getAllSchools() {
    return schools;
  }

  /// 搜索学校（按名称或简称模糊匹配）
  static List<SchoolConfig> searchSchools(String query) {
    if (query.isEmpty) return schools;
    final lower = query.toLowerCase();
    return schools.where((s) {
      return s.name.toLowerCase().contains(lower) ||
          s.shortName.toLowerCase().contains(lower);
    }).toList();
  }
}
