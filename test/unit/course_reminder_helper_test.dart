import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/features/system/notifications/course_reminder_helper.dart';

void main() {
  group('CourseReminderHelper', () {
    test('should_build_target_for_tomorrow_course_with_correct_date', () {
      final course = CourseModel(
        courseName: '高等数学',
        courseCode: 'MATH101',
        lessonId: 'lesson-1',
        room: '教室101',
        campus: '雁塔校区',
        startUnit: 1,
        endUnit: 2,
        weekday: DateTime.tuesday,
      );

      final target = CourseReminderHelper.buildTarget(
        course: course,
        courseDate: DateTime(2026, 4, 19),
      );

      expect(target, isNotNull);
      expect(target!.courseTime, DateTime(2026, 4, 19, 8, 0));
    });

    test('should_generate_stable_notification_id_for_same_course_occurrence',
        () {
      final course = CourseModel(
        courseName: '大学英语',
        courseCode: 'ENG201',
        lessonId: 'lesson-2',
        room: '教室202',
        campus: '雁塔校区',
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
    });
  });
}
