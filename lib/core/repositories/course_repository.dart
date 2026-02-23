import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:ios_club_app/core/models/course_model.dart';
import 'package:ios_club_app/core/services/hive_manager.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

/// 课程数据仓库
///
/// 每门课程作为独立 Hive 条目存储：
///   course_{lessonId}           — 正式课程（lessonId 非空）
///   course_custom_{ts}_{index}  — 自定义课程（lessonId 为空）
class CourseRepository {
  static const String _boxName = HiveManager.courseBoxName;
  static const String _keyPrefix = 'course_';
  static const String _legacyKey = 'current_courses';

  Future<Box> _getBox() async {
    return await HiveManager.instance.openBox(_boxName);
  }

  /// 生成课程的存储 key
  String _keyFor(CourseModel course, int index) {
    final id = course.lessonId;
    if (id.isNotEmpty) {
      return '$_keyPrefix$id';
    }
    final ts = DateTime.now().millisecondsSinceEpoch;
    return '${_keyPrefix}custom_${ts}_$index';
  }

  /// 保存课程列表（全量替换）
  Future<void> saveCourses(List<CourseModel> courses) async {
    try {
      final box = await _getBox();

      // 删除所有 course_ 前缀条目
      final oldKeys = box.keys
          .where((k) => k is String && k.startsWith(_keyPrefix))
          .toList();
      await box.deleteAll(oldKeys);

      // 防御性清理旧格式
      if (box.containsKey(_legacyKey)) {
        await box.delete(_legacyKey);
      }

      // 批量写入
      if (courses.isEmpty) return;
      final entries = <String, CourseModel>{};
      for (var i = 0; i < courses.length; i++) {
        entries[_keyFor(courses[i], i)] = courses[i];
      }
      await box.putAll(entries);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save courses to Hive', error: e, stackTrace: stackTrace);
    }
  }

  /// 获取课程列表
  Future<List<CourseModel>> getCourses() async {
    try {
      final box = await _getBox();

      // 检测旧格式并迁移
      if (box.containsKey(_legacyKey)) {
        return await _migrateFromLegacyHive(box);
      }

      // 读取所有 course_ 前缀条目
      final courses = box.keys
          .where((k) => k is String && k.startsWith(_keyPrefix))
          .map((k) => box.get(k))
          .whereType<CourseModel>()
          .toList();

      if (courses.isNotEmpty) return courses;

      // Hive 中无数据，尝试从 SharedPreferences 迁移
      return await _migrateFromPrefs();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get courses from Hive', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// 按 lessonId 查询单门课程
  Future<CourseModel?> getCourseById(String id) async {
    try {
      final box = await _getBox();
      final byPrefixed = box.get('$_keyPrefix$id');
      if (byPrefixed is CourseModel) return byPrefixed;
      final direct = box.get(id);
      if (direct is CourseModel) return direct;
      return null;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get course by id', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// 清除课程数据
  Future<void> clear() async {
    try {
      final box = await _getBox();
      final keys = box.keys
          .where((k) => k is String && k.startsWith(_keyPrefix))
          .toList();
      await box.deleteAll(keys);
      if (box.containsKey(_legacyKey)) {
        await box.delete(_legacyKey);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to clear courses from Hive', error: e, stackTrace: stackTrace);
    }
  }

  /// 将旧单 key 格式迁移到新多 key 格式
  Future<List<CourseModel>> _migrateFromLegacyHive(Box box) async {
    try {
      AppLogger.info('Migrating course data from legacy Hive format...');
      final dynamic data = box.get(_legacyKey);
      final courses = <CourseModel>[];
      if (data is List) {
        for (final item in data) {
          if (item is CourseModel) courses.add(item);
        }
      }
      // saveCourses 会自动删除旧 key
      await saveCourses(courses);
      AppLogger.info('Legacy Hive migration completed. Count: ${courses.length}');
      return courses;
    } catch (e) {
      AppLogger.warning('Failed to migrate from legacy Hive format', error: e);
      return [];
    }
  }

  /// 从 SharedPreferences 迁移数据
  Future<List<CourseModel>> _migrateFromPrefs() async {
    final prefs = PrefsService.instance;
    // ignore: deprecated_member_use
    final jsonString = prefs.getString(PrefsKeys.COURSE_DATA);

    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        AppLogger.info('Migrating course data from SharedPreferences to Hive...');
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final courses = <CourseModel>[];
        for (final e in jsonList) {
          try {
            courses.add(CourseModel.fromJson(e as Map<String, dynamic>));
          } catch (itemErr) {
            AppLogger.warning('Skipping corrupt course entry during migration', error: itemErr);
          }
        }

        await saveCourses(courses);

        AppLogger.info('Course data migration completed. Count: ${courses.length}');
        return courses;
      } catch (e) {
        AppLogger.warning('Failed to migrate course data', error: e);
      }
    }
    return [];
  }
}
