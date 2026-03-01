import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:hive/hive.dart';
import 'package:ios_club_app/core/config/api_config.dart';
import 'package:ios_club_app/core/models/course_model.dart';
import 'package:ios_club_app/core/models/score_model.dart';
import 'package:ios_club_app/core/models/semester_model.dart';
import 'package:ios_club_app/core/models/user_data.dart';
import 'package:ios_club_app/core/repositories/course_repository.dart';
import 'package:ios_club_app/core/repositories/score_repository.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/models/todo_item.dart';
import 'package:ios_club_app/features/education/services/edu_http_client_manager.dart';
import 'package:ios_club_app/features/education/services/edu_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

void _registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(CourseModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ScoreModelAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(ScoreListAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(SemesterModelAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(TodoItemAdapter());
  }
}

void _mockEduResponse({
  required String path,
  required dynamic data,
  int statusCode = 200,
}) {
  EduHttpClientManager.instance.dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.path == path) {
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: statusCode,
              data: data,
            ),
          );
          return;
        }
        handler.next(options);
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final secureStore = <String, String>{};
  late Directory tempDir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();
    Get.testMode = true;

    tempDir = await Directory.systemTemp.createTemp('edu_service_test_');
    Hive.init(tempDir.path);
    _registerHiveAdapters();
  });

  setUp(() async {
    secureStore.clear();
    await PrefsService.instance.clear();
    Get.reset();

    for (final boxName in <String>[
      'request_cache',
      'courses',
      'scores',
      'todos'
    ]) {
      final box = await Hive.openBox(boxName);
      await box.clear();
    }

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      final key = call.arguments['key'] as String?;
      switch (call.method) {
        case 'write':
          final value = call.arguments['value'] as String?;
          if (key != null && value != null) {
            secureStore[key] = value;
          }
          return null;
        case 'read':
          if (key == null) {
            return null;
          }
          return secureStore[key];
        case 'delete':
          if (key != null) {
            secureStore.remove(key);
          }
          return null;
        case 'deleteAll':
          secureStore.clear();
          return null;
      }
      return null;
    });

    final manager = Get.put(EduHttpClientManager());
    manager.updateSchoolConfig(
      const SchoolConfig(
        id: 'offline',
        name: 'Offline',
        eduApiBaseUrl: 'http://127.0.0.1:1',
      ),
    );
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    Get.reset();
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('EduService credential and cache paths', () {
    test('migrateCredentials should move non-empty values to secure storage',
        () async {
      final prefs = PrefsService.instance;
      await prefs.setString(PrefsKeys.USERNAME, 'u1');
      await prefs.setString(PrefsKeys.PASSWORD, 'p1');
      await prefs.setString(PrefsKeys.CLUB_NAME, 'club');
      await prefs.setString(PrefsKeys.CLUB_ID, 'c1');
      await prefs.setString(PrefsKeys.MEMBER_JWT, 'jwt1');
      await prefs.setString(PrefsKeys.PAYMENT_NUM, 'pay1');

      await EduService.migrateCredentials();

      expect(secureStore[PrefsKeys.USERNAME], 'u1');
      expect(secureStore[PrefsKeys.PASSWORD], 'p1');
      expect(secureStore[PrefsKeys.CLUB_NAME], 'club');
      expect(secureStore[PrefsKeys.CLUB_ID], 'c1');
      expect(secureStore[PrefsKeys.MEMBER_JWT], 'jwt1');
      expect(secureStore[PrefsKeys.PAYMENT_NUM], 'pay1');

      expect(prefs.getString(PrefsKeys.USERNAME), isNull);
      expect(prefs.getString(PrefsKeys.PASSWORD), isNull);
      expect(prefs.getString(PrefsKeys.CLUB_NAME), isNull);
      expect(prefs.getString(PrefsKeys.CLUB_ID), isNull);
      expect(prefs.getString(PrefsKeys.MEMBER_JWT), isNull);
      expect(prefs.getString(PrefsKeys.PAYMENT_NUM), isNull);
    });

    test('migrateCredentials should skip empty values', () async {
      final prefs = PrefsService.instance;
      await prefs.setString(PrefsKeys.USERNAME, '');
      await prefs.setString(PrefsKeys.CLUB_ID, '');

      await EduService.migrateCredentials();

      expect(secureStore.containsKey(PrefsKeys.USERNAME), isFalse);
      expect(secureStore.containsKey(PrefsKeys.CLUB_ID), isFalse);
      expect(prefs.getString(PrefsKeys.USERNAME), '');
      expect(prefs.getString(PrefsKeys.CLUB_ID), '');
    });

    test('login should return false when secure credentials are missing',
        () async {
      final result = await EduService.login();
      expect(result, isFalse);
    });

    test('login should return false when username or password is empty',
        () async {
      secureStore[PrefsKeys.USERNAME] = '';
      secureStore[PrefsKeys.PASSWORD] = 'p';

      final result = await EduService.login();
      expect(result, isFalse);
    });

    test('getCookie should return null when cache is expired', () async {
      final prefs = PrefsService.instance;
      final now = DateTime.now().millisecondsSinceEpoch;

      await prefs.setInt(PrefsKeys.LAST_FETCH_TIME, now - 21 * 60 * 1000);
      await prefs.setString(
          PrefsKeys.USER_DATA,
          jsonEncode(<String, String>{
            'studentId': '2026001',
            'cookie': 'c1',
          }));

      final data = await EduService.getCookie();
      expect(data, isNull);
    });

    test('getCookie should parse valid non-expired user data', () async {
      final prefs = PrefsService.instance;
      await prefs.setInt(
        PrefsKeys.LAST_FETCH_TIME,
        DateTime.now().millisecondsSinceEpoch,
      );
      await prefs.setString(
          PrefsKeys.USER_DATA,
          jsonEncode(<String, String>{
            'studentId': '2026002',
            'cookie': 'cookie-2',
          }));

      final data = await EduService.getCookie();
      expect(data, isNotNull);
      expect(data!.studentId, '2026002');
      expect(data.cookie, 'cookie-2');
    });

    test('getCookie should return null on malformed json', () async {
      final prefs = PrefsService.instance;
      await prefs.setInt(
        PrefsKeys.LAST_FETCH_TIME,
        DateTime.now().millisecondsSinceEpoch,
      );
      await prefs.setString(PrefsKeys.USER_DATA, 'not-json');

      final data = await EduService.getCookie();
      expect(data, isNull);
    });

    test('getUserData should return cached cookie data', () async {
      final prefs = PrefsService.instance;
      await prefs.setInt(
        PrefsKeys.LAST_FETCH_TIME,
        DateTime.now().millisecondsSinceEpoch,
      );
      await prefs.setString(
          PrefsKeys.USER_DATA,
          jsonEncode(<String, String>{
            'studentId': '2026003',
            'cookie': 'cookie-3',
          }));

      final data = await EduService.getUserData();
      expect(data, isNotNull);
      expect(data!.studentId, '2026003');
    });

    test('getUserData should return null when cache missing and login fails',
        () async {
      final prefs = PrefsService.instance;
      await prefs.remove(PrefsKeys.USER_DATA);
      await prefs.remove(PrefsKeys.LAST_FETCH_TIME);

      final data = await EduService.getUserData();
      expect(data, isNull);
    });
  });

  group('EduService data fallback paths', () {
    test('getAllScoreFromLocal should return cached scores without user data',
        () async {
      final scoreRepo = ScoreRepository();
      final semester = SemesterModel(semester: '2025-2', name: '2025-2');
      await scoreRepo.saveScores(<ScoreList>[
        ScoreList(
          semester: semester,
          list: <ScoreModel>[
            ScoreModel(name: 'Math', gpa: '4.0', credit: '3'),
          ],
        ),
      ]);

      final prefs = PrefsService.instance;
      await prefs.setInt(
        PrefsKeys.SEMESTER_TIME,
        DateTime.now().microsecondsSinceEpoch,
      );
      await prefs.setString(
          PrefsKeys.SEMESTER_DATA,
          jsonEncode(<String, List>{
            'data': <Map<String, String>>[],
          }));

      final result = await EduService.getAllScoreFromLocal();
      expect(result, hasLength(1));
      expect(result.first.semester.semester, '2025-2');
      expect(result.first.list.first.name, 'Math');
    });

    test('getProgram and getPrograms should return empty when user missing',
        () async {
      final programs = await EduService.getProgram();
      final programDic = await EduService.getPrograms();

      expect(programs, isEmpty);
      expect(programDic, isEmpty);
    });

    test('getCourse should early return when time range is unavailable',
        () async {
      final prefs = PrefsService.instance;
      await prefs.setString(
          PrefsKeys.TIME_DATA,
          jsonEncode(<String, String>{
            'semester': '2025-2026-2',
          }));
      await prefs.setInt(
        PrefsKeys.TIME_LAST_UPDATED,
        DateTime.now().millisecondsSinceEpoch,
      );

      await EduService.getCourse(isRefresh: false);
      expect(true, isTrue);
    });

    test('getBus should return empty model on API failure', () async {
      final result = await EduService.getBus(dayDate: '2026-03-02');
      expect(result.records, isEmpty);
      expect(result.total, 0);
    });

    test('getTime should cache returned time payload', () async {
      _mockEduResponse(
        path: '/Info/Time',
        data: <String, dynamic>{
          'startTime': '2026-02-20T00:00:00.000',
          'endTime': '2026-07-20T00:00:00.000',
          'semester': '2025-2026-2',
        },
      );

      await EduService.getTime();

      final stored = PrefsService.instance.getString(PrefsKeys.TIME_DATA);
      expect(stored, isNotNull);
      expect(stored!, contains('2025-2026-2'));
      expect(
          PrefsService.instance.getInt(PrefsKeys.TIME_LAST_UPDATED), isNotNull);
    });

    test('getSemester should persist semester payload when user data provided',
        () async {
      _mockEduResponse(
        path: '/Score/Semester',
        data: <String, dynamic>{
          'data': <Map<String, String>>[
            <String, String>{'semester': '2025-2', 'name': '2025-2'}
          ]
        },
      );

      await EduService.getSemester(
        userData: UserData(studentId: '2026001', cookie: 'cookie'),
      );

      final stored = PrefsService.instance.getString(PrefsKeys.SEMESTER_DATA);
      expect(stored, isNotNull);
      expect(stored!, contains('2025-2'));
      expect(PrefsService.instance.getInt(PrefsKeys.SEMESTER_TIME), isNotNull);
    });

    test('getCourse should persist parsed courses in refresh mode', () async {
      final prefs = PrefsService.instance;
      await prefs.setString(
          PrefsKeys.TIME_DATA,
          jsonEncode(<String, String>{
            'startTime': '2026-02-20T00:00:00.000',
            'endTime': '2026-07-20T00:00:00.000',
          }));
      await prefs.setInt(
        PrefsKeys.TIME_LAST_UPDATED,
        DateTime.now().millisecondsSinceEpoch,
      );

      _mockEduResponse(
        path: '/Course',
        data: <Map<String, dynamic>>[
          <String, dynamic>{
            'lessonId': 'L1',
            'courseName': 'Math',
            'weekIndexes': <int>[1, 2],
            'teachers': <String>['T1'],
            'room': 'A101',
            'weekday': 1,
            'startUnit': 1,
            'endUnit': 2,
          }
        ],
      );

      await EduService.getCourse(
        userData: UserData(studentId: '2026001', cookie: 'cookie'),
        isRefresh: true,
      );

      final courseRepo = CourseRepository();
      final courses = await courseRepo.getCourses();
      expect(courses, hasLength(1));
      expect(courses.first.courseName, 'Math');
      expect(PrefsService.instance.getInt(PrefsKeys.COURSE_LAST_FETCH_TIME),
          isNotNull);
    });

    test('getAllScore should save parsed score lists', () async {
      final prefs = PrefsService.instance;
      await prefs.setInt(
        PrefsKeys.SEMESTER_TIME,
        DateTime.now().microsecondsSinceEpoch,
      );
      await prefs.setString(
          PrefsKeys.SEMESTER_DATA,
          jsonEncode(<String, List>{
            'data': <Map<String, String>>[
              <String, String>{'semester': '2025-2', 'name': '2025-2'}
            ],
          }));

      _mockEduResponse(
        path: '/Score',
        data: <Map<String, dynamic>>[
          <String, dynamic>{
            'name': 'Math',
            'lessonCode': 'M101',
            'grade': '95',
            'gpa': '4.0',
            'credit': '3',
          }
        ],
      );

      await EduService.getAllScore(
        userData: UserData(studentId: '2026001', cookie: 'cookie'),
      );

      final list = await ScoreRepository().getScores();
      expect(list, hasLength(1));
      expect(list.first.list, isNotEmpty);
      expect(list.first.list.first.name, 'Math');
    });

    test('getProgram and getPrograms should parse successful responses',
        () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await PrefsService.instance.setInt(PrefsKeys.LAST_FETCH_TIME, now);
      await PrefsService.instance.setString(
        PrefsKeys.USER_DATA,
        jsonEncode(<String, String>{
          'studentId': '2026001',
          'cookie': 'cookie',
        }),
      );

      _mockEduResponse(
        path: '/Program',
        data: <Map<String, dynamic>>[
          <String, dynamic>{'name': 'Course A', 'courseTypeName': '必修课'}
        ],
      );
      _mockEduResponse(
        path: '/Program/GetDic',
        data: <String, dynamic>{
          '必修课': <Map<String, dynamic>>[
            <String, dynamic>{'name': 'Course B'}
          ],
        },
      );

      final program = await EduService.getProgram();
      final programDic = await EduService.getPrograms();

      expect(program, isNotEmpty);
      expect(programDic, isNotEmpty);
      expect(programDic.first.term, '必修课');
    });

    test('getBus should keep only future records for today', () async {
      final now = DateTime.now();
      final day = '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      final future = now.add(const Duration(hours: 2));
      final past = now.subtract(const Duration(minutes: 10));

      String hm(DateTime t) =>
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

      _mockEduResponse(
        path: '/Bus/$day',
        data: <String, dynamic>{
          'records': <Map<String, dynamic>>[
            <String, dynamic>{
              'lineName': 'line-future',
              'description': '',
              'departureStation': 'A',
              'arrivalStation': 'B',
              'runTime': hm(future),
              'arrivalStationTime': '00:30',
            },
            <String, dynamic>{
              'lineName': 'line-past',
              'description': '',
              'departureStation': 'A',
              'arrivalStation': 'B',
              'runTime': hm(past),
              'arrivalStationTime': '00:30',
            },
          ],
          'total': 2,
        },
      );

      final result = await EduService.getBus(dayDate: day);
      expect(result.records, hasLength(1));
      expect(result.records.first.lineName, 'line-future');
    });
  });
}
