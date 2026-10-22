import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/services/app_locale_service.dart';
import 'package:ios_club_app/core/services/permission_service.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:ios_club_app/state/prefs_keys.dart';

import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/education/services/course_service.dart';
import 'package:ios_club_app/features/system/notifications/course_reminder_helper.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();

  /// 排期规则版本。旧版本按设备时区换算开始时间，闹钟可能被排到半夜；
  /// 升级后清空一次旧排期，由新规则重新排。
  static const int reminderSchemaVersion = 2;

  static const String _courseChannelId = 'ios_club_app_course_reminders';
  static const String _courseChannelNameZh = '课程通知';
  static const String _courseChannelDescriptionZh = '进行每日课表的课程通知';

  /// 系统在 Doze 下可能把闹钟延后十几分钟才送达，超过这个时间才算“过期脏数据”。
  static const Duration _staleGrace = Duration(minutes: 15);

  static NotificationService get instance => _instance;
  bool isInit = false;

  Future<void>? _initialization;

  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._();

  AppLocalizations get _l10n => AppLocaleService.currentL10n();

  static bool _isGranted(PermissionStatus status) {
    return status == PermissionStatus.granted ||
        status == PermissionStatus.limited ||
        status == PermissionStatus.provisional;
  }

  /// 确保通知服务只初始化一次（前台和后台 isolate 都可能调用）。
  Future<void> ensureInitialized() async {
    if (isInit) {
      return;
    }

    final pending = _initialization;
    if (pending != null) {
      await pending;
      return;
    }

    final future = initialize();
    _initialization = future;
    try {
      await future;
    } finally {
      _initialization = null;
    }
  }

  Future<void> initialize() async {
    if (isInit) {
      return;
    }

    tzdata.initializeTimeZones();

    // 课程时间是校区墙上时间，统一按校区时区换算。
    tz.setLocalLocation(tz.getLocation(kCampusTimeZoneName));

    final androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
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
          appName: _l10n.appName,
          appUserModelId: 'DA45F98E-38F0-F574-4192-36EB8C8DA0CA',
          guid: 'DA45F98E-38F0-F574-4192-36EB8C8DA0CA',
        );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      windows: initializationSettingsWindows,
      macOS: initializationSettingsDarwin,
    );

    await notifications.initialize(settings: initSettings);

    await notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          AndroidNotificationChannel(
            _courseChannelId,
            _courseChannelNameZh,
            description: _courseChannelDescriptionZh,
            importance: Importance.max,
          ),
        );

    await _migrateLegacySchedule();

    isInit = true;
  }

  /// 清理旧版本留下的排期。
  ///
  /// 旧版本按设备时区把“8:00”换算成绝对时刻，设备时区/时钟不准时闹钟会偏
  /// 8 小时（7:45 的通知变成前一天 23:45）；这些闹钟在重启、应用更新后还会被
  /// 插件重新注册。升级后一次性撤销，交给新规则重排。
  Future<void> _migrateLegacySchedule() async {
    try {
      final prefs = await PrefsService.getInstanceAsync();
      final version = prefs.getInt(PrefsKeys.COURSE_REMINDER_SCHEMA) ?? 0;
      if (version >= reminderSchemaVersion) {
        return;
      }

      await notifications.cancelAll();
      await prefs.remove(PrefsKeys.COURSE_REMINDER_PLAN);
      // 排期已经作废，同步清掉“今天已排过”的标记，让下一轮检查立刻重排
      await prefs.remove(PrefsKeys.LAST_REMIND_DATE);
      await prefs.setInt(
        PrefsKeys.COURSE_REMINDER_SCHEMA,
        reminderSchemaVersion,
      );
      AppLogger.debug('已清理旧版本的课程通知排期，稍后按新规则重排');
    } catch (e, stackTrace) {
      AppLogger.error('清理旧版本课程通知排期失败', error: e, stackTrace: stackTrace);
    }
  }

  /// 取消所有已排期的通知
  Future<void> cancelAllNotifications() async {
    await notifications.cancelAll();
    await _writePlan(<int, int>{});
    AppLogger.debug('所有通知已取消');
  }

  /// 排一条课程提醒。
  ///
  /// [reminderTime] 必须已经是校区时区下的绝对时刻，并由
  /// [CourseReminderHelper.resolveReminderTime] 校验过仍在未来：
  /// Android 收到已经过期的闹钟会立刻弹出，这是课程提醒在半夜突然
  /// 冒出来的直接原因（插件自身也会对过去的时间抛 ArgumentError）。
  Future<bool> scheduleCourseReminder({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime reminderTime,
    required int advanceMinutes,
  }) async {
    final android = notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android != null) {
      final canScheduleExact = await android.canScheduleExactNotifications();
      if (canScheduleExact != null && !canScheduleExact) {
        AppLogger.debug('Exact alarm scheduling not allowed');
        return false;
      }
    }

    final l10n = _l10n;

    try {
      // 增加安全检查：如果待处理通知接近 500 个，停止安排
      final pendingCount =
          (await notifications.pendingNotificationRequests()).length;
      if (pendingCount >= 450) {
        AppLogger.debug(
          'Warning: Approaching 500 alarm limit ($pendingCount). Skipping schedule.',
        );
        return false;
      }

      await notifications.zonedSchedule(
        id: id,
        title: title,
        body: '$body ${l10n.courseReminderStartsIn(advanceMinutes)}',
        scheduledDate: reminderTime,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _courseChannelId,
            _courseChannelNameZh,
            channelDescription: _courseChannelDescriptionZh,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            threadIdentifier: _courseChannelId,
          ),
          macOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            threadIdentifier: _courseChannelId,
          ),
          windows: WindowsNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      AppLogger.debug('Scheduling notification at $reminderTime with id=$id');
      return true;
    } on ArgumentError catch (e) {
      // 刚好排到过去：宁可少一条通知，也不要在任意时刻弹出来
      AppLogger.debug('跳过已过期的课程提醒 id=$id: $e');
      return false;
    } catch (e) {
      AppLogger.debug('Error scheduling notification: $e');
      return false;
    }
  }

  /// 读取本地排期记录：通知 id -> 计划触发的绝对时刻（epoch ms）。
  ///
  /// 插件只暴露待处理通知的 id，不暴露排期时刻，所以自己记一份，
  /// 用来判断系统里那条闹钟是不是已经被排歪了。
  Future<Map<int, int>> _readPlan() async {
    try {
      final prefs = await PrefsService.getInstanceAsync();
      final raw = prefs.getString(PrefsKeys.COURSE_REMINDER_PLAN);
      if (raw == null || raw.isEmpty) {
        return <int, int>{};
      }

      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return <int, int>{};
      }

      final plan = <int, int>{};
      decoded.forEach((key, value) {
        final id = int.tryParse('$key');
        if (id != null && value is int) {
          plan[id] = value;
        }
      });
      return plan;
    } catch (e) {
      AppLogger.debug('读取课程通知排期失败: $e');
      return <int, int>{};
    }
  }

  Future<void> _writePlan(Map<int, int> plan) async {
    try {
      final prefs = await PrefsService.getInstanceAsync();
      if (plan.isEmpty) {
        await prefs.remove(PrefsKeys.COURSE_REMINDER_PLAN);
        return;
      }

      await prefs.setString(
        PrefsKeys.COURSE_REMINDER_PLAN,
        jsonEncode(<String, int>{
          for (final entry in plan.entries) '${entry.key}': entry.value,
        }),
      );
    } catch (e) {
      AppLogger.debug('保存课程通知排期失败: $e');
    }
  }

  static Future<bool> ensureReminderPermission(BuildContext context) async {
    final l10n = context.l10n;

    // Android 13+ 通知需要运行时授权；否则即使闹钟排好了也不会显示。
    final notificationStatus = await PermissionService.request(
      Permission.notification,
      context: context,
      dialogTitle: l10n.permissionNotificationTitle,
      dialogContent: l10n.permissionNotificationDesc,
      settingsText: l10n.goToSettings,
    );

    if (!_isGranted(notificationStatus)) {
      return false;
    }

    // 精确闹钟与忽略电池优化只存在于 Android；iOS 由系统统一调度本地通知。
    if (PlatformUtils.isAndroid) {
      if (!context.mounted) {
        return false;
      }

      final status = await PermissionService.request(
        Permission.scheduleExactAlarm,
        context: context,
        dialogTitle: l10n.allowScheduleAlarm,
        dialogContent: l10n.allowScheduleAlarmContent,
        settingsText: l10n.goToSettings,
      );

      if (!_isGranted(status)) {
        return false;
      }

      if (!context.mounted) {
        return false;
      }

      await PermissionService.request(
        Permission.ignoreBatteryOptimizations,
        context: context,
        dialogTitle: l10n.allowBackgroundRun,
        dialogContent: l10n.allowBackgroundRunContent,
        settingsText: l10n.goToSettings,
      );
    }

    await remind();
    return true;
  }

  static Future<void> set(BuildContext context) async {
    await ensureReminderPermission(context);
  }

  static Future<void> remind() async {
    await NotificationService.instance.ensureInitialized();

    final a = await CourseService.getTodayOrTomorrowCourse(isTomorrow: true);
    final targetDate = a.$1
        ? DateTime.now().add(const Duration(days: 1))
        : DateTime.now();

    await remindList(a.$2, targetDate: targetDate);
  }

  /// 撤销已经过期、却还挂在系统里的课程提醒。
  ///
  /// 设备重启 / 应用更新后，插件会把排期缓存重新注册成闹钟，已经过期的闹钟
  /// 会被 Android **立刻**触发——用户就会在半夜或开机时突然收到“课程即将开始”。
  /// 所以每次后台检查（包括“今天已排过”的提前返回路径）都要先清理一遍。
  static Future<void> purgeStaleReminders() async {
    final state = await _loadCleanPlan();
    await NotificationService.instance._writePlan(state.plan);
  }

  /// 读取本地排期并清理：过期闹钟撤销、和系统状态对不上的记录删除。
  static Future<({Map<int, int> plan, Set<int> pending})>
  _loadCleanPlan() async {
    final service = NotificationService.instance;
    await service.ensureInitialized();

    final plan = await service._readPlan();
    final pending = (await service.notifications.pendingNotificationRequests())
        .map((request) => request.id)
        .toSet();

    // 系统里的闹钟太多时先全清，避免撞上 Android 的 500 个闹钟上限
    if (pending.length >= 450) {
      AppLogger.debug('检测到闹钟接近上限 (${pending.length})，清空后重排');
      await service.notifications.cancelAll();
      plan.clear();
      pending.clear();
    }

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final staleBeforeMs = nowMs - _staleGrace.inMilliseconds;
    for (final id in plan.keys.toList()) {
      final scheduledMs = plan[id];
      if (scheduledMs == null) {
        plan.remove(id);
        continue;
      }

      if (scheduledMs <= staleBeforeMs) {
        if (pending.contains(id)) {
          await service.notifications.cancel(id: id);
          pending.remove(id);
          AppLogger.debug('撤销已过期的课程通知 id=$id');
        }
        plan.remove(id);
      } else if (!pending.contains(id)) {
        // 已经触发、被系统清掉或用户手动取消
        plan.remove(id);
      }
    }

    return (plan: plan, pending: pending);
  }

  /// 校准课程提醒排期：先清理过期/失效的旧闹钟，再按校区时区补排
  /// [targetDate] 当天的课程提醒。[courses] 为空时只做清理。
  static Future<void> remindList(
    List<CourseModel> courses, {
    DateTime? targetDate,
  }) async {
    final service = NotificationService.instance;
    final state = await _loadCleanPlan();
    final plan = state.plan;
    final pending = state.pending;

    final prefs = await PrefsService.getInstanceAsync();
    final advance = CourseReminderHelper.normalizeAdvanceMinutes(
      prefs.getInt(PrefsKeys.NOTIFICATION_TIME),
    );
    final now = tz.TZDateTime.now(CourseReminderHelper.campusLocation);
    final staleBeforeMs =
        now.millisecondsSinceEpoch - _staleGrace.inMilliseconds;

    // 补排：时间对不上的旧闹钟先撤销再重排，避免它按旧时间响。
    final effectiveDate = targetDate ?? DateTime.now();
    for (final course in courses) {
      final target = CourseReminderHelper.buildTarget(
        course: course,
        courseDate: effectiveDate,
      );
      if (target == null) {
        continue;
      }

      final id = target.notificationId;
      final reminderTime = CourseReminderHelper.resolveReminderTime(
        target: target,
        advanceMinutes: advance,
        now: now,
      );

      if (reminderTime == null) {
        // 这次不该再提醒了。只有确认是过期脏数据（或没有排期记录）才撤销，
        // 避免把刚被系统延后、马上就要响的闹钟误删。
        final scheduledMs = plan[id];
        final isStale = scheduledMs == null || scheduledMs <= staleBeforeMs;
        if (isStale && pending.contains(id)) {
          await service.notifications.cancel(id: id);
          pending.remove(id);
          plan.remove(id);
        }
        continue;
      }

      final scheduledMs = reminderTime.millisecondsSinceEpoch;
      if (plan[id] == scheduledMs && pending.contains(id)) {
        continue;
      }

      if (pending.contains(id)) {
        await service.notifications.cancel(id: id);
        pending.remove(id);
        plan.remove(id);
      }

      final scheduled = await service.scheduleCourseReminder(
        id: id,
        title: service._l10n.courseReminderTitle,
        body: course.courseName,
        reminderTime: reminderTime,
        advanceMinutes: advance,
      );

      if (scheduled) {
        plan[id] = scheduledMs;
        pending.add(id);
      }
    }

    await service._writePlan(plan);
  }
}
