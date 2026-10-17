import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/features/system/widget_schedule_snapshot.dart';

CourseModel _course({
  String name = '高等数学',
  String room = '教学楼A101',
  List<String> teachers = const ['张老师'],
  int weekday = 3,
  int startUnit = 1,
  int endUnit = 2,
  List<int> weeks = const [1, 2, 3],
  String campus = '草堂校区',
  bool isCustom = false,
}) {
  return CourseModel(
    courseName: name,
    room: room,
    teachers: teachers,
    weekday: weekday,
    startUnit: startUnit,
    endUnit: endUnit,
    weekIndexes: weeks,
    campus: campus,
    isCustom: isCustom,
  );
}

void main() {
  group('WidgetScheduleSnapshot.build', () {
    test('should serialize course fields the widget needs', () {
      final snapshot = WidgetScheduleSnapshot.build(
        courses: [_course()],
        tables: TimeService.builtInTables,
        semesterStart: '2026-09-01T00:00:00',
        semesterEnd: '2027-01-12T00:00:00',
        weekStartDay: DateTime.monday,
      );

      final courses = snapshot['courses'] as List;
      expect(courses, hasLength(1));
      expect(courses.first, {
        'name': '高等数学',
        'room': '教学楼A101',
        'teachers': ['张老师'],
        'weekday': 3,
        'startUnit': 1,
        'endUnit': 2,
        'weeks': [1, 2, 3],
        'campus': '草堂校区',
      });
    });

    test('should normalize semester bounds to yyyy-MM-dd', () {
      final snapshot = WidgetScheduleSnapshot.build(
        courses: const [],
        tables: TimeService.builtInTables,
        semesterStart: '2026-09-01T08:30:00',
        semesterEnd: '2027-01-12',
        weekStartDay: DateTime.sunday,
      );

      expect(snapshot['semesterStart'], '2026-09-01');
      expect(snapshot['semesterEnd'], '2027-01-12');
    });

    test('should drop semester bounds that cannot be parsed', () {
      final snapshot = WidgetScheduleSnapshot.build(
        courses: const [],
        tables: TimeService.builtInTables,
        semesterStart: 'not-a-date',
        semesterEnd: null,
        weekStartDay: DateTime.sunday,
      );

      expect(snapshot['semesterStart'], isNull);
      expect(snapshot['semesterEnd'], isNull);
    });

    test('should drop courses the widget cannot place on a day', () {
      final snapshot = WidgetScheduleSnapshot.build(
        courses: [
          _course(),
          _course(name: '', weekday: 3),
          _course(weekday: 0),
          _course(weekday: 8),
          _course(startUnit: 0),
          _course(startUnit: 3, endUnit: 2),
        ],
        tables: TimeService.builtInTables,
        semesterStart: '2026-09-01',
        semesterEnd: '2027-01-12',
        weekStartDay: DateTime.sunday,
      );

      expect(snapshot['courses'], hasLength(1));
    });

    test('should always ship the default campus table', () {
      final snapshot = WidgetScheduleSnapshot.build(
        courses: const [],
        tables: const [
          ScheduleTable(
            campusName: '雁塔校区',
            start: ['', '08:00'],
            end: ['', '08:45'],
          ),
        ],
        semesterStart: '2026-09-01',
        semesterEnd: '2027-01-12',
        weekStartDay: DateTime.sunday,
      );

      final campuses = (snapshot['tables'] as List)
          .map((table) => (table as Map)['campus'])
          .toList();
      expect(campuses, contains(TimeService.caoTangCampus));
    });

    test('should not duplicate the default campus table', () {
      final snapshot = WidgetScheduleSnapshot.build(
        courses: const [],
        tables: TimeService.builtInTables,
        semesterStart: '2026-09-01',
        semesterEnd: '2027-01-12',
        weekStartDay: DateTime.sunday,
      );

      final campuses = (snapshot['tables'] as List)
          .map((table) => (table as Map)['campus'])
          .where((campus) => campus == TimeService.caoTangCampus)
          .toList();
      expect(campuses, hasLength(1));
    });

    test('should serialize table time range and periods', () {
      final snapshot = WidgetScheduleSnapshot.build(
        courses: const [],
        tables: TimeService.builtInTables,
        semesterStart: '2026-09-01',
        semesterEnd: '2027-01-12',
        weekStartDay: DateTime.sunday,
      );

      final tables = (snapshot['tables'] as List).cast<Map>();
      final yanTa = tables.firstWhere(
        (table) => table['range'] == '10/01~04/30',
      );
      expect(yanTa['campus'], '雁塔校区');
      expect(yanTa['start'], isA<List>());
      expect(yanTa['end'], isA<List>());
    });

    test('should fall back to sunday for an unsupported week start day', () {
      final snapshot = WidgetScheduleSnapshot.build(
        courses: const [],
        tables: TimeService.builtInTables,
        semesterStart: '2026-09-01',
        semesterEnd: '2027-01-12',
        weekStartDay: 4,
      );

      expect(snapshot['weekStartDay'], DateTime.sunday);
    });

    test(
      'should resolve campus from the room when the campus field is wrong',
      () {
        final snapshot = WidgetScheduleSnapshot.build(
          courses: [_course(campus: '雁塔校区', room: '草堂8-101')],
          tables: TimeService.builtInTables,
          semesterStart: '2026-09-01',
          semesterEnd: '2027-01-12',
          weekStartDay: DateTime.sunday,
        );

        final courses = snapshot['courses'] as List;
        expect((courses.first as Map)['campus'], TimeService.caoTangCampus);
      },
    );
  });
}
