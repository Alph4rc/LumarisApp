import 'dart:async';
import 'dart:ui';

import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/features/education/models/time_info.dart';
import 'package:ios_club_app/core/models/schedule_item.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/features/education/services/course_service.dart';
import 'package:ios_club_app/features/education/services/edu_time_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/features/system/notifications/notification_service.dart';
import 'package:ios_club_app/features/system/widget_service.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:flutter/widgets.dart';
import 'package:ios_club_app/core/services/hive_manager.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

/// 任务执行器 - 实际的业务逻辑
@pragma('vm:entry-point')
class TaskExecutor {
  /// 标记是否正在执行任务，避免重复执行
  static bool _isExecuting = false;

  /// 缓存的课程数据
  static List<CourseModel>? _cachedCourses;
  static TimeInfo? _cachedTime;
  static DateTime? _cacheTimestamp;

  /// 缓存有效期（5分钟）
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  /// 检查缓存是否有效
  static bool _isCacheValid() {
    if (_cachedCourses == null ||
        _cachedTime == null ||
        _cacheTimestamp == null) {
      return false;
    }
    return DateTime.now().difference(_cacheTimestamp!) < _cacheValidDuration;
  }

  /// 清除缓存
  static void _clearCache() {
    _cachedCourses = null;
    _cachedTime = null;
    _cacheTimestamp = null;
  }

  /// 预加载数据到缓存
  static Future<void> _preloadData() async {
    if (_isCacheValid()) {
      return;
    }

    try {
      // 并行获取课程和时间数据
      final results = await Future.wait([
        CourseService.getAllCourse(),
        EduTimeService.getTime(),
      ]).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('预加载数据超时');
        },
      );

