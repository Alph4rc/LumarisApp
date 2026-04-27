import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/new_bus_api.dart';
import 'package:ios_club_app/features/education/models/bus_model.dart';

class _QueueAdapter implements HttpClientAdapter {
  _QueueAdapter(this._responses);

  final List<ResponseBody Function(RequestOptions options)> _responses;

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

ResponseBody _jsonBody(dynamic data, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(data),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  tearDown(resetNewBusApiForTest);

  group('getBusFromNewData', () {
    test('should_parse_new_platform_bus_records_when_response_has_plans',
        () async {
      late RequestOptions capturedOptions;
      final dio = Dio()
        ..httpClientAdapter = _QueueAdapter([
          (options) {
            capturedOptions = options;
            return _jsonBody({
              'data': {
                'dfBusPlans': [
                  {
                    'fscamp': '雁塔',
                    'frcamp': '',
                    'fecamp': '草堂',
                    'fstime': 3600,
                    'fbusNo': 'A1',
                  },
                  {
                    'fscamp': '雁塔',
                    'frcamp': '幸福林带',
                    'fecamp': '草堂',
                    'fstime': '7200',
                    'fbusNo': null,
                  },
                ],
              },
            });
          },
        ]);
      setNewBusApiDioFactoryForTest(() => dio);

      final model = await getBusFromNewData(time: '2026-04-27', loc: 'ALL');

      expect(capturedOptions.path, '/api/openapi/getDayBusPlans');
      expect(capturedOptions.data, {
        'type': 'ALL',
        'nowDay': '2026-04-27',
      });
      expect(model.total, 2);
      expect(model.records.first.lineName, '雁塔校区→草堂校区');
      expect(model.records.first.description, 'A1');
      expect(model.records.first.runTime, '08:00');
      expect(model.records.last.departureStation, '幸福林带校区');
      expect(model.records.last.description, '');
    });

    test('should_use_fallback_when_new_platform_returns_empty_plans', () async {
      final dio = Dio()
        ..httpClientAdapter = _QueueAdapter([
          (_) => _jsonBody({
                'data': {'dfBusPlans': <dynamic>[]},
              }),
        ]);
      setNewBusApiDioFactoryForTest(() => dio);
      setNewBusApiFallbackFetcherForTest(({String? dayDate}) async {
        expect(dayDate, '2026-04-27');
        return BusModel(
          total: 1,
          records: [
            BusItem(
              lineName: 'fallback',
              description: 'old',
              departureStation: 'A',
              arrivalStation: 'B',
              runTime: '10:00',
              arrivalStationTime: '01:00',
            ),
          ],
        );
      });

      final model = await getBusFromNewData(time: '2026-04-27');

      expect(model.total, 1);
      expect(model.records.single.lineName, 'fallback');
    });

    test('should_skip_plan_when_required_fields_are_missing', () async {
      final dio = Dio()
        ..httpClientAdapter = _QueueAdapter([
          (_) => _jsonBody({
                'data': {
                  'dfBusPlans': [
                    {'fscamp': '雁塔', 'fstime': 3600},
                    {'fscamp': '雁塔', 'fecamp': '草堂'},
                    {
                      'fscamp': '雁塔',
                      'fecamp': '草堂',
                      'fstime': 3600,
                    },
                  ],
                },
              }),
        ]);
      setNewBusApiDioFactoryForTest(() => dio);

      final model = await getBusFromNewData(time: '2026-04-27');

      expect(model.records, hasLength(1));
      expect(model.total, 1);
    });

    test('should_return_empty_model_when_request_fails', () async {
      final dio = Dio()
        ..httpClientAdapter = _QueueAdapter([
          (_) => throw DioException(
                requestOptions: RequestOptions(path: '/api'),
                type: DioExceptionType.connectionError,
              ),
        ]);
      setNewBusApiDioFactoryForTest(() => dio);

      final model = await getBusFromNewData(time: '2026-04-27');

      expect(model.records, isEmpty);
      expect(model.total, 0);
    });
  });
}
