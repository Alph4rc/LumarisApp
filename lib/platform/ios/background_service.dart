import 'dart:async';
import 'package:ios_club_app/core/services/workmanager_service.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/features/system/notifications/task_executor.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

/// iOS后台服务管理类
/// 使用 [WorkmanagerService]（底层使用 iOS BGTaskScheduler）处理后台任务
class IOSBackgroundService {
  /// 初始化后台服务
  static Future<void> initializeService() async {
    await WorkmanagerService.initialize();
    AppLogger.debug('iOS Background Service 初始化完成');
  }

  /// 启动服务
  static Future<void> startService() async {
    AppLogger.debug('iOS Background Service 已启动');

    // 注册周期性后台任务（iOS 通过 BGTaskScheduler 实现）
    await WorkmanagerService.startWidgetRefresh();
    await WorkmanagerService.startReminderCheck();

    // 立即执行一次更新
    await TaskExecutor.updateWidget();
  }

  /// 停止服务
  static Future<void> stopService() async {
    AppLogger.debug('iOS Background Service 已停止');
  }

  /// 手动触发课程提醒检查
  static Future<void> checkCourseReminder() async {
    await TaskExecutor.checkAndSendCourseReminder();
  }

  /// 手动触发小组件更新
  static Future<void> updateWidget() async {
    await TaskExecutor.updateWidget();
  }
}

/// 课程提醒服务的外部接口
class CourseReminderService {
  /// 手动执行课程提醒
  static Future<void> performCourseReminder() async {
    await IOSBackgroundService.checkCourseReminder();
  }

  /// 手动更新今日课程
  static Future<void> updateTodayCourse() async {
    await IOSBackgroundService.updateWidget();
  }

  /// 获取服务状态
  static Future<bool> isServiceRunning() async {
    return true;
  }

  /// 获取上次提醒时间
  static Future<DateTime?> getLastReminderTime() async {
    final prefs = await PrefsService.getInstanceAsync();
    final lastTimeStr = prefs.getString(PrefsKeys.LAST_REMIND_DATE);

    if (lastTimeStr != null) {
      try {
        return DateTime.parse(lastTimeStr);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// 设置是否启用提醒
  /// 课程通知通过 flutter_local_notifications.zonedSchedule()
  /// 预先安排的 OS 级别通知来触发，不依赖后台执行
  static Future<void> setReminderEnabled(bool enabled) async {
    final prefs = await PrefsService.getInstanceAsync();
    await prefs.setBool(PrefsKeys.IS_REMIND, enabled);

    if (enabled) {
      await TaskExecutor.checkAndSendCourseReminder();
      AppLogger.debug('iOS 课程提醒已启用，通知已通过 OS 级别调度');
    } else {
      AppLogger.debug('iOS 课程提醒已禁用');
    }
  }

  /// 获取是否启用提醒
  static Future<bool> isReminderEnabled() async {
    final prefs = await PrefsService.getInstanceAsync();
    return prefs.getBool(PrefsKeys.IS_REMIND) ?? false;
  }
}
