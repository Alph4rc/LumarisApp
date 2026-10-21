import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/features/system/notifications/course_reminder_helper.dart';
import 'package:timezone/timezone.dart' as tz;

CourseModel _buildCourse({
  String campus = '雁塔校区',
  int startUnit = 1,
  int endUnit = 2,
  int weekday = DateTime.tuesday,
  String name = '高等数学',
  String code = 'MATH101',
  String lessonId = 'lesson-1',
  String room = '教室101',
}) {
  return CourseModel(
    courseName: name,
    courseCode: code,
    lessonId: lessonId,
    room: room,
    campus: campus,
    startUnit: startUnit,
    endUnit: endUnit,
    weekday: weekday,
  );
}

void main() {
  group('CourseReminderHelper', () {
    test('should_build_target_for_tomorrow_course_with_correct_date', () {
      final course = _buildCourse();

      final target = CourseReminderHelper.buildTarget(
        course: course,
        courseDate: DateTime(2026, 4, 19),
      );

      expect(target, isNotNull);
      expect(target!.courseTime, DateTime(2026, 4, 19, 8, 0));
    });

    test(
      'should_generate_stable_notification_id_for_same_course_occurrence',
      () {
        final course = _buildCourse(
          name: '大学英语',
          code: 'ENG201',
          room: '教室202',
          lessonId: 'lesson-2',
          startUnit: 8,
          endUnit: 9,
          weekday: DateTime.wednesday,
        );

        final first = CourseReminderHelper.buildTarget(
          course: course,
          courseDate: DateTime(2026, 4, 20),
        );
        final second = CourseReminderHelper.buildTarget(
          course: course,
          courseDate: DateTime(2026, 4, 20),
        );

        expect(first, isNotNull);
        expect(second, isNotNull);
        expect(first!.notificationId, second!.notificationId);
      },
    );

    test('should_anchor_course_start_to_campus_time_zone', () {
      final target = CourseReminderHelper.buildTarget(
        course: _buildCourse(),
        courseDate: DateTime(2026, 4, 20),
      );

      final start = CourseReminderHelper.toCampusTime(target!.courseTime);

      expect(start.hour, 8);
      expect(start.minute, 0);
      // 上海 2026-04-20 08:00 就是 2026-04-20 00:00 UTC。
      // 结论与运行测试的机器时区无关，能挡住“按设备时区换算导致整体偏移”的回归。
      expect(
        start.millisecondsSinceEpoch,
        DateTime.utc(2026, 4, 20).millisecondsSinceEpoch,
      );
    });

    test('should_use_course_date_to_pick_seasonal_schedule_table', () {
      final course = _buildCourse(startUnit: 7, endUnit: 8);

      // 10/01~04/30 是雁塔冬季表：第 7 节 14:00
      final winter = CourseReminderHelper.buildTarget(
        course: course,
        courseDate: DateTime(2026, 4, 20),
      );
      // 05/01~09/30 是雁塔夏季表：第 7 节 14:30
      final summer = CourseReminderHelper.buildTarget(
        course: course,
        courseDate: DateTime(2026, 6, 1),
      );

      expect(winter!.courseTime, DateTime(2026, 4, 20, 14, 0));
      expect(summer!.courseTime, DateTime(2026, 6, 1, 14, 30));
    });

    test('should_return_null_when_start_time_is_missing', () {
      final target = CourseReminderHelper.buildTarget(
        // 节次超出作息表范围，取不到开始时间
        course: _buildCourse(startUnit: 99, endUnit: 99),
        courseDate: DateTime(2026, 4, 20),
      );

      expect(target, isNull);
    });

    test('should_schedule_reminder_before_course_start', () {
      final target = CourseReminderHelper.buildTarget(
        course: _buildCourse(),
        courseDate: DateTime(2026, 4, 20),
      );
      final now = tz.TZDateTime(
        CourseReminderHelper.campusLocation,
        2026,
        4,
        20,
        7,
      );

      final reminder = CourseReminderHelper.resolveReminderTime(
        target: target!,
        advanceMinutes: 15,
        now: now,
      );

      expect(reminder, isNotNull);
      expect(reminder!.hour, 7);
      expect(reminder.minute, 45);
      expect(
        reminder.millisecondsSinceEpoch,
        DateTime.utc(2026, 4, 19, 23, 45).millisecondsSinceEpoch,
      );
    });

    test('should_skip_reminder_that_is_already_in_the_past', () {
      final target = CourseReminderHelper.buildTarget(
        course: _buildCourse(),
        courseDate: DateTime(2026, 4, 20),
      );
      final now = tz.TZDateTime(
        CourseReminderHelper.campusLocation,
        2026,
        4,
        20,
        7,
        50,
      );

      final reminder = CourseReminderHelper.resolveReminderTime(
        target: target!,
        advanceMinutes: 15,
        now: now,
      );

      expect(reminder, isNull);
    });

    test('should_keep_large_advance_on_the_same_day', () {
      final target = CourseReminderHelper.buildTarget(
        course: _buildCourse(),
        courseDate: DateTime(2026, 4, 20),
      );
      final now = tz.TZDateTime(
        CourseReminderHelper.campusLocation,
        2026,
        4,
        20,
        5,
      );

      final reminder = CourseReminderHelper.resolveReminderTime(
        target: target!,
        advanceMinutes: 120,
        now: now,
      );

      expect(reminder, isNotNull);
      expect(reminder!.day, 20);
      expect(reminder.hour, 6);
    });

    test('should_skip_reminder_that_crosses_to_the_previous_day', () {
      final target = CourseReminderTarget(
        // 00:10 的课，提前 120 分钟就会落到前一天 22:10
        courseTime: DateTime(2026, 4, 20, 0, 10),
        notificationId: 1,
      );
      final now = tz.TZDateTime(
        CourseReminderHelper.campusLocation,
        2026,
        4,
        19,
        22,
      );

      final reminder = CourseReminderHelper.resolveReminderTime(
        target: target,
        advanceMinutes: 120,
        now: now,
      );

      expect(reminder, isNull);
    });

    test('should_clamp_invalid_advance_minutes', () {
      expect(CourseReminderHelper.normalizeAdvanceMinutes(null), 15);
      expect(CourseReminderHelper.normalizeAdvanceMinutes(15), 15);
      expect(CourseReminderHelper.normalizeAdvanceMinutes(480), 120);
      expect(CourseReminderHelper.normalizeAdvanceMinutes(0), 1);
      expect(CourseReminderHelper.normalizeAdvanceMinutes(-30), 1);
    });
  });

  group('StartAndEnd', () {
    test('should_parse_clock_strings_into_date_time', () {
      final time = StartAndEnd(start: '8:00', end: '09:50');

      expect(
        time.startDateTime(DateTime(2026, 4, 20)),
        DateTime(2026, 4, 20, 8),
      );
      expect(
        time.endDateTime(DateTime(2026, 4, 20)),
        DateTime(2026, 4, 20, 9, 50),
      );
      expect(
        StartAndEnd(
          start: '9：05',
          end: '',
        ).startDateTime(DateTime(2026, 4, 20)),
        DateTime(2026, 4, 20, 9, 5),
      );
    });

    test('should_return_null_for_empty_or_invalid_clock_strings', () {
      final date = DateTime(2026, 4, 20);

      expect(StartAndEnd(start: '', end: '').startDateTime(date), isNull);
      expect(StartAndEnd(start: 'abc', end: '').startDateTime(date), isNull);
      expect(StartAndEnd(start: '25:00', end: '').startDateTime(date), isNull);
      expect(StartAndEnd(start: '8:70', end: '').startDateTime(date), isNull);
    });
  });
}
