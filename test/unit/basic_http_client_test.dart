import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/basic/services/basic_http_client.dart';

void main() {
  group('BasicHttpClient', () {
    test('should normalize query parameters from url before request', () async {
      final client = BasicHttpClient();
      const specialPassword = r'p?%$&=+/';

      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.uri.path, '/api/v1/login');
            expect(options.queryParameters, <String, dynamic>{
              'username': 'club_user',
              'password': specialPassword,
            });

            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{'success': true},
              ),
            );
          },
        ),
      );

      final result = await client.get(
        '/api/v1/login?username=club_user&password=${Uri.encodeQueryComponent(specialPassword)}',
      );

      expect(result, <String, dynamic>{'success': true});
      client.dispose();
    });
  });
}
