import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:ios_club_app/core/models/course_model.dart';
import 'package:ios_club_app/core/services/hive_manager.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

/// 课程数据仓库
/// 
/// 负责课程数据的持久化存储（Hive）和迁移
class CourseRepository {
  static const String _boxName = HiveManager.courseBoxName;
  
  /// 获取 Box
  Future<Box<CourseModel>> _getBox() async {
    return await HiveManager.instance.openBox<CourseModel>(_boxName);
  }
  
  /// 保存课程列表
  /// 
  /// 现在的设计是将所有课程作为一个List存储，或者按ID存储。
  /// 原有的 SharedPreferences 实现是将整个列表序列化为一个 JSON 字符串。
  /// 在 Hive 中，我们可以直接存储 List<CourseModel>，或者将每门课作为单独的条目。
  /// 为了查询方便，建议将每门课作为单独条目存储，Key 可以是 courseCode 或者自动生成的 ID。
  /// 但考虑到 current course data 是一组，我们可以用一个特定的 Key (如 'current_courses') 存储这个列表。
  /// 或者，更灵活的方式是：Box<CourseModel> 存储所有课程，但我们需要区分"当前学期课程"。
  /// 
  /// 简单起见，我们沿用"一组课程"的概念，但在 Hive 中，我们可能需要一个 Wrapper 或者直接存 List。
  /// Hive Box 的值可以是 List，但更好的做法是定义一个 CourseList 模型，或者直接 put('current', list)。
  /// 由于 Hive 不支持直接 put List<T> 到动态类型 Box 而保留类型信息（除非用 wrapper），
  /// 我们这里选择将 List<CourseModel> 存储在 Box 的一个 Key 下。
  Future<void> saveCourses(List<CourseModel> courses) async {
    try {
      final box = await HiveManager.instance.openBox(HiveManager.courseBoxName);
      // Hive 支持直接存储 List<dynamic>，只要里面的元素注册了 Adapter
      await box.put('current_courses', courses);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save courses to Hive', error: e, stackTrace: stackTrace);
    }
  }
  
  /// 获取课程列表
  Future<List<CourseModel>> getCourses() async {
    try {
      final box = await HiveManager.instance.openBox(HiveManager.courseBoxName);
      
      // 尝试从 Hive 读取
      final dynamic data = box.get('current_courses');
      
      if (data != null) {
        if (data is List) {
          return data.cast<CourseModel>();
        }
      }
      
      // 如果 Hive 中没有，尝试从 SharedPreferences 迁移
      return await _migrateFromPrefs();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get courses from Hive', error: e, stackTrace: stackTrace);
      return [];
    }
  }
  
  /// 从 SharedPreferences 迁移数据
  Future<List<CourseModel>> _migrateFromPrefs() async {
    final prefs = PrefsService.instance;
    final jsonString = prefs.getString(PrefsKeys.COURSE_DATA);
    
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        AppLogger.info('Migrating course data from SharedPreferences to Hive...');
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final courses = jsonList.map((e) => CourseModel.fromJson(e)).toList();
        
        // 保存到 Hive
        await saveCourses(courses);
        
        // 删除旧数据 (可选，为了安全起见可以先保留，确认稳定后再删)
        // await prefs.remove(PrefsKeys.COURSE_DATA);
        
        AppLogger.info('Course data migration completed. Count: ${courses.length}');
        return courses;
      } catch (e) {
        AppLogger.warning('Failed to migrate course data', error: e);
      }
    }
    return [];
  }
  
  /// 清除课程数据
  Future<void> clear() async {
    final box = await HiveManager.instance.openBox(HiveManager.courseBoxName);
    await box.delete('current_courses');
  }
}
