import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ios_club_app/core/models/course_model.dart';
import 'prefs_keys.dart';

/// 课程数据存储管理类
/// 
/// 用于管理课程数据的状态，包括加载、保存、忽略课程等功能。
/// 使用GetX框架进行状态管理，支持响应式更新。
class CourseStore extends GetxController {
  /// 获取CourseStore实例
  static CourseStore get to => Get.find();

  /// 存储所有课程的响应式列表
  final _courses = <CourseModel>[].obs;
  
  /// 存储自定义课程的响应式列表
  final _customCourses = <CourseModel>[].obs;
  
  /// 存储被忽略课程名称的响应式列表
  final _ignoreCourses = <String>[].obs;

  /// 获取所有课程的只读列表
  List<CourseModel> get courses => _courses.toList();
  
  /// 获取自定义课程的只读列表
  List<CourseModel> get customCourses => _customCourses.toList();
  
  /// 获取被忽略课程的只读列表
  List<String> get ignoreCourses => _ignoreCourses.toList();
  
  /// 获取被忽略课程的响应式列表
  RxList<String> get ignoreCoursesList => _ignoreCourses;

  /// 从本地存储加载所有课程数据
  /// 
  /// 从SharedPreferences中读取课程数据，解析为CourseModel列表并存储到响应式列表中。
  /// 如果解析失败，会清除本地存储中的课程数据。
  Future<void> loadCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(PrefsKeys.COURSE_DATA);
    
    if (jsonString != null) {
      try {
        final List<CourseModel> list = [];
        var jsonList = jsonDecode(jsonString);
        jsonList = jsonList["data"];
        for (var json in jsonList) {
          list.add(CourseModel.fromJson(json));
        }
        _courses.assignAll(list);
      } catch (e) {
        // 解析失败，清除数据
        await prefs.remove(PrefsKeys.COURSE_DATA);
      }
    }
    
    // 加载自定义课程
    await loadCustomCourses();
  }

  /// 从本地存储加载自定义课程数据
  /// 
  /// 从SharedPreferences中读取自定义课程数据，解析为CourseModel列表并存储到响应式列表中。
  /// 如果解析失败，会清除本地存储中的自定义课程数据。
  Future<void> loadCustomCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(PrefsKeys.CUSTOM_COURSE_DATA);
    
    if (jsonString != null) {
      try {
        final List<CourseModel> list = [];
        var jsonList = jsonDecode(jsonString);
        jsonList = jsonList["data"];
        for (var json in jsonList) {
          list.add(CourseModel.fromJson(json));
        }
        _customCourses.assignAll(list);
      } catch (e) {
        // 解析失败，清除数据
        await prefs.remove(PrefsKeys.CUSTOM_COURSE_DATA);
      }
    }
  }

  /// 从本地存储加载被忽略的课程数据
  /// 
  /// 从SharedPreferences中读取被忽略的课程数据，解析为字符串列表并存储到响应式列表中。
  /// 如果解析失败，会清除本地存储中的被忽略课程数据。
  Future<void> loadIgnoreCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(PrefsKeys.IGNORE_DATA);
    
    if (jsonString != null) {
      try {
        final List<String> list = [];
        var jsonList = jsonDecode(jsonString);
        jsonList = jsonList["data"];
        for (var json in jsonList) {
          list.add(json);
        }
        _ignoreCourses.assignAll(list);
      } catch (e) {
        // 解析失败，清除数据
        await prefs.remove(PrefsKeys.IGNORE_DATA);
      }
    }
  }

  /// 设置被忽略的课程列表
  /// 
  /// @param ignoreList 被忽略的课程名称列表
  void setIgnoreCourses(List<String> ignoreList) {
    _ignoreCourses.assignAll(ignoreList);
  }

  /// 保存被忽略的课程数据到本地存储
  /// 
  /// @param ignoreList 被忽略的课程名称列表
  Future<void> saveCourseData(List<String> ignoreList) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.IGNORE_DATA, jsonEncode({"data": ignoreList}));
  }

  /// 添加课程到忽略列表
  /// 
  /// 如果课程不在忽略列表中，则添加到忽略列表并保存到本地存储。
  /// 
  /// @param courseName 要忽略的课程名称
  Future<void> addIgnoreCourse(String courseName) async {
    if (!_ignoreCourses.contains(courseName)) {
      _ignoreCourses.add(courseName);

      setIgnoreCourses(_ignoreCourses.toList());
      await saveCourseData(_ignoreCourses.toList());
    }
  }

  /// 从忽略列表中移除课程
  /// 
  /// 如果课程在忽略列表中，则从忽略列表中移除并保存到本地存储。
  /// 
  /// @param courseName 要移除的课程名称
  Future<void> removeIgnoreCourse(String courseName) async {
    if (_ignoreCourses.contains(courseName)) {
      _ignoreCourses.remove(courseName);

      setIgnoreCourses(_ignoreCourses.toList());
      await saveCourseData(_ignoreCourses.toList());
    }
  }

  /// 添加自定义课程
  /// 
  /// 将自定义课程添加到响应式列表并保存到本地存储。
  /// 
  /// @param course 要添加的自定义课程
  Future<void> addCustomCourse(CourseModel course) async {
    _customCourses.add(course);
    await _saveCustomCourses();
  }

  /// 删除自定义课程
  /// 
  /// 从响应式列表中移除自定义课程并保存到本地存储。
  /// 
  /// @param course 要删除的自定义课程
  Future<void> deleteCustomCourse(CourseModel course) async {
    _customCourses.remove(course);
    await _saveCustomCourses();
  }

  /// 保存自定义课程到本地存储
  /// 
  /// 将当前自定义课程列表保存到SharedPreferences中。
  Future<void> _saveCustomCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList = _customCourses.map((course) {
      return {
        'weekIndexes': course.weekIndexes,
        'teachers': course.teachers,
        'room': course.room,
        'courseName': course.courseName,
        'courseCode': course.courseCode,
        'weekday': course.weekday,
        'startUnit': course.startUnit,
        'endUnit': course.endUnit,
        'credits': course.credits,
        'lessonId': course.lessonId,
        'campus': course.campus,
      };
    }).toList();
    
    await prefs.setString(PrefsKeys.CUSTOM_COURSE_DATA, jsonEncode({'data': jsonList}));
  }

  /// 清空所有课程数据
  /// 
  /// 清空响应式列表中的所有课程数据，但不影响本地存储。
  void clearCourseData() {
    _courses.clear();
    _customCourses.clear();
  }
}