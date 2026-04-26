import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/features/system/notifications/task_executor.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

/// 统一的课程提醒服务
/// 不依赖后台执行，利用 flutter_local_notifications.zonedSchedule() 的 OS 级别通知调度
class CourseReminderService {
  /// 执行课程提醒检查并安排通知
  /// 在 App 前台时调用，会预先安排今日/明日课程的通知
  static Future<void> performCourseReminder() async {
    await TaskExecutor.checkAndSendCourseReminder();
  }

  /// 刷新小组件数据
  static Future<void> updateWidget() async {
    await TaskExecutor.updateWidget();
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
      // 启用时立即安排一次课程通知
      AppLogger.debug('课程提醒已启用，正在安排通知...');
      await TaskExecutor.checkAndSendCourseReminder();
      // 启动平台相关的后台服务（用于小组件更新）
      if (PlatformUtils.isAndroid) {
        // Android 使用 AlarmManager 定期更新小组件
        // 通过 BackgroundService.startReminderService() 已在原文件中处理
      } else if (PlatformUtils.isIOS) {
        // iOS 小组件更新依赖 App 前台触发，后台 Timer 不会运行
        AppLogger.debug('iOS 课程提醒已启用，通知将通过 OS 级别调度触发');
      }
    } else {
      AppLogger.debug('课程提醒已禁用');
    }
  }

  /// 获取是否启用提醒
  static Future<bool> isReminderEnabled() async {
    final prefs = await PrefsService.getInstanceAsync();
    return prefs.getBool(PrefsKeys.IS_REMIND) ?? false;
  }
}
