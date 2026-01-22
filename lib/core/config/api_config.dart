/// 学校 API 配置
class SchoolConfig {
  /// 学校唯一标识
  final String id;

  /// 学校名称
  final String name;

  /// 教务系统 API 基础 URL
  final String eduApiBaseUrl;

  const SchoolConfig({
    required this.id,
    required this.name,
    required this.eduApiBaseUrl,
  });

  /// 从 JSON 创建
  factory SchoolConfig.fromJson(Map<String, dynamic> json) {
    return SchoolConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      eduApiBaseUrl: json['eduApiBaseUrl'] as String,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'eduApiBaseUrl': eduApiBaseUrl,
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
      eduApiBaseUrl: 'https://xauatapi.xauat.site',
    ),
    // 可以在这里添加更多学校配置
    // SchoolConfig(
    //   id: 'example',
    //   name: '示例大学',
    //   eduApiBaseUrl: 'https://api.example.edu.cn',
    // ),
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
}
