import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:hive/hive.dart';
import 'package:ios_club_app/core/config/api_config.dart';
import 'package:ios_club_app/core/services/network_exception.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/services/bus_api.dart';
import 'package:ios_club_app/features/education/services/bus_service.dart';
import 'package:ios_club_app/features/education/services/edu_http_client.dart';
import 'package:ios_club_app/features/education/services/edu_http_client_manager.dart';
import 'package:ios_club_app/features/education/services/login_service.dart';
import 'package:ios_club_app/features/education/services/payment_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();
    Get.testMode = true;
    tempDir = await Directory.systemTemp.createTemp(
      'education_api_success_paths_test_',
    );
    Hive.init(tempDir.path);
  });

  setUp(() async {
    await PrefsService.instance.clear();
    Get.reset();
    LoginService.setLoginOverrideForTest(null);
    final manager = Get.put(EduHttpClientManager());
    manager.updateSchoolConfig(
      const SchoolConfig(
        id: 'test',
        name: 'Test',
        eduApiBaseUrl: 'http://api.test',
      ),
    );
  });

  tearDown(() {
    LoginService.setLoginOverrideForTest(null);
    LoginService.resetClientForTest();
    Get.reset();
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('education API success paths', () {
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
