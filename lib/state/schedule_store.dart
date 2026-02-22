import 'dart:async';

import 'package:get/get.dart';
import 'package:ios_club_app/core/models/course_model.dart';
import 'package:ios_club_app/core/models/week_info.dart';
import 'package:ios_club_app/core/services/data_service.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/state/settings_store.dart';

import 'package:ios_club_app/features/education/services/edu_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

class ScheduleStore extends GetxController {
  static ScheduleStore get to => Get.find();
  List<CourseModel> _allCoursesRemind = [];

  // 课程数据
  final _allCourses = <List<CourseModel>>[].obs;
  final _isLoading = true.obs;
  final _maxWeek = 0.obs;
  final _currentWeek = 0.obs;
  final _currentPage = 0.obs;
  final _height = 55.0.obs;
  final _isYanTa = false.obs;
  final _showTomorrow = false.obs;

  List<List<CourseModel>> get allCourses => _allCourses.toList();

  bool get isLoading => _isLoading.value;

  int get maxWeek => _maxWeek.value;

  int get currentWeek => _currentWeek.value;

  int get currentPage => _currentPage.value;

  double get height => _height.value;

  bool get isYanTa => _isYanTa.value;

  // 直接使用SettingsStore的showTomorrow变量
  bool get showTomorrow => _showTomorrow.value;

  bool get isShowTomorrow => SettingsStore.to.isShowTomorrow;

  int weekNow = 0;

  @override
  void onInit() {
    super.onInit();
    initializeData();

    // 监听CourseStore的忽略课程变化
    ever(CourseStore.to.ignoreCoursesList, (_) {
      refreshCourseData();
    });
  }

  /// 初始化数据
  Future<void> initializeData() async {
    try {
      final weekData = await DataService.getWeek();
      _handleWeekData(weekData);
      await getRemindCourses();
      await _loadCourses();
      await _loadPreferences();
    } catch (e) {
      // 错误处理
      AppLogger.debug('初始化课表数据出错: $e');
    }
  }

  /// 处理周数据
  void _handleWeekData(WeekInfo weekData) {
    _currentWeek.value = weekData.week;
    weekNow = weekData.week;
    _maxWeek.value = weekData.maxWeek;
    _currentPage.value = _currentWeek.value <= 0 ? 0 : _currentWeek.value;
  }

  Future<void> getRemindCourses() async {
    _allCoursesRemind = await DataService.getAllCourse(isNeedIgnore: false);
  }

  Future<void> refreshCourseData() async {
    List<CourseModel> courses = [];
    for (var item in _allCoursesRemind) {
      if (CourseStore.to.ignoreCoursesList.isNotEmpty &&
          CourseStore.to.ignoreCoursesList.any((x) => x == item.courseName)) {
        continue;
      }
      courses.add(item);
    }
    _allCourses.value = List.generate(_maxWeek.value + 1, (i) {
      return i == 0
          ? courses
          : courses.where((course) => course.weekIndexes.contains(i)).toList();
    });
    if (courses.isNotEmpty) {
      final firstCourse = courses[0];
      _isYanTa.value = !(firstCourse.campus == "草堂校区" ||
          (firstCourse.room.length >= 2 && firstCourse.room.startsWith("草堂")));
    }
    _isLoading.value = false;
  }

  /// 加载课程数据
  Future<void> _loadCourses() async {
    final courses = await DataService.getAllCourse();
    _allCourses.value = List.generate(_maxWeek.value + 1, (i) {
      return i == 0
          ? courses
          : courses.where((course) => course.weekIndexes.contains(i)).toList();
    });
    if (courses.isNotEmpty) {
      final firstCourse = courses[0];
      _isYanTa.value = !(firstCourse.campus == "草堂校区" ||
          (firstCourse.room.length >= 2 && firstCourse.room.startsWith("草堂")));
    }
    _isLoading.value = false;
  }

  /// 加载用户偏好设置
  Future<void> _loadPreferences() async {
    final prefs = PrefsService.instance;
    final courseSize = prefs.getDouble('course_size');

    if (courseSize != null && courseSize != 0) {
      _height.value = courseSize;
    }
  }

