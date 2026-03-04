import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/xauat_login.dart';

typedef _Step = void Function(
  RequestOptions options,
  RequestInterceptorHandler handler,
);

class _ScriptedInterceptor extends Interceptor {
  _ScriptedInterceptor(this.steps);

  final Queue<_Step> steps;
  final List<RequestOptions> seen = <RequestOptions>[];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    seen.add(options);
    if (steps.isEmpty) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: 'No scripted response',
          type: DioExceptionType.unknown,
        ),
      );
      return;
    }
    final step = steps.removeFirst();
    step(options, handler);
  }
}

Response<dynamic> _response(
  RequestOptions options, {
  int statusCode = 200,
  dynamic data = '',
  Map<String, List<String>> headers = const <String, List<String>>{},
  String? statusMessage,
}) {
  return Response<dynamic>(
    requestOptions: options,
    statusCode: statusCode,
    data: data,
    headers: Headers.fromMap(headers),
    statusMessage: statusMessage,
  );
}

void main() {
  group('XAUATLogin basic helpers', () {
    late XAUATLogin loginClient;

    setUp(() {
      loginClient = XAUATLogin();
    });

    tearDown(() {
      loginClient.dispose();
    });

    test('LoginTokenModel should use defaults and serialize', () {
      final token = LoginTokenModel();
      expect(token.eduCookie, '');
      expect(token.ssoCookie, '');
      expect(token.success, isTrue);
      expect(token.message, '');

      final custom = LoginTokenModel(
        eduCookie: 'edu',
        ssoCookie: 'sso',
        success: false,
        message: 'err',
      );
      expect(custom.toJson(), <String, dynamic>{
        'eduCookie': 'edu',
        'ssoCookie': 'sso',
        'success': false,
        'message': 'err',
      });
    });

    test('randomStringTest should honor length bounds', () {
      expect(loginClient.randomStringTest(0), isEmpty);
      expect(loginClient.randomStringTest(1).length, 1);
      expect(loginClient.randomStringTest(64).length, 64);
    });

    test('buildCookieStringTest should join cookies', () {
      expect(
        loginClient.buildCookieStringTest(<String, String>{'a': '1', 'b': '2'}),
        anyOf(<Matcher>[equals('a=1; b=2'), equals('b=2; a=1')]),
      );
      expect(loginClient.buildCookieStringTest(<String, String>{}), isEmpty);
    });
  });

  group('XAUATLogin scripted requests', () {
    test('login should return success and parse redirect cookies', () async {
      final steps = Queue<_Step>.from(<_Step>[
        (options, handler) {
          handler.resolve(
            _response(
              options,
              data: '''
<html><body>
<input name="lt" value="LT-1"/>
<input name="execution" value="EXE-1"/>
<input name="_eventId" value="submit"/>
<input id="pwdEncryptSalt" value="1234567890abcdef"/>
</body></html>
''',
              headers: <String, List<String>>{
                'set-cookie': <String>['JSESSIONID=sid1; Path=/']
              },
            ),
          );
        },
        (options, handler) {
          handler.resolve(
            _response(
              options,
              statusCode: 302,
              headers: <String, List<String>>{
                'set-cookie': <String>['CASTGC=tgc1; Path=/'],
                'location': <String>['https://swjw.xauat.edu.cn/redirect']
              },
            ),
          );
        },
        (options, handler) {
          handler.resolve(
            _response(
              options,
              headers: <String, List<String>>{
                'set-cookie': <String>['JSESSIONID=edu1; Path=/']
              },
            ),
          );
        },
      ]);

      final interceptor = _ScriptedInterceptor(steps);
      final dio = Dio()..interceptors.add(interceptor);
      final loginClient = XAUATLogin(dio: dio);

      final result = await loginClient.login('u1', 'p1');

      expect(result.success, isTrue);
      expect(result.eduCookie, contains('JSESSIONID=edu1'));
      expect(result.ssoCookie, contains('CASTGC=tgc1'));
      expect(result.message, '登录成功');

      expect(interceptor.seen.length, 3);
      expect(interceptor.seen[1].method, 'POST');
      expect(interceptor.seen[2].method, 'GET');
      loginClient.dispose();
    });

    test('login should map 401/403 to credential error', () async {
      final steps = Queue<_Step>.from(<_Step>[
        (options, handler) {
          handler.resolve(
            _response(
              options,
              data: '''
<html><body>
<input name="lt" value="LT-1"/>
<input name="execution" value="EXE-1"/>
</body></html>
''',
            ),
          );
        },
        (options, handler) {
          handler.resolve(_response(options, statusCode: 403));
        },
      ]);
      final dio = Dio()..interceptors.add(_ScriptedInterceptor(steps));
      final loginClient = XAUATLogin(dio: dio);

      final result = await loginClient.login('u2', 'bad');

      expect(result.success, isFalse);
      expect(result.message, contains('账号或密码错误'));
      loginClient.dispose();
    });

    test('login should parse server error message from html', () async {
      final steps = Queue<_Step>.from(<_Step>[
        (options, handler) {
          handler.resolve(
            _response(
              options,
              data: '''
<html><body>
<input name="lt" value="LT-1"/>
<input name="execution" value="EXE-1"/>
</body></html>
''',
            ),
          );
        },
        (options, handler) {
          handler.resolve(
            _response(
              options,
              statusCode: 418,
              data: '<span id="msg">bad state</span>',
            ),
          );
        },
      ]);
      final dio = Dio()..interceptors.add(_ScriptedInterceptor(steps));
      final loginClient = XAUATLogin(dio: dio);

      final result = await loginClient.login('u3', 'p3');

      expect(result.success, isFalse);
      expect(result.message, contains('bad state'));
      loginClient.dispose();
    });

    test('login should return catch-all error message on transport exception',
        () async {
      final steps = Queue<_Step>.from(<_Step>[
        (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              error: 'offline',
              type: DioExceptionType.connectionError,
            ),
          );
        },
      ]);
      final dio = Dio()..interceptors.add(_ScriptedInterceptor(steps));
      final loginClient = XAUATLogin(dio: dio);

      final result = await loginClient.login('u4', 'p4');

      expect(result.success, isFalse);
      expect(result.message, contains('登录出错'));
      loginClient.dispose();
    });

    test('loginFromSSO should return success and parse edu cookie', () async {
      final steps = Queue<_Step>.from(<_Step>[
        (options, handler) {
          handler.resolve(
            _response(
              options,
              statusCode: 200,
              headers: <String, List<String>>{
                'set-cookie': <String>['JSESSIONID=edu2; Path=/']
              },
            ),
          );
        },
      ]);

      final dio = Dio()..interceptors.add(_ScriptedInterceptor(steps));
      final loginClient = XAUATLogin(dio: dio);
      final result = await loginClient.loginFromSSO('CASTGC=abc');

      expect(result.success, isTrue);
      expect(result.eduCookie, contains('JSESSIONID=edu2'));
      expect(result.ssoCookie, 'CASTGC=abc');
      loginClient.dispose();
    });

    test('loginFromSSO should return failure on non-200 response', () async {
      final steps = Queue<_Step>.from(<_Step>[
        (options, handler) {
          handler.resolve(
            _response(
              options,
              statusCode: 500,
              statusMessage: 'Server error',
            ),
          );
        },
      ]);
      final dio = Dio()..interceptors.add(_ScriptedInterceptor(steps));
      final loginClient = XAUATLogin(dio: dio);

      final result = await loginClient.loginFromSSO('CASTGC=abc');
      expect(result.success, isFalse);
      expect(result.message, contains('SSO登录失败'));
      loginClient.dispose();
    });
  });
}
