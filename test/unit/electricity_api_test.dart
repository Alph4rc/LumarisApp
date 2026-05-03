import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ios_club_app/core/config/api_config.dart';
import 'package:ios_club_app/core/services/network_exception.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/request_cache.dart';
import 'package:ios_club_app/features/education/services/edu_http_client_manager.dart';
import 'package:ios_club_app/features/education/services/electricity_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();
    tempDir = await Directory.systemTemp.createTemp('electricity_api_test_');
    Hive.init(tempDir.path);
    await RequestCache.instance.initialize();
  });

  setUp(() async {
    await PrefsService.instance.clear();
    await RequestCache.instance.clear();
    EduHttpClientManager.resetForTest();
    final manager = EduHttpClientManager.initialize();
    manager.updateSchoolConfig(
      const SchoolConfig(
        id: 'test',
        name: 'Test',
        eduApiBaseUrl: 'http://api.test',
      ),
    );
  });

  tearDown(() {
    EduHttpClientManager.resetForTest();
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('ElectricityApi', () {
    test('should_get_current_balance_with_optional_url', () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/Electricity');
            expect(options.queryParameters, <String, dynamic>{
              'url': 'https://example.com/wxAccount?id=1',
            });
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: 23.5,
              ),
            );
          },
        ),
      );

      final balance = await ElectricityApi.getCurrentBalance(
        url: 'https://example.com/wxAccount?id=1',
      );

      expect(balance, 23.5);
    });

    test('should_return_null_when_current_balance_is_not_found', () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response<dynamic>(
                  requestOptions: options,
                  statusCode: 404,
                  data: <String, dynamic>{'error': '未找到电费余额数据'},
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      final balance = await ElectricityApi.getCurrentBalance();

      expect(balance, isNull);
    });

    test('should_parse_weekly_data_list', () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/Electricity/WeeklyData');
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <Map<String, dynamic>>[
                  <String, dynamic>{
                    'timestamp': '2026-05-01T10:00:00',
                    'value': 1.5,
                  },
                  <String, dynamic>{
                    'Timestamp': '2026-05-01T11:00:00',
                    'Value': '2.0',
                  },
                ],
              ),
            );
          },
        ),
      );

      final data = await ElectricityApi.getWeeklyData();

      expect(data, hasLength(2));
      expect(data[0].timestamp, DateTime.parse('2026-05-01T10:00:00'));
      expect(data[0].value, 1.5);
      expect(data[1].timestamp, DateTime.parse('2026-05-01T11:00:00'));
      expect(data[1].value, 2.0);
    });

    test('should_throw_network_exception_on_invalid_weekly_data', () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: 'invalid',
              ),
            );
          },
        ),
      );

      expect(
        ElectricityApi.getWeeklyData,
        throwsA(isA<NetworkException>()),
      );
    });

    test('should_return_recharge_url', () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/Electricity/RechargeUrl');
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: 'https://example.com/wxCharge?id=1',
              ),
            );
          },
        ),
      );

      final rechargeUrl = await ElectricityApi.getRechargeUrl();

      expect(rechargeUrl, 'https://example.com/wxCharge?id=1');
    });

    test('should_return_null_when_recharge_url_is_not_found', () async {
      EduHttpClientManager.instance.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response<dynamic>(
                  requestOptions: options,
                  statusCode: 404,
                  data: <String, dynamic>{'error': '未找到电费充值地址'},
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      final rechargeUrl = await ElectricityApi.getRechargeUrl();

      expect(rechargeUrl, isNull);
    });
  });
}
