import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/club/models/api_response.dart';
import 'package:ios_club_app/features/club/utils/api_response_helper.dart';

void main() {
  Map<String, dynamic> _ok(dynamic data) => {
        'code': 200,
        'errorCode': 0,
        'message': 'ok',
        'detail': null,
        'data': data,
      };

  group('ApiResponseHelper parseSingleObject', () {
    test('should_parse_single_object_from_map', () {
      final result = ApiResponseHelper.parseSingleObject<Map<String, dynamic>>(
        _ok({'name': 'alice'}),
        (json) => json,
      );

      expect(result, isNotNull);
      expect(result!['name'], 'alice');
    });

    test('should_return_null_on_failed_response', () {
      final result = ApiResponseHelper.parseSingleObject<Map<String, dynamic>>(
        {
          'code': 500,
          'errorCode': 1,
          'message': 'failed',
          'data': {'name': 'alice'},
        },
        (json) => json,
      );

      expect(result, isNull);
    });
  });

  group('ApiResponseHelper parseList', () {
    test('should_parse_list_from_json_string', () {
      final jsonString =
          '{"code":200,"errorCode":0,"message":"ok","data":[{"id":1},{"id":2}]}';

      final result = ApiResponseHelper.parseList<Map<String, dynamic>>(
        jsonString,
        (json) => json,
      );

      expect(result, hasLength(2));
      expect(result!.first['id'], 1);
      expect(result.last['id'], 2);
    });

    test('should_return_null_when_input_not_map_or_json', () {
      final result = ApiResponseHelper.parseList<Map<String, dynamic>>(
        123,
        (json) => json,
      );

      expect(result, isNull);
    });
  });

  group('ApiResponseHelper scalar parsing', () {
    test('should_parse_string_when_success', () {
      final value = ApiResponseHelper.parseString(_ok('jwt-token'));
      expect(value, 'jwt-token');
    });

    test('should_parse_bool_and_fallback_false', () {
      final ok = ApiResponseHelper.parseBool(_ok(true));
      final fallback = ApiResponseHelper.parseBool(_ok(null));
      final failed = ApiResponseHelper.parseBool({
        'code': 500,
        'errorCode': 1,
        'message': 'no',
        'data': true,
      });

      expect(ok, isTrue);
      expect(fallback, isFalse);
      expect(failed, isFalse);
    });

    test('should_parse_raw_generic_value', () {
      final raw = ApiResponseHelper.parseRaw<List<dynamic>>(_ok([1, 2, 3]));

      expect(raw, [1, 2, 3]);
    });
  });

  group('ApiResponseHelper getApiResponse', () {
    test('should_get_api_response_with_fromJsonT', () {
      final response = ApiResponseHelper.getApiResponse<int>(
        _ok('42'),
        fromJsonT: (data) => int.parse(data.toString()),
      );

      expect(response, isNotNull);
      expect(response!.isSuccess, isTrue);
      expect(response.data, 42);
    });

    test('should_return_null_on_invalid_json_string', () {
      final response = ApiResponseHelper.getApiResponse<Map<String, dynamic>>(
        'not-json',
      );

      expect(response, isNull);
    });
  });

  test('ApiResponse model should expose errorMessage and hasError correctly',
      () {
    final response = ApiResponse<String>(
      code: 400,
      errorCode: 1001,
      message: 'bad request',
      detail: 'invalid user',
      data: null,
    );

    expect(response.isSuccess, isFalse);
    expect(response.hasError, isTrue);
    expect(response.errorMessage, 'invalid user');
    expect(response.toJson()['code'], 400);
  });
}