      _cachedCourses = results[0] as List<CourseModel>;
      _cachedTime = results[1] as TimeInfo;
      _cacheTimestamp = DateTime.now();
      AppLogger.debug('后台任务数据预加载完成');
    } catch (e) {
      AppLogger.debug('预加载数据失败: $e');
      _clearCache();
      rethrow;
    }
  }

  /// 从缓存获取今日或明日课程
  static (bool, List<CourseModel>) _getTodayOrTomorrowCourseFromCache(
      {bool isTomorrow = false}) {
    if (_cachedCourses == null || _cachedTime == null) {
      return (false, <CourseModel>[]);
    }

    final time = _cachedTime!;
    var now = DateTime.now();
    if (time.startTime == null) {
      return (false, <CourseModel>[]);
    }

    final startTime = DateTime.parse(time.startTime!);
    var weekNow = EduTimeService.getWeekIndexByStartTime(now, startTime);
    var filteredCourses = _cachedCourses!.where((course) {
      return course.weekIndexes.contains(weekNow) &&
          course.weekday == now.weekday;
    }).toList();

    if (filteredCourses.isEmpty) {
      if (isTomorrow) {
        final tomorrow = now.add(const Duration(days: 1));
        var weekTomorrow = EduTimeService.getWeekIndexByStartTime(tomorrow, startTime);
        var tomorrowWeekday = tomorrow.weekday;

        filteredCourses = _cachedCourses!.where((course) {
          return course.weekIndexes.contains(weekTomorrow) &&
              course.weekday == tomorrowWeekday;
        }).toList();
        filteredCourses.sort((a, b) => a.startUnit.compareTo(b.startUnit));
        return (true, filteredCourses);
      } else {
        return (false, filteredCourses);
      }
    }

    filteredCourses = filteredCourses.where((course) {
      final courseTime = TimeService.getStartAndEnd(course);
      final l = courseTime.end.split(':');
      var end = DateTime(
          now.year, now.month, now.day, int.parse(l[0]), int.parse(l[1]), 0);
      return now.isBefore(end);
    }).toList();

    filteredCourses.sort((a, b) => a.startUnit.compareTo(b.startUnit));
    return (false, filteredCourses);
  }

  /// 从缓存获取今日和明日课程
  static Map<String, List<CourseModel>> _getTodayAndTomorrowCoursesFromCache() {
    if (_cachedCourses == null || _cachedTime == null) {
      return {'today': <CourseModel>[], 'tomorrow': <CourseModel>[]};
    }

    final time = _cachedTime!;
    var now = DateTime.now();

    if (time.startTime == null) {
      return {'today': <CourseModel>[], 'tomorrow': <CourseModel>[]};
    }

    final startTime = DateTime.parse(time.startTime!);
    var weekNow = EduTimeService.getWeekIndexByStartTime(now, startTime);

    // 获取今天的课程
    var todayCourses = _cachedCourses!.where((course) {
      return course.weekIndexes.contains(weekNow) &&
          course.weekday == now.weekday;
    }).toList();

    // 过滤掉已经结束的课程
    todayCourses = todayCourses.where((course) {
      final courseTime = TimeService.getStartAndEnd(course);
      final l = courseTime.end.split(':');
      var end = DateTime(
          now.year, now.month, now.day, int.parse(l[0]), int.parse(l[1]), 0);
      return now.isBefore(end);
    }).toList();

    todayCourses.sort((a, b) => a.startUnit.compareTo(b.startUnit));

    // 计算明天日期和周数
    final tomorrow = now.add(const Duration(days: 1));
    var weekTomorrow = EduTimeService.getWeekIndexByStartTime(tomorrow, startTime);
    var tomorrowWeekday = tomorrow.weekday;

    // 获取明天的课程
    var tomorrowCourses = _cachedCourses!.where((course) {
      return course.weekIndexes.contains(weekTomorrow) &&
          course.weekday == tomorrowWeekday;
    }).toList();

    tomorrowCourses.sort((a, b) => a.startUnit.compareTo(b.startUnit));

    return {'today': todayCourses, 'tomorrow': tomorrowCourses};
  }

  /// 检查并发送课程提醒
  static Future<void> _ensureInitialized() async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    await HiveManager.init();
    await PrefsService.init();
  }

  static Future<void> checkAndSendCourseReminder() async {
    await _ensureInitialized();
    try {
      final prefs = await PrefsService.getInstanceAsync();

      // 检查是否启用提醒
      final isReminderEnabled = prefs.getBool(PrefsKeys.IS_REMIND) ?? false;
      if (!isReminderEnabled) {
        AppLogger.debug('课程提醒未启用');
        return;
      }

      // 检查今天是否已经提醒过
      final now = DateTime.now();
      final lastRemindTimeStr = prefs.getString(PrefsKeys.LAST_REMIND_DATE);

      if (lastRemindTimeStr != null) {
        try {
          final lastRemindDate = DateTime.parse(lastRemindTimeStr);
          if (_isSameDay(now, lastRemindDate)) {
            AppLogger.debug('今天已经提醒过了');
            return;
          }
        } catch (e) {
          AppLogger.debug('解析上次提醒时间失败: $e');
        }
      }

      // 预加载数据
      await _preloadData();

      // 从缓存获取课程数据
      final result = _getTodayOrTomorrowCourseFromCache(isTomorrow: true);

      if (result.$2.isNotEmpty) {
        await NotificationService.remindList(result.$2);

        // 记录提醒时间（使用ISO格式字符串）
        await prefs.setString(
            PrefsKeys.LAST_REMIND_DATE, now.toIso8601String());
        AppLogger.debug('课程提醒发送成功: ${now.toIso8601String()}');
      } else {
        AppLogger.debug('没有需要提醒的课程');
      }
    } catch (e) {
      AppLogger.debug('课程提醒检查失败: $e');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> updateWidget() async {
    await _ensureInitialized();
    // 防止重复执行
    if (_isExecuting) {
      AppLogger.debug('后台任务正在执行中，跳过本次调用');
      return;
    }

    _isExecuting = true;
    try {
      // 预加载数据（只请求一次）
      await _preloadData();

      // 并行更新两个小组件
      await Future.wait([
        _updateTodayWidgetFromCache(),
        _updateTodayAndTomorrowWidgetFromCache(),
      ]);
    } catch (e) {
      AppLogger.debug('更新小组件失败: $e');
    } finally {
      _isExecuting = false;
    }
  }

  /// 从缓存更新今日课程小组件
  static Future<void> _updateTodayWidgetFromCache() async {
    try {
      final (_, courses) =
          _getTodayOrTomorrowCourseFromCache(isTomorrow: false);

      if (courses.isNotEmpty) {
        final scheduleItems = _convertToScheduleItems(courses);
        await WidgetService.updateTodayCourses(scheduleItems);
        AppLogger.debug('今日课程小组件更新成功');
      } else {
        await WidgetService.updateTodayCourses([]);
        AppLogger.debug('今日无课，小组件已更新');
      }
    } catch (e) {
      AppLogger.debug('更新今日课程小组件失败: $e');
    }
  }

  /// 从缓存更新近日课程小组件
  static Future<void> _updateTodayAndTomorrowWidgetFromCache() async {
    try {
      final courses = _getTodayAndTomorrowCoursesFromCache();

      Map<String, List<ScheduleItem>> scheduleItems = {};
      scheduleItems['today'] = _convertToScheduleItems(courses['today']!);
      scheduleItems['tomorrow'] = _convertToScheduleItems(courses['tomorrow']!);
      await WidgetService.updateTodayAndTomorrowCourses(scheduleItems);
      AppLogger.debug('近日课程小组件更新成功');
    } catch (e) {
      AppLogger.debug('更新近日课程小组件失败: $e');
    }
  }

  /// 更新今日课程小组件（公开方法，用于外部调用）
  @pragma('vm:entry-point')
  static Future<void> updateTodayWidget() async {
    await _ensureInitialized();
    try {
      await _preloadData();
      await _updateTodayWidgetFromCache();
    } catch (e) {
      AppLogger.debug('更新小组件失败: $e');
    }
  }

  /// 更新近日课程小组件（公开方法，用于外部调用）
  @pragma('vm:entry-point')
  static Future<void> updateTodayAndTomorrowWidget() async {
    await _ensureInitialized();
    try {
      await _preloadData();
      await _updateTodayAndTomorrowWidgetFromCache();
    } catch (e) {
      AppLogger.debug('更新小组件失败: $e');
    }
  }

  /// 转换课程数据为小组件显示格式
  static List<ScheduleItem> _convertToScheduleItems(List<CourseModel> courses) {
    final List<ScheduleItem> items = [];

    for (final course in courses) {
      try {
        final time = TimeService.getStartAndEnd(course);

        items.add(ScheduleItem(
          title: course.courseName,
          time:
              '第${course.startUnit}-${course.endUnit}节 ${time.start}-${time.end}',
          location: course.room,
          teacher: course.teachers.join(','),
        ));
      } catch (e) {
        AppLogger.debug('转换课程 ${course.courseName} 失败: $e');
        // 即使单个课程转换失败，也继续处理其他课程
        continue;
      }
    }

    return items;
  }

  /// 判断是否同一天
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
