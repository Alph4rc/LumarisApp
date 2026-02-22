// ignore_for_file: unintended_html_in_doc_comment

import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ios_club_app/core/models/bus_model.dart';
import 'package:ios_club_app/core/services/data_service.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/models/score_model.dart';
import 'package:ios_club_app/core/models/user_data.dart';
import 'package:ios_club_app/core/models/plan_course.dart';
import 'package:ios_club_app/core/models/course_model.dart';
import 'edu_api_client.dart';
import 'login_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/core/utils/request_cache.dart';

import 'package:ios_club_app/core/repositories/course_repository.dart';
import 'package:ios_club_app/core/repositories/score_repository.dart';
import 'package:ios_club_app/core/services/secure_storage_service.dart';

/// 教务系统服务类
/// 提供与教务系统相关的所有操作，包括数据刷新、登录、信息获取等
/// 所有方法均为静态方法，可以直接调用
class EduService {
  /// 迁移旧的凭证数据到安全存储
  static Future<void> migrateCredentials() async {
    final prefs = PrefsService.instance;
    final secureStorage = SecureStorageService.instance;

    // 迁移教务系统账号
    final username = prefs.getString(PrefsKeys.USERNAME);
    final password = prefs.getString(PrefsKeys.PASSWORD);

    if (username != null && username.isNotEmpty) {
      await secureStorage.write(key: PrefsKeys.USERNAME, value: username);
      await prefs.remove(PrefsKeys.USERNAME);
    }

    if (password != null && password.isNotEmpty) {
      await secureStorage.write(key: PrefsKeys.PASSWORD, value: password);
      await prefs.remove(PrefsKeys.PASSWORD);
    }

    // 迁移社团账号
    final clubName = prefs.getString(PrefsKeys.CLUB_NAME);
    final clubId = prefs.getString(PrefsKeys.CLUB_ID);
    final memberJwt = prefs.getString(PrefsKeys.MEMBER_JWT);

    if (clubName != null && clubName.isNotEmpty) {
      await secureStorage.write(key: PrefsKeys.CLUB_NAME, value: clubName);
      await prefs.remove(PrefsKeys.CLUB_NAME);
    }

    if (clubId != null && clubId.isNotEmpty) {
      await secureStorage.write(key: PrefsKeys.CLUB_ID, value: clubId);
      await prefs.remove(PrefsKeys.CLUB_ID);
    }

    if (memberJwt != null && memberJwt.isNotEmpty) {
      await secureStorage.write(key: PrefsKeys.MEMBER_JWT, value: memberJwt);
      await prefs.remove(PrefsKeys.MEMBER_JWT);
    }

    // 迁移支付卡号
    final paymentNum = prefs.getString(PrefsKeys.PAYMENT_NUM);
    if (paymentNum != null && paymentNum.isNotEmpty) {
      await secureStorage.write(key: PrefsKeys.PAYMENT_NUM, value: paymentNum);
      await prefs.remove(PrefsKeys.PAYMENT_NUM);
    }
  }

