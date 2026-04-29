import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ios_club_app/core/services/permission_service.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:intl/intl.dart';

import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/core/models/todo_item.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/education/services/course_service.dart';
import 'package:ios_club_app/features/system/notifications/course_reminder_helper.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();

  static NotificationService get instance => _instance;
  bool isInit = false;

  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    // 将时区注册为本地时区（后续调用 tz.local 就是本地时区）
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));

    final androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final WindowsInitializationSettings initializationSettingsWindows =
        WindowsInitializationSettings(
      appName: 'iOS Club App',
      appUserModelId: 'DA45F98E-38F0-F574-4192-36EB8C8DA0CA',
      guid: 'DA45F98E-38F0-F574-4192-36EB8C8DA0CA',
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      windows: initializationSettingsWindows,
      macOS: initializationSettingsDarwin,
    );

    await notifications.initialize(
      settings: initSettings,
    );

    await notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'ios_club_app_course_reminders',
          '课程通知',
          description: '进行每日课表的课程通知',
          importance: Importance.max,
        ));

    await notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'ios_club_app_todo_reminders',
          '待办事务提醒',
          description: '待办事务截止提醒',
          importance: Importance.max,
        ));

    isInit = true;
  }

  Future<void> scheduleCourseReminder(
      {required int id,
      required String title,
      required String body,
      required DateTime courseTime}) async {
    final prefs = PrefsService.instance;
    final notificationTime = prefs.getInt(PrefsKeys.NOTIFICATION_TIME) ?? 15;
    final now = DateTime.now();
    final reminderTime =
        courseTime.subtract(Duration(minutes: notificationTime));

    if (reminderTime.isBefore(now)) {
      AppLogger.debug('Cannot schedule notification for past reminder time');
      return;
    }

    final tzDateTime = tz.TZDateTime.from(reminderTime, tz.local);

    final android = notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final canScheduleExact = await android.canScheduleExactNotifications();
      if (canScheduleExact == null || !canScheduleExact) {
        AppLogger.debug('Exact alarm scheduling not allowed');
        return;
      }
    }

    AppLogger.debug('Scheduling notification at $tzDateTime with id=$id');

    try {
      await notifications.zonedSchedule(
        id: id,
        title: title,
        body: '$body 将在$notificationTime分钟后开始',
        scheduledDate: tzDateTime,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'ios_club_app_course_reminders',
            '课程通知',
            channelDescription: '进行每日课表的课程通知，提前$notificationTime分钟进行通知',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            threadIdentifier: 'ios_club_app_course_reminders',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      AppLogger.debug('Error scheduling notification: $e');
    }
  }

  /// 安排待办事项提醒
  Future<void> scheduleTodoNotification(
      TodoItem todo, bool todoRemindEnabled) async {
    // 如果提醒功能未启用，直接返回
    if (!todoRemindEnabled) return;

    // 如果待办事项已完成，取消提醒
    if (todo.isCompleted) {
      await notifications.cancel(id: todo.id.hashCode);
      return;
    }

    // 确保时区已初始化
    if (!isInit) {
      await initialize();
    }

    // 解析截止日期
    DateTime? deadline;
    try {
      deadline = DateFormat('yyyy-MM-dd HH:mm').parse(todo.deadline);
    } catch (e) {
      try {
        deadline = DateFormat('yyyy-MM-dd').parse(todo.deadline);
      } catch (e) {
        try {
          deadline = DateTime.parse(todo.deadline);
        } catch (e) {
          // 如果解析失败，不设置提醒
          return;
        }
      }
    }

    // 如果没有截止日期或已经过期，不设置提醒
    if (deadline.isBefore(DateTime.now())) {
      return;
    }

    // 设置提醒
    final notificationTime =
        deadline; // deadline.subtract(const Duration(hours: 1));

    // 如果计算出的提醒时间已经过去，不设置提醒
    if (notificationTime.isBefore(DateTime.now())) {
      return;
    }

    final tzNotificationTime = tz.TZDateTime.from(notificationTime, tz.local);

    try {
      await notifications.zonedSchedule(
        id: todo.id.hashCode, // 使用唯一ID作为通知ID
        title: '待办事务提醒',
        body: '您的待办事务 ${todo.title} 已到期',
        scheduledDate: tzNotificationTime,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'ios_club_app_todo_reminders',
            '待办事务提醒',
            channelDescription: '待办事务截止提醒',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            threadIdentifier: 'ios_club_app_todo_reminders',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      AppLogger.debug('Error scheduling todo notification: $e');
    }
  }

  /// 更新待办事项提醒
  Future<void> updateTodoNotification(
      TodoItem todo, bool todoRemindEnabled) async {
    // 确保时区已初始化
    if (!isInit) {
      await initialize();
    }

    // 先取消之前的通知
    await notifications.cancel(id: todo.id.hashCode);
    // 再根据新状态决定是否重新安排通知
    await scheduleTodoNotification(todo, todoRemindEnabled);
  }

  static Future<void> set(BuildContext context) async {
    // 请求精确闹钟权限
    await PermissionService.request(
      Permission.scheduleExactAlarm,
      onGranted: () async {
        // 在 Android 上进一步请求忽略电池优化权限，以确保后台任务存活
        if (PlatformUtils.isAndroid) {
          await PermissionService.request(
            Permission.ignoreBatteryOptimizations,
            context: context,
            dialogTitle: '允许后台运行',
            dialogContent: '为了确保课程提醒能准时响铃，请允许应用在后台运行（忽略电池优化）。',
            settingsText: '去设置',
          );
        }
        await remind();
      },
      context: context,
      dialogTitle: '请允许使用闹钟',
      dialogContent: '您需要允许使用闹钟才能使用通知功能',
      settingsText: '去设置',
    );
  }

  static Future<void> remind() async {
    if (!NotificationService.instance.isInit) {
      await NotificationService.instance.initialize();
    }

    final a = await CourseService.getTodayOrTomorrowCourse(isTomorrow: true);
    final targetDate =
        a.$1 ? DateTime.now().add(const Duration(days: 1)) : DateTime.now();

    for (var course in a.$2) {
      final target = CourseReminderHelper.buildTarget(
        course: course,
        courseDate: targetDate,
      );
      if (target == null) continue;

      await NotificationService.instance.scheduleCourseReminder(
        id: target.notificationId,
        title: '课程提醒',
        body: course.courseName,
        courseTime: target.courseTime,
      );
    }
  }

  static Future<void> remindList(
    List<CourseModel> a, {
    DateTime? targetDate,
  }) async {
    if (!NotificationService.instance.isInit) {
      await NotificationService.instance.initialize();
    }

    final effectiveDate = targetDate ?? DateTime.now();

    // 获取所有待处理的通知，用于去重
    final pendingRequests = await NotificationService.instance.notifications
        .pendingNotificationRequests();
    final existingIds = pendingRequests.map((r) => r.id).toSet();

    for (var course in a) {
      final target = CourseReminderHelper.buildTarget(
        course: course,
        courseDate: effectiveDate,
      );
      if (target == null) continue;

      // 如果通知已存在，跳过，避免重复调度引发通知闪烁或系统限制
      if (existingIds.contains(target.notificationId)) {
        continue;
      }

      await NotificationService.instance.scheduleCourseReminder(
        id: target.notificationId,
        title: '课程提醒',
        body: course.courseName,
        courseTime: target.courseTime,
      );
    }
  }
}
