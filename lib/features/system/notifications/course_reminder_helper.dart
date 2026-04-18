import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';

class CourseReminderTarget {
  final DateTime courseTime;
  final int notificationId;

  const CourseReminderTarget({
    required this.courseTime,
    required this.notificationId,
  });
}

class CourseReminderHelper {
  static CourseReminderTarget? buildTarget({
    required CourseModel course,
    required DateTime courseDate,
  }) {
    final time = TimeService.getStartAndEnd(course);
    final parts = time.start.split(':');
    if (parts.length < 2) {
      return null;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }

    final normalizedDate = DateTime(
      courseDate.year,
      courseDate.month,
      courseDate.day,
      hour,
      minute,
    );

    return CourseReminderTarget(
      courseTime: normalizedDate,
      notificationId: _buildNotificationId(course, normalizedDate),
    );
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
