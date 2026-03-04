import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ios_club_app/core/models/course_model.dart';
import 'package:ios_club_app/core/repositories/course_repository.dart';
import 'package:ios_club_app/core/services/data_service.dart';
import 'package:ios_club_app/core/services/hive_manager.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

CourseModel _course({
  required String lessonId,
  required String courseName,
  required int weekday,
  required int startUnit,
  required int endUnit,
  required List<int> weekIndexes,
  bool isCustom = false,
  String campus = '雁塔校区',
  String room = 'A101',
}) {
  return CourseModel(
    lessonId: lessonId,
    courseName: courseName,
    weekIndexes: weekIndexes,
    teachers: ['T'],
    room: room,
    weekday: weekday,
    startUnit: startUnit,
    endUnit: endUnit,
    isCustom: isCustom,
    campus: campus,
  );
}

void main() {
  late Directory tempDir;
  late CourseRepository courseRepo;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();
  });

  setUp(() async {
    await PrefsService.instance.clear();
    tempDir = await Directory.systemTemp.createTemp('data_service_test_');
    Hive.init(tempDir.path);

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CourseModelAdapter());
    }

    courseRepo = CourseRepository();
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('DataService ignore list', () {
    test('should_set_and_get_ignore_list', () async {
      await DataService.setIgnore(['A', 'B']);

      final list = await DataService.getIgnore();

      expect(list, ['A', 'B']);
    });

    test('should_return_empty_ignore_list_when_key_missing', () async {
      final list = await DataService.getIgnore();
      expect(list, isEmpty);
    });
  });

  group('DataService course paths', () {
    test('should_get_all_course_with_ignore_and_custom_courses', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      await PrefsService.instance
          .setInt(PrefsKeys.COURSE_LAST_FETCH_TIME, nowMs);

      await courseRepo.saveCourses([
        _course(
          lessonId: 'L1',
          courseName: '数学',
          weekday: 1,
          startUnit: 1,
          endUnit: 2,
          weekIndexes: [1],
        ),
        _course(
          lessonId: 'L2',
          courseName: '英语',
          weekday: 2,
          startUnit: 3,
          endUnit: 4,
          weekIndexes: [1],
        ),
      ]);

      await DataService.setIgnore(['英语']);
      await PrefsService.instance.setString(
        'custom_courses',
        jsonEncode([
          _course(
            lessonId: '',
            courseName: '自定义课程',
            weekday: 3,
            startUnit: 5,
            endUnit: 6,
            weekIndexes: [1],
            isCustom: true,
          ).toJson(),
        ]),
      );

      final allCourses = await DataService.getAllCourse();
      final names = allCourses.map((e) => e.courseName).toSet();

      expect(names.contains('数学'), isTrue);
      expect(names.contains('英语'), isFalse);
      expect(names.contains('自定义课程'), isTrue);
    });

    test('should_skip_invalid_custom_courses_json', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      await PrefsService.instance
          .setInt(PrefsKeys.COURSE_LAST_FETCH_TIME, nowMs);

      await courseRepo.saveCourses([
        _course(
          lessonId: 'L1',
          courseName: '数学',
          weekday: 1,
          startUnit: 1,
          endUnit: 2,
          weekIndexes: [1],
        ),
      ]);
      await PrefsService.instance.setString('custom_courses', 'not-json');

      final allCourses = await DataService.getAllCourse();

      expect(allCourses, hasLength(1));
      expect(allCourses.first.courseName, '数学');
    });

    test('should_get_course_names_without_custom_and_duplicates', () async {
      await courseRepo.saveCourses([
        _course(
          lessonId: 'L1',
          courseName: '数学',
          weekday: 1,
          startUnit: 1,
          endUnit: 2,
          weekIndexes: [1],
        ),
        _course(
          lessonId: 'L2',
          courseName: '数学',
          weekday: 2,
          startUnit: 3,
          endUnit: 4,
          weekIndexes: [1],
        ),
        _course(
          lessonId: '',
          courseName: '自定义课程',
          weekday: 3,
          startUnit: 5,
          endUnit: 6,
          weekIndexes: [1],
          isCustom: true,
        ),
      ]);

      final names = await DataService.getCourseName();

      expect(names, ['数学']);
    });

    test('should_get_course_by_week_when_week_specified', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      await PrefsService.instance
          .setInt(PrefsKeys.COURSE_LAST_FETCH_TIME, nowMs);

      await courseRepo.saveCourses([
        _course(
          lessonId: 'W2',
          courseName: '第2周课程',
          weekday: 1,
          startUnit: 1,
          endUnit: 2,
          weekIndexes: [2],
        ),
        _course(
          lessonId: 'W3',
          courseName: '第3周课程',
          weekday: 2,
          startUnit: 3,
          endUnit: 4,
          weekIndexes: [3],
        ),
      ]);

      final list = await DataService.getCourseByWeek(week: 2);

      expect(list, hasLength(1));
      expect(list.first.courseName, '第2周课程');
    });
  });

  group('DataService cached time/semester/info paths', () {
    test('should_get_time_from_cache_without_refresh', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      await PrefsService.instance.setString(
        PrefsKeys.TIME_DATA,
        jsonEncode({
          'startTime': '2026-02-01T00:00:00.000',
          'endTime': '2026-07-01T00:00:00.000',
          'semester': '2025-2026-2',
          'note': 'cached',
        }),
      );
      await PrefsService.instance.setInt(PrefsKeys.TIME_LAST_UPDATED, nowMs);

      final time = await DataService.getTime();

      expect(time.startTime, '2026-02-01T00:00:00.000');
      expect(time.endTime, '2026-07-01T00:00:00.000');
      expect(time.semester, '2025-2026-2');
      expect(time['note'], 'cached');
    });

    test('should_return_zero_week_when_start_time_missing', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      await PrefsService.instance.setString(
        PrefsKeys.TIME_DATA,
        jsonEncode({'endTime': '2026-07-01T00:00:00.000'}),
      );
      await PrefsService.instance.setInt(PrefsKeys.TIME_LAST_UPDATED, nowMs);

      final weekInfo = await DataService.getWeek();

      expect(weekInfo.week, 0);
      expect(weekInfo.maxWeek, 0);
    });

    test('should_compute_week_and_max_week_from_cached_time', () async {
      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 3));
      final end = now.add(const Duration(days: 30));
      final nowMs = now.millisecondsSinceEpoch;

      await PrefsService.instance.setString(
        PrefsKeys.TIME_DATA,
        jsonEncode({
          'startTime': start.toIso8601String(),
          'endTime': end.toIso8601String(),
          'semester': '2025-2026-2',
        }),
      );
      await PrefsService.instance.setInt(PrefsKeys.TIME_LAST_UPDATED, nowMs);

      final weekInfo = await DataService.getWeek();

      expect(weekInfo.week, greaterThanOrEqualTo(1));
      expect(weekInfo.maxWeek, greaterThanOrEqualTo(weekInfo.week));
    });

    test('should_get_semester_from_cached_json', () async {
      final nowMicros = DateTime.now().microsecondsSinceEpoch;
      await PrefsService.instance.setInt(PrefsKeys.SEMESTER_TIME, nowMicros);
      await PrefsService.instance.setString(
        PrefsKeys.SEMESTER_DATA,
        jsonEncode({
          'data': [
            {'value': '2025-2026-2', 'text': '2025-2026学年第二学期'}
          ]
        }),
      );

      final semesters = await DataService.getSemester();

      expect(semesters, hasLength(1));
      expect(semesters.first.semester, '2025-2026-2');
    });

    test('should_get_info_list_from_cache_when_not_expired', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      await PrefsService.instance.setString(
        PrefsKeys.INFO_DATA,
        jsonEncode([
          {
            'type': 'electricity',
            'total': {'name': '宿舍', 'actual': 10, 'full': 100},
            'other': [
              {'name': 'A', 'actual': 1, 'full': 10}
            ],
          }
        ]),
      );
      await PrefsService.instance.setInt(PrefsKeys.INFO_DATA_TIME, nowMs);

      final list = await DataService.getInfoList();

      expect(list, hasLength(1));
      expect(list.first.type, 'electricity');
      expect(list.first.total.name, '宿舍');
    });
  });

  group('DataService today/tomorrow selection', () {
    test('should_return_tomorrow_courses_when_today_empty_and_enabled',
        () async {
      final now = DateTime.now();
      final nowMs = now.millisecondsSinceEpoch;
      final start = now.subtract(const Duration(days: 1)).toIso8601String();
      final end = now.add(const Duration(days: 60)).toIso8601String();

      await PrefsService.instance
          .setInt(PrefsKeys.COURSE_LAST_FETCH_TIME, nowMs);
      await PrefsService.instance.setString(
        PrefsKeys.TIME_DATA,
        jsonEncode({'startTime': start, 'endTime': end, 'semester': 'S'}),
      );
      await PrefsService.instance.setInt(PrefsKeys.TIME_LAST_UPDATED, nowMs);

      var tomorrowWeek = 1;
      var tomorrowWeekday = now.weekday + 1;
      if (tomorrowWeekday == 7) {
        tomorrowWeek++;
      }
      if (tomorrowWeekday > 7) {
        tomorrowWeekday = 1;
      }

      await courseRepo.saveCourses([
        _course(
          lessonId: 'T1',
          courseName: '明天课程',
          weekday: tomorrowWeekday,
          startUnit: 11,
          endUnit: 12,
          weekIndexes: [tomorrowWeek],
        ),
      ]);

      final result =
          await DataService.getTodayOrTomorrowCourse(isTomorrow: true);

      expect(result.$1, isTrue);
      expect(result.$2, isNotEmpty);
      expect(result.$2.first.courseName, '明天课程');
    });

    test('should_get_today_and_tomorrow_courses_map', () async {
      final now = DateTime.now();
      final nowMs = now.millisecondsSinceEpoch;
      final start = now.subtract(const Duration(days: 1)).toIso8601String();
      final end = now.add(const Duration(days: 60)).toIso8601String();

      await PrefsService.instance
          .setInt(PrefsKeys.COURSE_LAST_FETCH_TIME, nowMs);
      await PrefsService.instance.setString(
        PrefsKeys.TIME_DATA,
        jsonEncode({'startTime': start, 'endTime': end, 'semester': 'S'}),
      );
      await PrefsService.instance.setInt(PrefsKeys.TIME_LAST_UPDATED, nowMs);

      var tomorrowWeek = 1;
      var tomorrowWeekday = now.weekday + 1;
      if (tomorrowWeekday >= 7) {
        tomorrowWeek++;
      }
      if (tomorrowWeekday > 7) {
        tomorrowWeekday = 1;
      }

      await courseRepo.saveCourses([
        _course(
          lessonId: 'TM',
          courseName: '明天课程',
          weekday: tomorrowWeekday,
          startUnit: 11,
          endUnit: 12,
          weekIndexes: [tomorrowWeek],
        ),
      ]);

      final map = await DataService.getTodayAndTomorrowCourses();

      expect(map.containsKey('today'), isTrue);
      expect(map.containsKey('tomorrow'), isTrue);
      expect(map['tomorrow'], isNotNull);
      expect(map['tomorrow']!, isNotEmpty);
    });
  });

  test('should_return_sorted_future_all_time_entries', () async {
    final now = DateTime.now();
    final nowMs = now.millisecondsSinceEpoch;
    final start = now.subtract(const Duration(days: 2)).toIso8601String();
    final end = now.add(const Duration(days: 40)).toIso8601String();

    await PrefsService.instance.setInt(PrefsKeys.COURSE_LAST_FETCH_TIME, nowMs);
    await PrefsService.instance.setString(
      PrefsKeys.TIME_DATA,
      jsonEncode({'startTime': start, 'endTime': end, 'semester': 'S'}),
    );
    await PrefsService.instance.setInt(PrefsKeys.TIME_LAST_UPDATED, nowMs);

    final targetWeekday = now.weekday < 6 ? now.weekday + 1 : 6;

    await courseRepo.saveCourses([
      _course(
        lessonId: 'A',
        courseName: '较晚课程',
        weekday: targetWeekday,
        startUnit: 11,
        endUnit: 12,
        weekIndexes: [1],
      ),
      _course(
        lessonId: 'B',
        courseName: '较早课程',
        weekday: targetWeekday,
        startUnit: 7,
        endUnit: 8,
        weekIndexes: [1],
      ),
    ]);

    final list = await DataService.getAllTime();

    expect(list, isA<List>());
    if (list.length >= 2) {
      expect(
          list.first.startTime.isBefore(list.last.startTime) ||
              list.first.startTime.isAtSameMomentAs(list.last.startTime),
          isTrue);
    }
  });
}
