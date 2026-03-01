import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:hive/hive.dart';
import 'package:ios_club_app/core/services/auth_state_notifier.dart';
import 'package:ios_club_app/core/services/network_exception.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/services/edu_http_client.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final secureStore = <String, String>{};
  late Directory tempDir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();
    Get.testMode = true;

    tempDir = await Directory.systemTemp.createTemp('edu_http_client_test_');
    Hive.init(tempDir.path);
    final box = await Hive.openBox('request_cache');
    await box.clear();
  });

  setUp(() async {
    secureStore.clear();
    await PrefsService.instance.clear();
    Get.reset();
    final box = await Hive.openBox('request_cache');
    await box.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      final key = call.arguments['key'] as String?;
      switch (call.method) {
        case 'read':
          if (key == null) {
            return null;
          }
          return secureStore[key];
        case 'write':
          final value = call.arguments['value'] as String?;
          if (key != null && value != null) {
            secureStore[key] = value;
          }
          return null;
      }
      return null;
    });
  });

  tearDown(() {
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

  group('EduHttpClient', () {
    test('should update baseUrl in runtime', () {
      final client = EduHttpClient(baseUrl: 'http://api.old');
      expect(client.baseUrl, 'http://api.old');

      client.updateBaseUrl('http://api.new');
      expect(client.baseUrl, 'http://api.new');

      client.dispose();
    });

    test('should inject cookie headers and return get response data', () async {
      await PrefsService.instance.setString(
        PrefsKeys.USER_DATA,
        jsonEncode(<String, String>{
          'studentId': '2026001',
          'cookie': 'cookie-token',
        }),
      );

      final client = EduHttpClient(baseUrl: 'http://api.test');
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.headers['Cookie'], 'cookie-token');
            expect(options.headers['xauat'], 'cookie-token');
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{'ok': true},
              ),
            );
          },
        ),
      );

      final data = await client.get('/ping');
      expect(data, isA<Map>());
      expect((data as Map<String, dynamic>)['ok'], isTrue);

      client.dispose();
    });

    test('should return post response data', () async {
      final client = EduHttpClient(baseUrl: 'http://api.test');
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.method, 'POST');
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{'result': 'ok'},
              ),
            );
          },
        ),
      );

      final data = await client.post('/submit', data: <String, dynamic>{
        'name': 'codex',
      });
      expect(data, isA<Map>());
      expect((data as Map<String, dynamic>)['result'], 'ok');

      client.dispose();
    });

    test('should trigger relog failed state on 401 and throw auth exception',
        () async {
      Get.put(AuthStateNotifier());
      final client = EduHttpClient(baseUrl: 'http://api.test');

      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response<dynamic>(
                  requestOptions: options,
                  statusCode: 401,
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      expect(
        () => client.get('/need-auth'),
        throwsA(isA<AuthenticationException>()),
      );

      client.dispose();
    });

    test('should map 500 response into server exception', () async {
      final client = EduHttpClient(baseUrl: 'http://api.test');
      client.dio.interceptors.add(
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

      expect(
        () => client.get('/boom'),
        throwsA(isA<ServerException>()),
      );

      client.dispose();
    });
  });
}
