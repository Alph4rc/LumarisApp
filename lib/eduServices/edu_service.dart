// ignore_for_file: unintended_html_in_doc_comment

import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ios_club_app/models/bus_model.dart';
import 'package:ios_club_app/services/data_service.dart';
import 'package:ios_club_app/stores/course_store.dart';
import 'package:ios_club_app/stores/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ios_club_app/models/score_model.dart';
import 'package:ios_club_app/models/user_data.dart';
import 'package:ios_club_app/models/plan_course.dart';
import 'edu_api_client.dart';
import 'login_service.dart';

/// 教务系统服务类
/// 提供与教务系统相关的所有操作，包括数据刷新、登录、信息获取等
/// 所有方法均为静态方法，可以直接调用
class EduService {
  
  /// 刷新所有数据
  /// 该方法会执行登录、获取学期信息、时间信息、课程信息、考试信息和完成情况等操作
  ///
  /// `@return` Future&lt;bool&gt; 返回是否刷新成功
  static Future<bool> refresh() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var now = DateTime.now().millisecondsSinceEpoch;

      final loginResult = await login();
      if (!loginResult) {
        return false;
      }

      var cookieData = await getUserData();
      await getSemester(userData: cookieData);
      await getTime();
      await getCourse(userData: cookieData, isRefresh: true);
      await getExam(userData: cookieData);
      await getInfoCompletion(userData: cookieData);
      await prefs.setInt(PrefsKeys.LAST_FETCH_TIME, now);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }

    return false;
  }

  /// 使用用户名和密码登录并获取数据
  ///
  /// @param username 用户名
  /// @param password 密码
  /// @return `Future&lt;bool&gt;` 返回是否登录成功
  static Future<bool> loginFromData(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();

    final response = await LoginService.login(username, password);
    if (response["success"] == true) {
      await prefs.setString(PrefsKeys.USER_DATA, jsonEncode(response));

      var cookieData = await getUserData();
      var now = DateTime.now().millisecondsSinceEpoch;
      await getSemester(userData: cookieData);
      await getTime();
      await getCourse(userData: cookieData, isRefresh: true);
      await getExam(userData: cookieData);
      await getInfoCompletion(userData: cookieData);
      await prefs.setInt(PrefsKeys.LAST_FETCH_TIME, now);

      final courseStore = Get.put(CourseStore());
      courseStore.loadCourses();
      return true;
    }

    return false;
  }

  /// 登录用户
  /// 从SharedPreferences中读取用户名和密码，然后尝试登录
  ///
  /// @return Future<bool> 返回是否登录成功
  static Future<bool> login() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? username = prefs.getString(PrefsKeys.USERNAME);
      final String? password = prefs.getString(PrefsKeys.PASSWORD);

      if (username == null || password == null) {
        return false;
      }

      if (username.isEmpty || password.isEmpty) {
        return false;
      }

      final preNow = DateTime.now().millisecondsSinceEpoch;
      final response = await LoginService.login(username, password);
      if (kDebugMode) {
        print('登录用时: ${DateTime.now().millisecondsSinceEpoch - preNow}');
      }

      if (response["success"] == true) {
        await prefs.setString(PrefsKeys.USER_DATA, jsonEncode(response));
        var now = DateTime.now().millisecondsSinceEpoch;
        await prefs.setInt(PrefsKeys.LAST_FETCH_TIME, now);

        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }

    return false;
  }

  /// 获取用户数据
  /// 首先尝试从缓存中获取，如果失败则尝试登录后重新获取
  ///
  /// @return Future<UserData?> 返回用户数据或null
  static Future<UserData?> getUserData() async {
    // 尝试获取缓存数据
    final cachedData = await getCookie();
    if (cachedData is UserData) return cachedData;

    // 缓存无效时尝试登录
    final loginSuccess = await login();
    if (!loginSuccess) return null;

    // 登录后重新获取数据
    final freshData = await getCookie();
    if (freshData is UserData) return freshData;

    // 数据仍然无效时抛出异常（或根据业务需求处理）
    throw const FormatException(
        'Cookie data is invalid after successful login');
  }

  /// 获取Cookie数据
  /// 从SharedPreferences中读取缓存的用户数据
  ///
  /// @return Future<UserData?> 返回用户数据或null
  static Future<UserData?> getCookie() async {
    try {
      var now = DateTime.now().millisecondsSinceEpoch;

      final prefs = await SharedPreferences.getInstance();
      final lastFetchTime = prefs.getInt(PrefsKeys.LAST_FETCH_TIME);
      if (lastFetchTime == null || now - lastFetchTime > 1000 * 60 * 20) {
        // 20小时
        return null;
      }
      final String? jsonString = prefs.getString(PrefsKeys.USER_DATA);

      if (jsonString != null) {
        return UserData.fromJson(jsonDecode(jsonString));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error reading local data: $e');
      }
    }
    return null;
  }

  /// 获取本学期成绩
  /// 从服务器获取当前学期的成绩信息并存储到本地
  ///
  /// @param userData 用户数据，如果为null则尝试从本地获取
  /// @return Future<void> 无返回值
  static Future<void> getThisSemester({UserData? userData}) async {
    try {
      final response = await EduApiClient.getThisSemester();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(PrefsKeys.THIS_SEMESTER_DATA, response);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  /// 获取学期信息
  /// 从服务器获取学生的学期列表并存储到本地
  ///
  /// @param userData 用户数据，如果为null则尝试从本地获取
  /// @return Future<void> 无返回值
  static Future<void> getSemester({UserData? userData}) async {
    UserData? cookieData = userData ?? await getUserData();
    if (cookieData == null) {
      return;
    }

    try {
      final response = await EduApiClient.getSemester(cookieData.studentId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(PrefsKeys.SEMESTER_DATA, response);

      final now = DateTime.now().microsecondsSinceEpoch;
      await prefs.setInt(PrefsKeys.SEMESTER_TIME, now);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  /// 获取课程信息
  /// 从服务器获取学生的课程信息并存储到本地
  /// 支持刷新控制和缓存机制，避免频繁请求
  ///
  /// @param userData 用户数据，如果为null则尝试从本地获取
  /// @param isRefresh 是否强制刷新，忽略缓存
  /// @return Future<void> 无返回值
  static Future<void> getCourse(
      {UserData? userData, bool isRefresh = false}) async {
    final time = await DataService.getTime();
    final week = await DataService.getWeek();
    if (!isRefresh &&
        (time["startTime"] == null ||
            time["endTime"] == null ||
            week["week"] == null)) {
      return;
    }

    final startTime = DateTime.parse(time["startTime"]!);
    final endTime = DateTime.parse(time["endTime"]!);

    if (!isRefresh &&
        (DateTime.now().isBefore(startTime) ||
            DateTime.now().isAfter(endTime))) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(PrefsKeys.COURSE_DATA);
    if (jsonString != null &&
        jsonString.isNotEmpty &&
        week["week"] != null &&
        week["week"] is int &&
        week["week"]! > 2 &&
        !isRefresh) {
      return;
    }

    UserData? cookieData = userData ?? await getUserData();
    if (cookieData == null) {
      return;
    }

    try {
      final response = await EduApiClient.getCourse(cookieData.studentId);
      if (response.isNotEmpty) {
        // 存储到本地
        await prefs.setString(
            PrefsKeys.COURSE_DATA, jsonEncode(jsonDecode(response)));
        await DataService.setIgnore([]);
        // 更新课程数据刷新时间
        await prefs.setInt(PrefsKeys.COURSE_LAST_FETCH_TIME, DateTime.now().millisecondsSinceEpoch);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  /// 获取所有学期成绩
  /// 从服务器获取学生所有学期的成绩信息并存储到本地
  ///
  /// @param userData 用户数据，如果为null则尝试从本地获取
  /// @return Future<void> 无返回值
  static Future<void> getAllScore({UserData? userData}) async {
    var cookieData = userData ?? await getUserData();
    if (cookieData == null) {
      return;
    }

    try {
      final list = await DataService.getSemester();
      final Map<String, String> json = {};
      for (var item in list) {
        final response = await EduApiClient.getScore(cookieData.studentId, item.semester);
        json[item.semester] = response;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(PrefsKeys.ALL_SCORE_DATA, jsonEncode(json));
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  /// 从本地获取所有学期成绩
  /// 优先从本地缓存获取成绩信息，如果缓存过期或需要刷新，则从服务器获取
  ///
  /// @param isRefresh 是否强制刷新，忽略缓存
  /// @return Future<List<ScoreList>> 返回所有学期的成绩列表
  static Future<List<ScoreList>> getAllScoreFromLocal(
      {bool isRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(PrefsKeys.ALL_SCORE_DATA);
    var now = DateTime.now().millisecondsSinceEpoch;

    final semesters = await DataService.getSemester();

    final last = prefs.getInt(PrefsKeys.LAST_SCORE_TIME);
    if (last != null && !isRefresh) {
      if (now - prefs.getInt(PrefsKeys.LAST_SCORE_TIME)! < 1000 * 60 * 60) {
        if (jsonString != null && jsonString.isNotEmpty) {
          final List<ScoreList> list = [];
          final Map<String, dynamic> jsonList = jsonDecode(jsonString);
          jsonList.forEach((String key, value) {
            final scoreList = jsonDecode(value);
            list.add(ScoreList(
              semester: semesters.firstWhere((x) => x.semester == key),
              list: (scoreList as List)
                  .map((e) => ScoreModel.fromJson(e))
                  .toList(),
            ));
          });

          return list;
        }
      }
    }

    UserData? cookieData = await getUserData();
    if (cookieData == null) {
      return [];
    }

    try {
      final list = await DataService.getSemester();
      final Map<String, String> json = {};
      for (var item in list) {
        final response = await EduApiClient.getScore(cookieData.studentId, item.semester);
        json[item.semester] = response;
      }
      
      await prefs.setString(PrefsKeys.ALL_SCORE_DATA, jsonEncode(json));

      final List<ScoreList> scoreReturnList = [];
      final Map<String, dynamic> jsonList = jsonDecode(jsonEncode(json));
      jsonList.forEach((String key, value) {
        final scoreList = jsonDecode(value);
        scoreReturnList.add(ScoreList(
          semester: semesters.firstWhere((x) => x.semester == key),
          list: (scoreList as List).map((e) => ScoreModel.fromJson(e)).toList(),
        ));
      });

      await prefs.setInt(PrefsKeys.LAST_SCORE_TIME, now);
      return scoreReturnList;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }

    return [];
  }

  /// 获取考试信息
  /// 从服务器获取学生的考试信息并存储到本地
  ///
  /// @param userData 用户数据，如果为null则尝试从本地获取
  /// @return Future<void> 无返回值
  static Future<void> getExam({UserData? userData}) async {
    UserData? cookieData = userData ?? await getUserData();
    if (cookieData == null) {
      return;
    }

    try {
      final response = await EduApiClient.getExam(cookieData.studentId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          PrefsKeys.EXAM_DATA, jsonEncode(jsonDecode(response)));
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  /// 获取时间信息
  /// 从服务器获取当前时间信息并存储到本地
  /// 用于计算当前周次、当前节次等
  ///
  /// @return Future<void> 无返回值
  static Future<void> getTime() async {
    try {
      final response = await EduApiClient.getTime();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          PrefsKeys.TIME_DATA, jsonEncode(jsonDecode(response)));
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(PrefsKeys.TIME_LAST_UPDATED, now);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  /// 获取学生信息完成度
  /// 从服务器获取学生信息的完成情况并存储到本地
  ///
  /// @param userData 用户数据，如果为null则尝试从本地获取
  /// @return Future<void> 无返回值
  static Future<void> getInfoCompletion({UserData? userData}) async {
    UserData? cookieData = userData ?? await getUserData();
    if (cookieData == null) {
      return;
    }

    try {
      final response = await EduApiClient.getInfoCompletion();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          PrefsKeys.INFO_DATA, jsonEncode(jsonDecode(response)));
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  /// 获取校巴信息
  /// 从服务器获取校巴运行信息，支持按日期查询
  /// 如果不指定日期或指定当前日期，则只返回未来的校巴班次
  ///
  /// @param dayDate 查询日期，格式为yyyy-MM-dd，可为null表示当天
  /// @return Future<BusModel> 返回校巴信息模型
  static Future<BusModel> getBus({String? dayDate}) async {
    try {
      final response = await EduApiClient.getBus(dayDate: dayDate);
      final now = DateTime.now();
      var result = BusModel.fromJson(jsonDecode(response));
      if (result.records.isNotEmpty &&
          (dayDate == null || dayDate.isEmpty || dayDate == DateFormat('yyyy-MM-dd').format(now))) {
        result.records = result.records.where((element) {
          final split = element.runTime.split(':');
          if (split.length < 2) return false;
          var time = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(split[0]),
            int.parse(split[1]),
          );
          return time.isAfter(now);
        }).toList();
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }

    return BusModel(records: [], total: 0);
  }

  /// 获取培养方案
  /// 从服务器获取学生的培养方案信息
  ///
  /// @return Future<List<PlanCourse>> 返回培养方案课程列表
  static Future<List<PlanCourse>> getProgram() async {
    UserData? cookieData = await getUserData();
    if (cookieData == null) {
      return [];
    }

    try {
      final response = await EduApiClient.getProgram(cookieData.studentId);
      var result = jsonDecode(response);
      if (kDebugMode) {
        print('找到了培养方案：${result.length}');
      }
      return result.map<PlanCourse>((e) => PlanCourse.fromJson(e)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }

    return [];
  }

  /// 获取培养方案字典
  /// 从服务器获取学生的培养方案字典，按课程类型分类
  ///
  /// @return Future<List<PlanCourseList>> 返回分类后的培养方案列表
  static Future<List<PlanCourseList>> getPrograms() async {
    UserData? cookieData = await getUserData();
    if (cookieData == null) {
      return [];
    }

    try {
      final response = await EduApiClient.getProgramDic(cookieData.studentId);
      var result = jsonDecode(response);
      if (kDebugMode) {
        print('找到了培养方案：${result.length}');
      }
      return result.entries
          .map<PlanCourseList>(
              (entry) => PlanCourseList.fromMap(entry.key, entry.value))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }

    return [];
  }
}