import 'dart:convert';
import 'package:get/get.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
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

  /// 存储被忽略课程名称的响应式列表
  final _ignoreCourses = <String>[].obs;

  /// 获取所有课程的只读列表
  List<CourseModel> get courses => _courses.toList();

  /// 获取被忽略课程的只读列表
  List<String> get ignoreCourses => _ignoreCourses.toList();

  /// 获取被忽略课程的响应式列表
  RxList<String> get ignoreCoursesList => _ignoreCourses;

  /// 获取自定义课程列表
  List<CourseModel> get customCourses =>
      _courses.where((course) => course.isCustom).toList();

  /// 从本地存储加载所有课程数据
  ///
  /// 从SharedPreferences中读取课程数据，解析为CourseModel列表并存储到响应式列表中。
  /// 同时加载自定义课程数据并合并到课程列表中。
  /// 如果解析失败，会清除本地存储中的课程数据。
  Future<void> loadCourses() async {
    final prefs = PrefsService.instance;
    final List<CourseModel> allCourses = [];

    // 加载系统课程数据
    final String? systemJsonString = prefs.getString(PrefsKeys.COURSE_DATA);
    if (systemJsonString != null) {
      try {
        var jsonList = jsonDecode(systemJsonString);
        jsonList = jsonList["data"];
        for (var json in jsonList) {
          allCourses.add(CourseModel.fromJson(json));
        }
      } catch (e) {
        // 解析失败，清除数据
        await prefs.remove(PrefsKeys.COURSE_DATA);
      }
    }

    // 加载自定义课程数据
    final String? customJsonString = prefs.getString('custom_courses');
    if (customJsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(customJsonString);
        for (var json in jsonList) {
          final course = CourseModel.fromJson(json);
          if (course.isCustom) {
            allCourses.add(course);
          }
        }
      } catch (e) {
        // 解析失败，清除自定义课程数据
        await prefs.remove('custom_courses');
      }
    }

    _courses.assignAll(allCourses);
  }

  /// 从本地存储加载被忽略的课程数据
  ///
  /// 从SharedPreferences中读取被忽略的课程数据，解析为字符串列表并存储到响应式列表中。
  /// 如果解析失败，会清除本地存储中的被忽略课程数据。
  Future<void> loadIgnoreCourses() async {
    final prefs = PrefsService.instance;
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
    final prefs = PrefsService.instance;
    await prefs.setString(
        PrefsKeys.IGNORE_DATA, jsonEncode({"data": ignoreList}));
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

  /// 清空所有课程数据
  ///
  /// 清空响应式列表中的所有课程数据，但不影响本地存储。
  void clearCourseData() {
    _courses.clear();
  }
}