  /// 清理所有教务系统相关的缓存数据
  /// 包括SharedPreferences中的缓存数据和HTTP请求层的缓存
  ///
  /// 该方法应该在用户登录新账号前调用，以避免显示旧用户的数据
  static Future<void> clearEduCache() async {
    try {
      final prefs = PrefsService.instance;

      AppLogger.debug('[EduService] 开始清理教务系统缓存');

      // 清理 SharedPreferences 中的教务相关数据
      final eduKeys = [
        PrefsKeys.USER_DATA,
        PrefsKeys.LAST_FETCH_TIME,
        PrefsKeys.COURSE_DATA,
        PrefsKeys.IGNORE_DATA,
        PrefsKeys.COURSE_LAST_FETCH_TIME,
        PrefsKeys.SEMESTER_DATA,
        PrefsKeys.SEMESTER_TIME,
        PrefsKeys.ALL_SCORE_DATA,
        PrefsKeys.LAST_SCORE_TIME,
        PrefsKeys.THIS_SEMESTER_DATA,
        PrefsKeys.EXAM_DATA,
        PrefsKeys.EXAM_TIME,
        PrefsKeys.TIME_DATA,
        PrefsKeys.TIME_LAST_UPDATED,
        PrefsKeys.INFO_DATA,
        PrefsKeys.INFO_DATA_TIME,
        '${PrefsKeys.ALL_SCORE_DATA}_TIMESTAMPS',
      ];

      for (final key in eduKeys) {
        await prefs.remove(key);
      }

      // 清除安全存储中的用户名密码
      // 注意：通常不建议清除用户名，方便用户下次登录，但如果这是完全退出或切换账号，则可能需要清除
      // 这里 clearEduCache 通常在登录新账号前调用，所以不清除用户名密码可能是为了保留记录
      // 但如果用户显式退出，应该在 logout 方法中清除

      AppLogger.debug('[EduService] SharedPreferences 缓存清理完成');

      // 清理 HTTP 请求层的缓存（教务系统相关）
      await RequestCache().deleteByPattern(RegExp(r'.*/course.*'));
      await RequestCache().deleteByPattern(RegExp(r'.*/score.*'));
      await RequestCache().deleteByPattern(RegExp(r'.*/exam.*'));
      await RequestCache().deleteByPattern(RegExp(r'.*/semester.*'));
      await RequestCache().deleteByPattern(RegExp(r'.*/program.*'));
      await RequestCache().deleteByPattern(RegExp(r'.*/info.*'));
      await RequestCache().deleteByPattern(RegExp(r'.*/time.*'));

      AppLogger.debug('[EduService] HTTP 请求层缓存清理完成');
    } catch (e, stackTrace) {
      AppLogger.error('清理教务系统缓存失败', error: e, stackTrace: stackTrace);
    }
  }

