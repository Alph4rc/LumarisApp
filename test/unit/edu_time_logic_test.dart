import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/services/edu_time_service.dart';

void main() {
  group('EduTimeService.getWeekIndexByStartTime', () {
    // 假设第一周开始时间是 2024-03-04 (周一)
    // 根据逻辑，第一周的周日是 2024-03-03 (虽然在日期上它属于前一周，但计算周数时作为起点)
    final startTime = DateTime(2024, 3, 4);

    test('should return 1 for a date in the first week (Monday)', () {
      final now = DateTime(2024, 3, 4);
      expect(EduTimeService.getWeekIndexByStartTime(now, startTime), 1);
    });

    test('should return 1 for the Sunday of the first week', () {
      // 2024-03-03 是周日
      final now = DateTime(2024, 3, 3);
      expect(EduTimeService.getWeekIndexByStartTime(now, startTime), 1);
    });

    test('should return 2 for the Monday of the second week', () {
      // 2024-03-11 是周一
      final now = DateTime(2024, 3, 11);
      expect(EduTimeService.getWeekIndexByStartTime(now, startTime), 2);
    });

    test('should return 2 for the Sunday of the second week', () {
      // 2024-03-10 是周日
      final now = DateTime(2024, 3, 10);
      expect(EduTimeService.getWeekIndexByStartTime(now, startTime), 2);
    });

    test('should correctly transition from Saturday to Sunday (start of new week)', () {
      final saturday = DateTime(2024, 3, 9);
      final sunday = DateTime(2024, 3, 10);
      
      expect(EduTimeService.getWeekIndexByStartTime(saturday, startTime), 1);
      expect(EduTimeService.getWeekIndexByStartTime(sunday, startTime), 2);
    });

    test('should keep same week from Sunday to Monday', () {
      final sunday = DateTime(2024, 3, 10);
      final monday = DateTime(2024, 3, 11);
      
      expect(EduTimeService.getWeekIndexByStartTime(sunday, startTime), 2);
      expect(EduTimeService.getWeekIndexByStartTime(monday, startTime), 2);
    });
  });
}
