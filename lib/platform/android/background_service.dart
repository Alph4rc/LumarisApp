import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/services/workmanager_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/features/system/notifications/task_executor.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

/// Android 后台服务管理类
/// 使用 [WorkmanagerService] 来注册周期性后台任务
class BackgroundService {
  /// 初始化后台服务
  static Future<void> initializeService() async {
    await WorkmanagerService.initialize();
    AppLogger.debug('Android 后台服务初始化完成');
  }

  /// 启动服务
  static Future<void> startService() async {
    await startReminderService();
    await startWidgetRefreshService();

    // 立即执行一次，确保 App 启动后小组件数据是最新的
    Future.delayed(const Duration(seconds: 1), () {
      TaskExecutor.checkAndSendCourseReminder();
      TaskExecutor.updateWidget();
    });
  }

  /// 启动课程提醒服务
  static Future<void> startReminderService() async {
    await WorkmanagerService.startReminderCheck();
  }

  /// 启动小组件自动刷新服务
  static Future<void> startWidgetRefreshService() async {
    await WorkmanagerService.startWidgetRefresh();
  }

  /// 停止服务
  static Future<void> stopService() async {
    await WorkmanagerService.stopAll();
    AppLogger.debug('所有后台任务已取消');
  }

  /// 停止课程提醒服务
  static Future<void> stopReminderService() async {
    await WorkmanagerService.stopReminderCheck();
  }

  /// 停止小组件自动刷新服务
  static Future<void> stopWidgetRefreshService() async {
    await WorkmanagerService.stopWidgetRefresh();
  }

  /// 手动触发课程提醒检查（同步执行，无需延迟）
  static Future<void> checkCourseReminder() async {
    await TaskExecutor.checkAndSendCourseReminder();
  }

  /// 手动触发小组件更新（同步执行，无需延迟）
  static Future<void> updateWidget() async {
    await TaskExecutor.updateWidget();
  }
}

/// 课程提醒服务的外部接口（保留引用兼容）
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
      await BackgroundService.startReminderService();
      // 立即安排一次课程通知（不依赖后台定时器）
      await TaskExecutor.checkAndSendCourseReminder();
    } else {
      await BackgroundService.stopReminderService();
    }
  }

  /// 获取是否启用提醒
  static Future<bool> isReminderEnabled() async {
    final prefs = await PrefsService.getInstanceAsync();
    return prefs.getBool(PrefsKeys.IS_REMIND) ?? false;
  }
}
