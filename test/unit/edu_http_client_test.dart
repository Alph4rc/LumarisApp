import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ios_club_app/core/services/network_exception.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/services/edu_http_client.dart';
import 'package:ios_club_app/features/education/services/login_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _QueueAdapter implements HttpClientAdapter {
  _QueueAdapter(this._responses);

  final List<ResponseBody Function(RequestOptions)> _responses;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (_responses.isEmpty) {
      throw StateError('No queued response for ${options.path}');
    }
    return _responses.removeAt(0)(options);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final secureStore = <String, String>{};
  late Directory tempDir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();

    tempDir = await Directory.systemTemp.createTemp('edu_http_client_test_');
    Hive.init(tempDir.path);
    final box = await Hive.openBox('request_cache');
    await box.clear();
  });

  setUp(() async {
    secureStore.clear();
    await PrefsService.instance.clear();
    EduHttpClient.resetReloginStateForTest();
    LoginService.setLoginOverrideForTest(null);
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
    EduHttpClient.resetReloginStateForTest();
    LoginService.setLoginOverrideForTest(null);
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
      var reloggingCalled = 0;
      String? failedReason;
      final client = EduHttpClient(
        baseUrl: 'http://api.test',
        authStateCallbacks: AuthStateCallbacks(
          onRelogging: () => reloggingCalled++,
          onRelogFailed: (reason) => failedReason = reason,
        ),
      );

      client.dio.httpClientAdapter = _QueueAdapter([
        (_) => ResponseBody.fromString(
              '{"error":"unauthorized"}',
              401,
              headers: <String, List<String>>{
                Headers.contentTypeHeader: <String>['application/json']
              },
            ),
      ]);

      await expectLater(
        () => client.get('/need-auth'),
        throwsA(isA<AuthenticationException>()),
      );
      expect(reloggingCalled, 1);
      expect(failedReason, '账号或密码错误');

      client.dispose();
    });

    test('should skip relogin during cooldown window', () async {
      var loginCalled = 0;
      EduHttpClient.setLoginHandlerForTest((_, __) async {
        loginCalled++;
        return <String, dynamic>{'success': true};
      });
      EduHttpClient.setLastLoginFailTimeForTest(
        DateTime.now().millisecondsSinceEpoch,
      );

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

      await expectLater(
        () => client.get('/need-auth'),
        throwsA(isA<AuthenticationException>()),
      );
      expect(loginCalled, 0);

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

    test('should relogin and retry when adapter returns 401 then 200',
        () async {
      secureStore[PrefsKeys.USERNAME] = 'u1';
      secureStore[PrefsKeys.PASSWORD] = 'p1';
      EduHttpClient.setLoginHandlerForTest((_, __) async {
        return <String, dynamic>{
          'success': true,
          'studentId': '2026001',
          'cookie': 'cookie-after-login',
        };
      });

      final client = EduHttpClient(baseUrl: 'http://api.test');
      client.dio.httpClientAdapter = _QueueAdapter([
        (_) => ResponseBody.fromString(
              '{"error":"unauthorized"}',
              401,
              headers: <String, List<String>>{
                Headers.contentTypeHeader: <String>['application/json']
              },
            ),
        (options) {
          expect(options.headers['Cookie'], 'cookie-after-login');
          expect(options.headers['xauat'], 'cookie-after-login');
          return ResponseBody.fromString(
            '{"ok":true}',
            200,
            headers: <String, List<String>>{
              Headers.contentTypeHeader: <String>['application/json']
            },
          );
        },
      ]);

      final data = await client.get('/protected') as Map<String, dynamic>;
      expect(data['ok'], isTrue);

      client.dispose();
    });

    test('should keep auth failure when relogin succeeds but retry still fails',
        () async {
      secureStore[PrefsKeys.USERNAME] = 'u1';
      secureStore[PrefsKeys.PASSWORD] = 'p1';
      EduHttpClient.setLoginHandlerForTest((_, __) async {
        return <String, dynamic>{
          'success': true,
          'studentId': '2026001',
          'cookie': 'cookie-after-login',
        };
      });

      final client = EduHttpClient(baseUrl: 'http://api.test');
      client.dio.httpClientAdapter = _QueueAdapter([
        (_) => ResponseBody.fromString(
              '{"error":"unauthorized"}',
              401,
              headers: <String, List<String>>{
                Headers.contentTypeHeader: <String>['application/json']
              },
            ),
        (_) => throw DioException(
              requestOptions: RequestOptions(path: '/protected-fail'),
              type: DioExceptionType.connectionError,
              error: 'network down',
            ),
      ]);

      await expectLater(
        () => client.get('/protected-fail'),
        throwsA(isA<AuthenticationException>()),
      );

      client.dispose();
    });

    test('reLoginWithLockForTest should succeed and persist fresh cookie',
        () async {
      secureStore[PrefsKeys.USERNAME] = 'u1';
      secureStore[PrefsKeys.PASSWORD] = 'p1';
      EduHttpClient.setLoginHandlerForTest((_, __) async {
        return <String, dynamic>{
          'success': true,
          'studentId': '2026001',
          'cookie': 'fresh-cookie',
        };
      });

      final client = EduHttpClient(baseUrl: 'http://api.test');
      final ok = await client.reLoginWithLockForTest();
      expect(ok, isTrue);
      expect(
        PrefsService.instance.getString(PrefsKeys.USER_DATA),
        contains('fresh-cookie'),
      );
      client.dispose();
    });

    test('reLoginWithLockForTest should return false during cooldown',
        () async {
      EduHttpClient.setLastLoginFailTimeForTest(
        DateTime.now().millisecondsSinceEpoch,
      );
      final client = EduHttpClient(baseUrl: 'http://api.test');

      final ok = await client.reLoginWithLockForTest();
      expect(ok, isFalse);

      client.dispose();
    });

    test('reLoginWithLockForTest should return false when credentials missing',
        () async {
      final client = EduHttpClient(baseUrl: 'http://api.test');

      final ok = await client.reLoginWithLockForTest();
      expect(ok, isFalse);

      client.dispose();
    });

    test('reLoginWithLockForTest should return false when login handler throws',
        () async {
      secureStore[PrefsKeys.USERNAME] = 'u1';
      secureStore[PrefsKeys.PASSWORD] = 'p1';
      EduHttpClient.setLoginHandlerForTest((_, __) async {
        throw Exception('forced failure');
      });
      final client = EduHttpClient(baseUrl: 'http://api.test');

      final ok = await client.reLoginWithLockForTest();
      expect(ok, isFalse);

      client.dispose();
    });

    test(
        'reLoginWithLockForTest should use LoginService fallback when test handler unset',
        () async {
      secureStore[PrefsKeys.USERNAME] = 'u2';
      secureStore[PrefsKeys.PASSWORD] = 'p2';
      LoginService.setLoginOverrideForTest((_, __) async {
        return <String, dynamic>{
          'success': true,
          'studentId': '2026002',
          'cookie': 'fallback-cookie',
        };
      });
      final client = EduHttpClient(baseUrl: 'http://api.test');

      final ok = await client.reLoginWithLockForTest();
      expect(ok, isTrue);

      client.dispose();
    });

    test('should map post dio error into network exception', () async {
      final client = EduHttpClient(baseUrl: 'http://api.test');
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response<dynamic>(
                  requestOptions: options,
                  statusCode: 400,
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      await expectLater(
        () => client.post('/bad-post', data: <String, dynamic>{'k': 'v'}),
        throwsA(isA<NetworkException>()),
      );

      client.dispose();
    });
  });
}
