import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// 课表时间所属的时区。
///
/// 课表里的 “8:00” 是校区所在时区的墙上时间，排通知时必须按这个时区换算成
/// 绝对时刻。如果改用设备当前的时区/时钟去换算（例如 `DateTime(y, m, d, h, min)`
/// 再 `TZDateTime.from`），一旦设备时区被改过、系统时间还没校准，或者在后台
/// isolate 里时区数据不一致，算出来的时刻就会整体偏移（常见是偏 8 小时），
/// 8:00 的课就会变成前一天半夜响。
const String kCampusTimeZoneName = 'Asia/Shanghai';

/// 默认提前 15 分钟提醒。
const int kDefaultReminderAdvanceMinutes = 15;

/// 提前量的合法范围。上限 2 小时：再大就可能把提醒推到课程前一天，
/// 用户会在半夜收到“课程即将开始”。
const int kMinReminderAdvanceMinutes = 1;
const int kMaxReminderAdvanceMinutes = 120;

class CourseReminderTarget {
  /// 课程开始的墙上时间（年月日时分，不带时区语义）。
  final DateTime courseTime;

  /// 通知 id，同一门课的同一次课保持稳定，用于去重和替换。
  final int notificationId;

  const CourseReminderTarget({
    required this.courseTime,
    required this.notificationId,
  });
}

class CourseReminderHelper {
  static tz.Location? _campusLocation;

  /// 校区时区。按需初始化时区库，后台 isolate 里没初始化过也能用。
  static tz.Location get campusLocation {
    final cached = _campusLocation;
    if (cached != null) {
      return cached;
    }
    tzdata.initializeTimeZones();
    return _campusLocation = tz.getLocation(kCampusTimeZoneName);
  }

  /// 计算某天这门课的提醒目标；作息表里取不到开始时间时返回 null。
  static CourseReminderTarget? buildTarget({
    required CourseModel course,
    required DateTime courseDate,
  }) {
    // 用课程当天的日期挑选季节作息表，避免跨季节边界时拿到另一季的时间。
    final time = TimeService.getStartAndEnd(course, date: courseDate);
    final start = time.startDateTime(courseDate);
    if (start == null) {
      return null;
    }

    return CourseReminderTarget(
      courseTime: start,
      notificationId: _buildNotificationId(course, start),
    );
  }

  /// 把墙上时间换算成校区时区下的绝对时刻。
  ///
  /// 只依赖 tz 数据库里的时区规则，不依赖设备当前的时区偏移，因此设备时区
  /// 被改过或系统时间未校准时也不会把 8:00 算成前一天半夜。
  static tz.TZDateTime toCampusTime(DateTime wallClock) {
    return tz.TZDateTime(
      campusLocation,
      wallClock.year,
      wallClock.month,
      wallClock.day,
      wallClock.hour,
      wallClock.minute,
      wallClock.second,
    );
  }

  /// 把提前量收敛到合理范围，坏数据（0、负数、几百分钟）不会把提醒推到半夜。
  static int normalizeAdvanceMinutes(int? minutes) {
    if (minutes == null) {
      return kDefaultReminderAdvanceMinutes;
    }
    if (minutes < kMinReminderAdvanceMinutes) {
      return kMinReminderAdvanceMinutes;
    }
    if (minutes > kMaxReminderAdvanceMinutes) {
      return kMaxReminderAdvanceMinutes;
    }
    return minutes;
  }

  /// 计算提醒时刻。
  ///
  /// 返回 null 的两种情形都不能排：
  /// - 提醒时刻已经过去/马上过去：Android 收到过去的闹钟会**立刻**弹出，
  ///   用户就会在半夜或者开机时突然收到“课程即将开始”。
  /// - 提前量把提醒推到了课程前一天：这种跨天提醒没有意义。
  static tz.TZDateTime? resolveReminderTime({
    required CourseReminderTarget target,
    required int advanceMinutes,
    required tz.TZDateTime now,
    Duration tolerance = const Duration(seconds: 2),
  }) {
    final courseStart = toCampusTime(target.courseTime);
    final reminderTime = courseStart.subtract(
      Duration(minutes: normalizeAdvanceMinutes(advanceMinutes)),
    );

    if (!reminderTime.isAfter(now.add(tolerance))) {
      return null;
    }

    final courseDay = tz.TZDateTime(
      campusLocation,
      target.courseTime.year,
      target.courseTime.month,
      target.courseTime.day,
    );
    if (reminderTime.isBefore(courseDay)) {
      return null;
    }

    return reminderTime;
  }

  static int _buildNotificationId(CourseModel course, DateTime courseTime) {
    return Object.hashAll([
          course.lessonId,
          course.courseCode,
          course.courseName,
          course.room,
          course.weekday,
          course.startUnit,
          course.endUnit,
          courseTime.year,
          courseTime.month,
          courseTime.day,
        ]) &
        0x7fffffff;
  }
}
