import 'package:ios_club_app/features/basic/models/school.dart';

/// 应用功能（用于 UI 权限控制）
enum AppFeature {
  viewTimetable,
  editTimetable,
  exportTimetable,
  notifications,
  calendarSync;
}

/// 从后端 Feature 列表映射出 UI AppFeature 集合
Set<AppFeature> appFeaturesForFeatureList(List<Feature> features) {
  final result = <AppFeature>{};
  for (final f in features) {
    switch (f) {
      case Feature.timetable:
        result.addAll([
          AppFeature.viewTimetable,
          AppFeature.editTimetable,
          AppFeature.exportTimetable,
          AppFeature.calendarSync,
        ]);
      case Feature.login:
        result.add(AppFeature.notifications);
      default:
        break;
    }
  }
  return result;
}

/// API 配置管理类
class ApiConfig {
  /// 默认学校 code
  static const String defaultSchoolCode = 'xauat';

  /// API 失败时的本地 fallback 学校列表
  static List<School> get fallbackSchools => [
        School(
          code: 'xauat',
          name: '西安建筑科技大学',
          website: 'https://xauatapi.xauat.site',
          features: [Feature.timetable, Feature.gradeQuery, Feature.login],
          enabled: true,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
        School(
          code: 'snnu',
          name: '陕西师范大学',
          website: 'https://snnuapi.example.edu.cn',
          features: [Feature.timetable, Feature.gradeQuery, Feature.login],
          enabled: true,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
        School(
          code: 'xidian',
          name: '西安电子科技大学',
          website: 'https://xidianapi.example.edu.cn',
          features: [Feature.timetable, Feature.gradeQuery, Feature.login],
          enabled: true,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
        School(
          code: 'nwu',
          name: '西北大学',
          website: 'https://nwuapi.example.edu.cn',
          features: [Feature.timetable],
          enabled: true,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
        School(
          code: 'xaut',
          name: '西安理工大学',
          website: 'https://xautapi.example.edu.cn',
          features: [Feature.timetable],
          enabled: true,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
      ];

  /// 在列表中按 code 查找学校
  static School? findSchoolByCode(List<School> schools, String code) {
    try {
      return schools.firstWhere((s) => s.code == code);
    } catch (e) {
      return null;
    }
  }

  /// 按名称或 code 本地搜索学校
  static List<School> searchSchoolsLocally(List<School> schools, String query) {
    if (query.isEmpty) return schools;
    final lower = query.toLowerCase();
    return schools
        .where((s) =>
            s.name.toLowerCase().contains(lower) ||
            s.code.toLowerCase().contains(lower))
        .toList();
  }
}

/// UI 层扩展方法：为后端 School 模型添加前端权限判断能力
extension SchoolUx on School {
  /// 是否支持指定 UI 功能（从后端 Feature 列表映射）
  bool supports(AppFeature feature) =>
      appFeaturesForFeatureList(features).contains(feature);
}
