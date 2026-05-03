import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/services/electricity_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const launcherChannel = MethodChannel('plugins.flutter.io/url_launcher');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(launcherChannel, null);
  });

  group('ElectricityService', () {
    test('should_parse_balance_from_html_and_persist_url', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: '<html><body>充值余额：¥12.5</body></html>',
              ),
            );
          },
        ),
      );
      final service = ElectricityService(dio: dio);

      final value =
          await service.fetchCurrentBalance(url: 'https://example.com/e');

      expect(value, 12.5);
      expect(
        PrefsService.instance.getString(PrefsKeys.ELECTRICITY_URL),
        'https://example.com/e',
      );
    });

    test('should_return_null_on_non_200_response', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 500,
                data: 'err',
              ),
            );
          },
        ),
      );
      final service = ElectricityService(dio: dio);

      final value =
          await service.fetchCurrentBalance(url: 'https://example.com/e');

      expect(value, isNull);
    });

    test('should_return_null_when_balance_is_invalid', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: '<html><body>充值余额：¥N/A</body></html>',
              ),
            );
          },
        ),
      );
      final service = ElectricityService(dio: dio);

      final value =
          await service.fetchCurrentBalance(url: 'https://example.com/e');

      expect(value, isNull);
    });

    test('should_return_null_when_url_is_empty', () async {
      await PrefsService.instance.remove(PrefsKeys.ELECTRICITY_URL);
      final service = ElectricityService();

      final value = await service.fetchCurrentBalance(url: '');

      expect(value, isNull);
    });

    test('should_return_null_on_request_failure', () async {
      final service = ElectricityService();

      final value =
          await service.fetchCurrentBalance(url: 'http://127.0.0.1:1/x');

      expect(value, isNull);
    });

    test('should_return_empty_weekly_data_when_url_missing', () async {
      await PrefsService.instance.remove(PrefsKeys.ELECTRICITY_URL);
      final service = ElectricityService();

      final list = await service.fetchWeeklyData();

      expect(list, isEmpty);
    });

    test('should_parse_and_aggregate_hourly_weekly_data', () async {
      await PrefsService.instance
          .setString(PrefsKeys.ELECTRICITY_URL, 'https://x/wxAccount?id=1');
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: '''
<table>
  <tr><td>1</td><td>2026/03/02 10:00</td><td>1.5</td></tr>
  <tr><td>2</td><td>2026/03/02 10:30</td><td>0.5</td></tr>
  <tr><td>3</td><td>2026/03/02 11:00</td><td>2.0</td></tr>
</table>
''',
              ),
            );
          },
        ),
      );
      final service = ElectricityService(dio: dio);

      final list = await service.fetchWeeklyData();

      expect(list, hasLength(2));
      expect(list[0].value, 2.0);
      expect(list[1].value, 2.0);
      expect(list[0].timestamp.hour, 10);
      expect(list[1].timestamp.hour, 11);
    });

    test('should_build_recharge_url_from_saved_source_url', () async {
      await PrefsService.instance
          .setString(PrefsKeys.ELECTRICITY_URL, 'https://x/wxAccount?id=1');
      final service = ElectricityService();

      final rechargeUrl = await service.getRechargeUrl();

      expect(rechargeUrl, 'https://x/wxCharge?id=1');
    });

    test('should_prefer_wechat_url_scheme_when_available', () async {
      final launched = <String>[];
      await PrefsService.instance.setString(
          PrefsKeys.ELECTRICITY_URL, 'https://example.com/wxAccount');
      final service = ElectricityService();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(launcherChannel, (call) async {
        final url = (call.arguments is Map)
            ? (call.arguments['url'] as String? ?? '')
            : call.arguments.toString();
        if (call.method == 'canLaunch' || call.method == 'canLaunchUrl') {
          return url.startsWith('weixin://');
        }
        if (call.method == 'launch' || call.method == 'launchUrl') {
          launched.add(url);
          return true;
        }
        return null;
      });

      await service.openRechargePage();

      expect(launched.single, startsWith('weixin://dl/business/'));
    });

    test('should_fallback_to_browser_when_wechat_is_unavailable', () async {
      final launched = <String>[];
      await PrefsService.instance.setString(
          PrefsKeys.ELECTRICITY_URL, 'https://example.com/wxAccount');
      final service = ElectricityService();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(launcherChannel, (call) async {
        final url = (call.arguments is Map)
            ? (call.arguments['url'] as String? ?? '')
            : call.arguments.toString();
        if (call.method == 'canLaunch' || call.method == 'canLaunchUrl') {
          return url.startsWith('http');
        }
        if (call.method == 'launch' || call.method == 'launchUrl') {
          launched.add(url);
          return true;
        }
        return null;
      });

      await service.openRechargePage();

      expect(launched.single, 'https://example.com/wxCharge');
    });

    test('should_throw_when_no_launcher_is_available', () async {
      await PrefsService.instance.setString(
          PrefsKeys.ELECTRICITY_URL, 'https://example.com/wxAccount');
      final service = ElectricityService();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(launcherChannel, (call) async {
        if (call.method == 'canLaunch' || call.method == 'canLaunchUrl') {
          return false;
        }
        return null;
      });

      await expectLater(
        service.openRechargePage,
        throwsA(isA<String>()),
      );
    });
  });
}