  /// 刷新所有数据
  /// 该方法会执行登录、获取学期信息、时间信息、课程信息、考试信息和完成情况等操作
  ///
  /// `@return` Future&lt;bool&gt; 返回是否刷新成功
  static Future<bool> refresh() async {
    try {
      final prefs = PrefsService.instance;
      var now = DateTime.now().millisecondsSinceEpoch;

      final loginResult = await login();
      if (!loginResult) {
        return false;
      }

      var cookieData = await getUserData();

      // 并行获取不依赖其他数据的请求
      await Future.wait([
        getSemester(userData: cookieData),
        getTime(),
        getExam(userData: cookieData),
        getInfoCompletion(userData: cookieData),
      ]);

      // getCourse 依赖 getTime 的数据，需要在 getTime 完成后执行
      await getCourse(userData: cookieData, isRefresh: true);

      await prefs.setInt(PrefsKeys.LAST_FETCH_TIME, now);

      // 更新 Store
      final courseStore = Get.put(CourseStore());
      courseStore.loadCourses();

      await prefs.setInt(PrefsKeys.COURSE_LAST_FETCH_TIME,
          DateTime.now().millisecondsSinceEpoch);

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('刷新数据失败', error: e, stackTrace: stackTrace);
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

    // 在登录前清理旧用户的缓存数据
    await clearEduCache();

    final prefs = PrefsService.instance;

    final response = await LoginService.login(username, password);
    if (response["success"] == true) {
      await prefs.setString(PrefsKeys.USER_DATA, jsonEncode(response));

      var cookieData = await getUserData();
      var now = DateTime.now().millisecondsSinceEpoch;

      // 并行获取不依赖其他数据的请求
      await Future.wait([
        getSemester(userData: cookieData),
        getTime(),
        getExam(userData: cookieData),
        getInfoCompletion(userData: cookieData),
      ]);

      // getCourse 依赖 getTime 的数据，需要在 getTime 完成后执行
      await getCourse(userData: cookieData, isRefresh: true);

      await prefs.setInt(PrefsKeys.LAST_FETCH_TIME, now);

      final courseStore = Get.put(CourseStore());
      courseStore.loadCourses();
      return true;
    }

    return false;
  }

  /// 登录用户
  /// 从 SecureStorageService 中读取用户名和密码，然后尝试登录
  ///
  /// @return Future<bool> 返回是否登录成功
  static Future<bool> login() async {
    try {
      final prefs = PrefsService.instance;
      final secureStorage = SecureStorageService.instance;

      // 尝试迁移旧数据
      await migrateCredentials();

      final String? username =
          await secureStorage.read(key: PrefsKeys.USERNAME);
      final String? password =
          await secureStorage.read(key: PrefsKeys.PASSWORD);

      if (username == null || password == null) {
        return false;
      }

      if (username.isEmpty || password.isEmpty) {
        return false;
      }

      final preNow = DateTime.now().millisecondsSinceEpoch;
      final response = await LoginService.login(username, password);
      if (kDebugMode) {
        AppLogger.debug(
            '登录用时: ${DateTime.now().millisecondsSinceEpoch - preNow}');
      }

      if (response["success"] == true) {
        await prefs.setString(PrefsKeys.USER_DATA, jsonEncode(response));
        var now = DateTime.now().millisecondsSinceEpoch;
        await prefs.setInt(PrefsKeys.LAST_FETCH_TIME, now);

        return true;
      }
    } catch (e, stackTrace) {
      AppLogger.error('登录失败', error: e, stackTrace: stackTrace);
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

      final prefs = PrefsService.instance;
      final lastFetchTime = prefs.getInt(PrefsKeys.LAST_FETCH_TIME);
      if (lastFetchTime == null || now - lastFetchTime > 1000 * 60 * 20) {
        // 20小时
        return null;
      }
      final String? jsonString = prefs.getString(PrefsKeys.USER_DATA);

      if (jsonString != null) {
        return UserData.fromJson(jsonDecode(jsonString));
      }
    } catch (e, stackTrace) {
      AppLogger.error('读取本地数据失败', error: e, stackTrace: stackTrace);
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
      final prefs = PrefsService.instance;
      await prefs.setString(PrefsKeys.THIS_SEMESTER_DATA, response);
    } catch (e, stackTrace) {
      AppLogger.error('获取本学期成绩失败', error: e, stackTrace: stackTrace);
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
      final prefs = PrefsService.instance;
      await prefs.setString(PrefsKeys.SEMESTER_DATA, response);

      final now = DateTime.now().microsecondsSinceEpoch;
      await prefs.setInt(PrefsKeys.SEMESTER_TIME, now);
    } catch (e, stackTrace) {
      AppLogger.error('获取学期信息失败', error: e, stackTrace: stackTrace);
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
    if (!isRefresh && (time.startTime == null || time.endTime == null)) {
      return;
    }

    final startTime = DateTime.parse(time.startTime!);
    final endTime = DateTime.parse(time.endTime!);

    if (!isRefresh &&
        (DateTime.now().isBefore(startTime) ||
            DateTime.now().isAfter(endTime))) {
      return;
    }

    final prefs = PrefsService.instance;
    final courseRepo = CourseRepository();
    // 检查缓存逻辑暂时略过，因为 repository 内部没有暴露时间检查，
    // 这里如果 isRefresh 为 false，我们可以先尝试从 repo 获取，如果为空再请求
    // 但原逻辑是根据 PrefsKeys.COURSE_DATA 是否存在且周次>2 来判断
    // 我们保留这个逻辑，但改为检查 Hive 中是否有数据

    // 注意：这里为了兼容，我们还是检查 prefs 中的时间戳
    final lastFetchTime = prefs.getInt(PrefsKeys.COURSE_LAST_FETCH_TIME);
    final hasData = (await courseRepo.getCourses()).isNotEmpty;

    if (hasData && lastFetchTime != null && week.week > 2 && !isRefresh) {
      return;
    }

    UserData? cookieData = userData ?? await getUserData();
    if (cookieData == null) {
      return;
    }

    try {
      final response = await EduApiClient.getCourse(cookieData.studentId);
      final courses = (jsonDecode(response) as List)
          .map((e) => CourseModel.fromJson(e))
          .toList()
          .cast<CourseModel>();

      // 即使是空数组也需要更新，因为可能原本有课现在退课了，或者学期切换了
      // 存储到 Hive
      await courseRepo.saveCourses(courses);

      await DataService.setIgnore([]);
      // 更新课程数据刷新时间
      await prefs.setInt(PrefsKeys.COURSE_LAST_FETCH_TIME,
          DateTime.now().millisecondsSinceEpoch);
    } catch (e, stackTrace) {
      AppLogger.error('获取课程信息失败', error: e, stackTrace: stackTrace);
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
      final List<ScoreList> scores = [];

      for (var item in list) {
        final response =
            await EduApiClient.getScore(cookieData.studentId, item.semester);
        final scoreList = (jsonDecode(response) as List)
            .map((e) => ScoreModel.fromJson(e))
            .toList();

        scores.add(ScoreList(semester: item, list: scoreList));
      }

      final scoreRepo = ScoreRepository();
      await scoreRepo.saveScores(scores);
    } catch (e, stackTrace) {
      AppLogger.error('获取所有学期成绩失败', error: e, stackTrace: stackTrace);
    }
  }

  /// 从本地获取所有学期成绩
  /// 优先从本地缓存获取成绩信息，如果缓存过期或需要刷新，则从服务器获取
  ///
  /// @param isRefresh 是否强制刷新，忽略缓存
  /// @return Future<List<ScoreList>> 返回所有学期的成绩列表
  static Future<List<ScoreList>> getAllScoreFromLocal(
      {bool isRefresh = false}) async {
    final prefs = PrefsService.instance;
    final scoreRepo = ScoreRepository();

    var now = DateTime.now().millisecondsSinceEpoch;
    final semesters = await DataService.getSemester();

    // 从 Repository 获取缓存
    final cachedScoresList = await scoreRepo.getScores();
    final Map<String, ScoreList> cachedScores = {
      for (var s in cachedScoresList) s.semester.semester: s
    };

    UserData? cookieData = await getUserData();
    if (cookieData == null) {
      // 没有用户数据时，返回缓存数据
      return cachedScoresList;
    }

    // 缓存检查和增量更新
    final List<ScoreList> updatedScores = [];

    // 获取每个学期的缓存时间戳
    final String? scoreTimestampsString =
        prefs.getString('${PrefsKeys.ALL_SCORE_DATA}_TIMESTAMPS');
    final Map<String, int> scoreTimestamps = scoreTimestampsString != null
        ? Map<String, int>.from(jsonDecode(scoreTimestampsString))
        : {};

    // 确定需要更新的学期
    final List<dynamic> semestersToUpdate = [];

    // 按学期排序，最新学期在前
    final sortedSemesters = List.from(semesters);
    sortedSemesters.sort((a, b) => b.semester.compareTo(a.semester));

    for (var semester in sortedSemesters) {
      final lastUpdate = scoreTimestamps[semester.semester];

      // 为不同学期设置不同的缓存过期时间
      // 最新学期：1小时过期
      // 其他学期：7天过期
      final isLatestSemester = semester == sortedSemesters.first;
      final expiryTime =
          isLatestSemester ? 1000 * 60 * 60 : 1000 * 60 * 60 * 24 * 7;
      final isExpired = lastUpdate == null || now - lastUpdate > expiryTime;

      if (isRefresh ||
          isExpired ||
          !cachedScores.containsKey(semester.semester)) {
        semestersToUpdate.add(semester);
      }
    }

    // 只更新需要刷新的学期
    if (semestersToUpdate.isNotEmpty) {
      try {
        for (var semester in semestersToUpdate) {
          final response = await EduApiClient.getScore(
              cookieData.studentId, semester.semester);

          final list = (jsonDecode(response) as List)
              .map((e) => ScoreModel.fromJson(e))
              .toList();
          final scoreList = ScoreList(semester: semester, list: list);

          updatedScores.add(scoreList);
          // 更新时间戳
          scoreTimestamps[semester.semester] = now;
        }

        // 合并更新的数据到缓存
        final Map<String, ScoreList> mergedScoresMap = Map.from(cachedScores);
        for (var s in updatedScores) {
          mergedScoresMap[s.semester.semester] = s;
        }

        final mergedScoresList = mergedScoresMap.values.toList();

        // 排序
        mergedScoresList
            .sort((a, b) => b.semester.semester.compareTo(a.semester.semester));

        // 保存更新后的数据和时间戳
        await scoreRepo.saveScores(mergedScoresList);

        await prefs.setString('${PrefsKeys.ALL_SCORE_DATA}_TIMESTAMPS',
            jsonEncode(scoreTimestamps));
        await prefs.setInt(PrefsKeys.LAST_SCORE_TIME, now);

        return mergedScoresList;
      } catch (e, stackTrace) {
        AppLogger.error('获取成绩数据失败', error: e, stackTrace: stackTrace);
      }
    }

    // 返回缓存数据 (需确保排序)
    cachedScoresList
        .sort((a, b) => b.semester.semester.compareTo(a.semester.semester));
    return cachedScoresList;
  }

  /// 从缓存数据构建成绩列表
  ///
  /// @param cachedScores 缓存的成绩数据
  /// @param semesters 学期列表
  /// @return List<ScoreList> 成绩列表
  static List<ScoreList> _buildScoreListFromCache(
      Map<String, dynamic> cachedScores, List<dynamic> semesters) {
    final List<ScoreList> list = [];
    cachedScores.forEach((String key, value) {
      // 查找匹配的学期
      final semesterMatch = semesters.firstWhere(
        (x) => x.semester == key,
        orElse: () => null,
      );

      // 如果找到了匹配的学期，使用它；否则创建一个临时的学期对象
      final semester = semesterMatch ??
          {
            'semester': key,
            'name': key,
          };

      final scoreList = jsonDecode(value);
      list.add(ScoreList(
        semester: semester,
        list: (scoreList as List).map((e) => ScoreModel.fromJson(e)).toList(),
      ));
    });

    // 按学期顺序排序，最新学期在前
    list.sort((a, b) => b.semester.semester.compareTo(a.semester.semester));
    return list;
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
      final prefs = PrefsService.instance;
      await prefs.setString(
          PrefsKeys.EXAM_DATA, jsonEncode(jsonDecode(response)));
    } catch (e, stackTrace) {
      AppLogger.error('获取考试信息失败', error: e, stackTrace: stackTrace);
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
      final prefs = PrefsService.instance;
      await prefs.setString(
          PrefsKeys.TIME_DATA, jsonEncode(jsonDecode(response)));
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(PrefsKeys.TIME_LAST_UPDATED, now);
    } catch (e, stackTrace) {
      AppLogger.error('获取时间信息失败', error: e, stackTrace: stackTrace);
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
      final prefs = PrefsService.instance;
      await prefs.setString(
          PrefsKeys.INFO_DATA, jsonEncode(jsonDecode(response)));
    } catch (e, stackTrace) {
      AppLogger.error('获取学生信息完成度失败', error: e, stackTrace: stackTrace);
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
          (dayDate == null ||
              dayDate.isEmpty ||
              dayDate == DateFormat('yyyy-MM-dd').format(now))) {
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
    } catch (e, stackTrace) {
      AppLogger.error('获取校巴信息失败', error: e, stackTrace: stackTrace);
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
        AppLogger.debug('找到了培养方案：${result.length}');
      }
      return result.map<PlanCourse>((e) => PlanCourse.fromJson(e)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('获取培养方案失败', error: e, stackTrace: stackTrace);
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
        AppLogger.debug('找到了培养方案：${result.length}');
      }
      return result.entries
          .map<PlanCourseList>(
              (entry) => PlanCourseList.fromMap(entry.key, entry.value))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error('获取培养方案字典失败', error: e, stackTrace: stackTrace);
    }

    return [];
  }
}
