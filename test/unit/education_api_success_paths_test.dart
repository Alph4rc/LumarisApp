import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ios_club_app/core/config/api_config.dart';
import 'package:ios_club_app/core/services/network_exception.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/services/app_api.dart';
import 'package:ios_club_app/features/education/services/bus_api.dart';
import 'package:ios_club_app/features/education/services/bus_service.dart';
import 'package:ios_club_app/features/education/services/edu_http_client.dart';
import 'package:ios_club_app/features/education/services/edu_http_client_manager.dart';
import 'package:ios_club_app/features/education/services/exam_api.dart';
import 'package:ios_club_app/features/education/services/info_api.dart';
import 'package:ios_club_app/features/education/services/login_service.dart';
import 'package:ios_club_app/features/education/services/payment_api.dart';
import 'package:ios_club_app/features/education/services/program_api.dart';
import 'package:ios_club_app/core/utils/request_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();
    tempDir = await Directory.systemTemp.createTemp(
      'education_api_success_paths_test_',
    );
    Hive.init(tempDir.path);
    await RequestCache.instance.initialize();
  });

  setUp(() async {
    await PrefsService.instance.clear();
    await RequestCache.instance.clear();
    EduHttpClientManager.resetForTest();
    LoginService.setLoginOverrideForTest(null);
    final manager = EduHttpClientManager.initialize();
    manager.updateSchoolConfig(
      const SchoolConfig(
        id: 'test',
        name: 'Test',
        eduApiBaseUrl: 'http://api.test',
        scheduleUrl: '',
      ),
    );
  });

  tearDown(() {
    LoginService.setLoginOverrideForTest(null);
    LoginService.resetClientForTest();
    EduHttpClientManager.resetForTest();
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('education API success paths', () {
    test('AppApi.getAppInfo should parse dynamic nested map releases',
        () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path != '/App/GetTag') {
              handler.next(options);
              return;
            }

            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <dynamic>[
                  Map<dynamic, dynamic>.from({
                    'id': 1,
                    'tag_name': 'v1.2.3',
                    'name': 'Release 1',
                    'body': 'Notes',
                    'author': Map<dynamic, dynamic>.from({
                      'id': 10,
                      'name': 'Alice',
                    }),
                    'created_at': '2026-05-06T00:00:00Z',
                    'assets': <dynamic>[
                      Map<dynamic, dynamic>.from({
                        'browser_download_url':
                            'https://downloads.example.com/app.apk',
                        'name': 'app-release.apk',
                      }),
                    ],
                  }),
                ],
              ),
            );
          },
        ),
      );

      final releases = await AppApi.getAppInfo();

      expect(releases, hasLength(1));
      expect(releases.single.author?.name, 'Alice');
      expect(
        releases.single.assets?.single.browserDownloadUrl,
        'https://downloads.example.com/app.apk',
      );
    });

    test('refresh-aware APIs should mark requests as bypassing cache',
        () async {
      final seenPaths = <String>{};
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(
              options.extra[CacheInterceptor.bypassCacheKey],
              isTrue,
              reason: 'Expected ${options.path} to bypass request cache',
            );
            seenPaths.add(options.path);

            dynamic data;
            switch (options.path) {
              case '/Info/Completion':
                data = <Map<String, dynamic>>[];
              case '/Exam':
                data = <String, dynamic>{
                  'exams': <Map<String, dynamic>>[],
                  'canClick': false,
                  'error': null,
                };
              case '/Program':
                data = <Map<String, dynamic>>[];
              case '/Program/GetDic':
                data = <String, dynamic>{};
              case '/Bus/2026-04-27':
                data = <String, dynamic>{'records': <dynamic>[], 'total': 0};
              default:
                fail('Unexpected path ${options.path}');
            }

            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: data,
              ),
            );
          },
        ),
      );

      await InfoApi.getInfoCompletion(forceRefresh: true);
      await ExamApi.getExam('2026001', forceRefresh: true);
      await ProgramApi.getProgram('2026001', forceRefresh: true);
      await ProgramApi.getProgramDic('2026001', forceRefresh: true);
      await BusApi.getBus(dayDate: '2026-04-27', forceRefresh: true);

      expect(seenPaths, {
        '/Info/Completion',
        '/Exam',
        '/Program',
        '/Program/GetDic',
        '/Bus/2026-04-27',
      });
    });

    test('BusApi.getBusNewData should pass time and loc query parameters',
        () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/Bus/NewData/2026-04-27');
            expect(options.queryParameters, {'loc': '雁塔'});
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'records': [
                    {
                      'lineName': '雁塔-草堂',
                      'description': 'A1',
                      'departureStation': '雁塔',
                      'arrivalStation': '草堂',
                      'runTime': '10:00',
                      'arrivalStationTime': '01:00',
                    }
                  ],
                  'total': 1,
                },
              ),
            );
          },
        ),
      );

      final model = await BusApi.getBusNewData('2026-04-27', loc: '雁塔');

      expect(model.records, hasLength(1));
      expect(model.records.single.description, 'A1');
    });

    test('BusApi.getBusOldData should pass isShow query parameter', () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/Bus/OldData/2026-04-27');
            expect(options.queryParameters, {'isShow': true});
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: {'records': <dynamic>[], 'total': 0},
              ),
            );
          },
        ),
      );

      final model = await BusApi.getBusOldData('2026-04-27', isShow: true);

      expect(model.records, isEmpty);
      expect(model.total, 0);
    });

    test('PaymentApi should parse raw payment and turnover responses',
        () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == '/Payment/card-1') {
              handler.resolve(
                Response<dynamic>(
                  requestOptions: options,
                  statusCode: 200,
                  data: 'card-bound',
                ),
              );
              return;
            }
            if (options.path == '/Payment/card-1/turnover') {
              handler.resolve(
                Response<dynamic>(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'records': [
                      {
                        'turnoverType': '充值',
                        'datetimeStr': '2026-04-27 10:00:00',
                        'resume': '测试',
                        'tranamt': '1000',
                      }
                    ],
                    'total': '1000',
                  },
                ),
              );
              return;
            }
            handler.next(options);
          },
        ),
      );

      final raw = await PaymentApi.getPayment('card-1');
      final turnover = await PaymentApi.getPaymentTurnover('card-1');

      expect(raw.value, 'card-bound');
      expect(turnover.payments.single.amount, 1000);
      expect(turnover.total, 1000);
    });

    test('PaymentApi.getPaymentTurnover should throw on invalid response',
        () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: 'not-json',
              ),
            );
          },
        ),
      );

      expect(
        () => PaymentApi.getPaymentTurnover('card-1'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('LoginService should parse map and string responses', () async {
      final client = EduHttpClient(baseUrl: 'http://api.test');
      var call = 0;
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            call++;
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: call == 1
                    ? {'success': true, 'studentId': '2026001'}
                    : jsonEncode({'success': true, 'studentId': '2026002'}),
              ),
            );
          },
        ),
      );
      LoginService.setClientForTest(client);

      final mapResult = await LoginService.login('u1', 'p1');
      final stringResult = await LoginService.login('u2', 'p2');

      expect(mapResult['studentId'], '2026001');
      expect(stringResult['studentId'], '2026002');
    });

    test('LoginService should wrap invalid response as NetworkException',
        () async {
      final client = EduHttpClient(baseUrl: 'http://api.test');
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <dynamic>[],
              ),
            );
          },
        ),
      );
      LoginService.setClientForTest(client);

      expect(
        () => LoginService.login('u', 'p'),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('BusService', () {
    test('should_filter_past_bus_records_for_today', () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'records': [
                    {
                      'lineName': 'past',
                      'description': '',
                      'departureStation': 'A',
                      'arrivalStation': 'B',
                      'runTime': '00:00:00',
                      'arrivalStationTime': '01:00',
                    },
                    {
                      'lineName': 'future',
                      'description': '',
                      'departureStation': 'A',
                      'arrivalStation': 'B',
                      'runTime': '23:59:00',
                      'arrivalStationTime': '01:00',
                    },
                  ],
                  'total': 2,
                },
              ),
            );
          },
        ),
      );

      final model = await BusService.getBus();

      expect(model.records.map((item) => item.lineName), ['future']);
    });

    test('should_not_filter_records_for_explicit_non_today_date', () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'records': [
                    {
                      'lineName': 'early',
                      'description': '',
                      'departureStation': 'A',
                      'arrivalStation': 'B',
                      'runTime': '06:00:00',
                      'arrivalStationTime': '01:00',
                    },
                  ],
                  'total': 1,
                },
              ),
            );
          },
        ),
      );

      final model = await BusService.getBus(dayDate: '2099-01-01');

      expect(model.records, hasLength(1));
      expect(model.records.single.lineName, 'early');
    });

    test('should_return_empty_model_when_bus_api_fails', () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response<dynamic>(
                  requestOptions: options,
                  statusCode: 500,
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      final model = await BusService.getBus();

      expect(model.records, isEmpty);
      expect(model.total, 0);
    });
  });
}
