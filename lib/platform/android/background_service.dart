import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:ios_club_app/features/system/notifications/task_executor.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

/// 后台任务回调函数
@pragma('vm:entry-point')
void backgroundTask() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  // 执行课程提醒检查
  await TaskExecutor.checkAndSendCourseReminder();
}

/// 后台服务管理类
class BackgroundService {
  static const int _reminderAlarmId = 1;
  static const int _widgetAlarmId = 2;
  static const Duration _reminderInterval = Duration(hours: 1);

  /// 初始化后台服务
  static Future<void> initializeService() async {
    // 初始化 Android Alarm Manager
    await AndroidAlarmManager.initialize();

    AppLogger.debug('Android Alarm Manager 初始化完成');
  }

  /// 启动服务
  static Future<void> startService() async {
    await startReminderService();
    await startWidgetRefreshService();

    // 立即执行一次任务，确保首次进入或重新拉起后小组件数据是最新的
    Future.delayed(const Duration(seconds: 1), () {
      backgroundTask();
      TaskExecutor.updateWidget();
    });

    AppLogger.debug('后台任务已启动');
  }

  /// 启动课程提醒服务
  static Future<void> startReminderService() async {
    await AndroidAlarmManager.cancel(_reminderAlarmId);

    // 启动周期性任务
    await AndroidAlarmManager.periodic(
      _reminderInterval,
      _reminderAlarmId,
      backgroundTask,
      wakeup: true,
      exact: true,
      rescheduleOnReboot: true,
    );

    AppLogger.debug('课程提醒后台任务已注册，间隔: $_reminderInterval');
  }

  /// 启动小组件自动刷新服务
  static Future<void> startWidgetRefreshService() async {
    await AndroidAlarmManager.cancel(_widgetAlarmId);

    await AndroidAlarmManager.periodic(
      const Duration(minutes: 10),
      _widgetAlarmId,
      TaskExecutor.updateWidget,
      wakeup: false, // 小组件更新不需要唤醒设备
      exact: true,
      rescheduleOnReboot: true,
    );

    AppLogger.debug('小组件自动刷新任务已注册');
  }

  /// 停止服务
  static Future<void> stopService() async {
    await stopReminderService();
    await stopWidgetRefreshService();
    AppLogger.debug('所有后台任务已取消');
  }

  /// 停止课程提醒服务
  static Future<void> stopReminderService() async {
    await AndroidAlarmManager.cancel(_reminderAlarmId);
    AppLogger.debug('课程提醒后台任务已取消');
  }

  /// 停止小组件自动刷新服务
  static Future<void> stopWidgetRefreshService() async {
    await AndroidAlarmManager.cancel(_widgetAlarmId);
    AppLogger.debug('小组件自动刷新任务已取消');
  }

  /// 手动触发课程提醒检查
  static Future<void> checkCourseReminder() async {
    await AndroidAlarmManager.oneShot(
      const Duration(seconds: 1),
      _reminderAlarmId,
      TaskExecutor.checkAndSendCourseReminder,
    );
  }

  /// 手动触发小组件更新
  static Future<void> updateWidget() async {
    await AndroidAlarmManager.oneShot(
      const Duration(seconds: 1),
      _widgetAlarmId,
      TaskExecutor.updateWidget,
    );
  }
}

/// 课程提醒服务的外部接口
class CourseReminderService {
  /// 手动执行课程提醒
  static Future<void> performCourseReminder() async {
    await BackgroundService.checkCourseReminder();
  }

  /// 手动更新今日课程
  static Future<void> updateTodayCourse() async {
    await BackgroundService.updateWidget();
  }

  /// 获取服务状态
  static Future<bool> isServiceRunning() async {
    // AndroidAlarmManager 没有直接的 API 来检查任务是否运行
    // 这里简单返回 true 表示已配置
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
  static Future<void> setReminderEnabled(bool enabled) async {
    final prefs = await PrefsService.getInstanceAsync();
    await prefs.setBool(PrefsKeys.IS_REMIND, enabled);

    if (enabled) {
      // 启用时仅启动提醒任务，小组件刷新保持独立运行
      await BackgroundService.startReminderService();
    } else {
      // 禁用时仅停止提醒任务，不影响小组件自动刷新
      await BackgroundService.stopReminderService();
    }
  }

  /// 获取是否启用提醒
  static Future<bool> isReminderEnabled() async {
    final prefs = await PrefsService.getInstanceAsync();
    return prefs.getBool(PrefsKeys.IS_REMIND) ?? false;
  }
}