  /// 刷新课程数据
  Future<void> refreshCourses() async {
    AppLogger.debug('[ScheduleStore] 开始刷新课程');
    _isLoading.value = true;
    try {
      AppLogger.debug('[ScheduleStore] 调用 EduService.getCourse');

      // 获取最新时间数据
      // 传入 isRefresh: true 以强制从服务器获取最新时间
      final weekData = await DataService.getWeek(isRefresh: true);
      _handleWeekData(weekData);

      // 添加超时保护：最多等待20秒
      // 考虑到可能需要重登录（3-5秒）+ 请求时间（5-10秒）
      await EduService.getCourse(isRefresh: true)
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              AppLogger.warning('[ScheduleStore] 刷新课程超时');
              throw TimeoutException('刷新课程超时');
            },
          );

      AppLogger.debug('[ScheduleStore] EduService.getCourse 完成');

      await getRemindCourses();
      AppLogger.debug('[ScheduleStore] getRemindCourses 完成');

      await CourseStore.to.loadCourses(); // 更新自定义课程数据
      AppLogger.debug('[ScheduleStore] CourseStore.loadCourses 完成');

      await _loadCourses();
      AppLogger.debug('[ScheduleStore] _loadCourses 完成');

      AppLogger.debug('[ScheduleStore] 刷新课程成功');
    } on TimeoutException catch (e) {
      AppLogger.warning('[ScheduleStore] 刷新课程超时: $e');
      // 超时错误会被UI层捕获并显示给用户
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('[ScheduleStore] 刷新课程失败', error: e, stackTrace: stackTrace);
      rethrow;
    } finally {
      AppLogger.debug('[ScheduleStore] 设置 _isLoading = false');
      _isLoading.value = false;
    }
  }

  /// 跳转到指定页面
  void jumpToPage(int page) {
    if (page < 0) {
      page = _maxWeek.value;
    } else if (page > _maxWeek.value) {
      page = 0;
    }
    _currentPage.value = page;
  }

  /// 设置课程高度
  Future<void> setCourseHeight(double value) async {
    _height.value = value;
    final prefs = PrefsService.instance;
    await prefs.setDouble('course_size', value);
  }

  /// 设置当前页面
  void setCurrentPage(int page) {
    _currentPage.value = page;
  }

  /// 切换显示明天课程
  Future<void> toggleShowTomorrow() async {
    // 直接调用SettingsStore的方法来切换showTomorrow
    SettingsStore.to.setIsShowTomorrow(!SettingsStore.to.isShowTomorrow);
  }

  /// 获取今天或明天的课程
  List<CourseModel> getTodayCourses() {
    final now = DateTime.now();
    final weekDay = now.weekday;
    var a = false;

    // 使用 currentWeek 替代 weekNow，确保响应式更新
    final weekIndex = currentWeek;

    // 处理今天的课程，使用DataService.getCourse中相同的逻辑
    if (weekIndex < 0 || weekIndex >= allCourses.length) {
      return [];
    }

    var filteredCourses = allCourses[weekIndex]
        .where((course) =>
            course.weekIndexes.contains(weekIndex) && course.weekday == weekDay)
        .toList();

    // 过滤掉已经结束的课程
    filteredCourses = filteredCourses.where((course) {
      final time = TimeService.getStartAndEnd(course);

      final l = time.end.split(':');
      var end = DateTime(
          now.year, now.month, now.day, int.parse(l[0]), int.parse(l[1]), 0);

      return now.isBefore(end);
    }).toList();

    filteredCourses.sort((a, b) => a.startUnit.compareTo(b.startUnit));

    // 只有当今天没有课程且isShowTomorrow为true时，才显示明天的课程
    if (isShowTomorrow && filteredCourses.isEmpty) {
      final tomorrow = now.add(Duration(days: 1));
      var tomorrowWeekDay = tomorrow.weekday;
      if (tomorrowWeekDay > 7) {
        tomorrowWeekDay = 1;
      }

      // 如果明天是周日，则周数需要增加
      final targetWeek = tomorrowWeekDay == 7 ? weekIndex + 1 : weekIndex;

      // 检查targetWeek是否超出范围
      if (targetWeek >= allCourses.length) {
        return [];
      }

      final courses = allCourses[targetWeek];
      a = true;
      filteredCourses = courses
          .where((course) => course.weekday == tomorrowWeekDay)
          .toList()
        ..sort((a, b) => a.startUnit.compareTo(b.startUnit));
    }

    // 使用 Future.microtask 延迟更新 _showTomorrow 的值，避免在构建过程中触发重建
    Future.microtask(() => _showTomorrow.value = a);

    return filteredCourses;
  }

  void clean() {
    _allCourses.clear();
  }
}
