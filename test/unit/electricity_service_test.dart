import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/models/electric_data.dart';
import 'package:ios_club_app/core/services/network_exception.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/services/electricity_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const launcherChannel = MethodChannel('plugins.flutter.io/url_launcher');

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();
    await PrefsService.instance.clear();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(launcherChannel, null);
  });

  group('ElectricityService', () {
    test('should_delegate_balance_request_with_url_and_persist_it', () async {
      String? receivedUrl;
      final service = ElectricityService(
        balanceReader: ({String? url}) async {
          receivedUrl = url;
          return 12.5;
        },
      );

      final value =
          await service.fetchCurrentBalance(url: 'https://example.com/e');

      expect(value, 12.5);
      expect(receivedUrl, 'https://example.com/e');
      expect(
        PrefsService.instance.getString(PrefsKeys.ELECTRICITY_URL),
        'https://example.com/e',
      );
    });

    test('should_use_cached_url_when_balance_request_has_no_input', () async {
      String? receivedUrl;
      await PrefsService.instance.setString(
        PrefsKeys.ELECTRICITY_URL,
        'https://cached.example.com/e',
      );
      final service = ElectricityService(
        balanceReader: ({String? url}) async {
          receivedUrl = url;
          return 9.5;
        },
      );

      final value = await service.fetchCurrentBalance();

      expect(value, 9.5);
      expect(receivedUrl, 'https://cached.example.com/e');
    });

    test('should_return_null_when_balance_request_has_no_input_and_no_cache',
        () async {
      var called = false;
      final service = ElectricityService(
        balanceReader: ({String? url}) async {
          called = true;
          return 1.0;
        },
      );

      final value = await service.fetchCurrentBalance();

      expect(value, isNull);
      expect(called, isFalse);
    });

    test('should_return_null_when_balance_reader_throws', () async {
      final service = ElectricityService(
        balanceReader: ({String? url}) async {
          throw NetworkException('boom', 500);
        },
      );

      final value = await service.fetchCurrentBalance(url: 'bad-url');

      expect(value, isNull);
    });

    test('should_delegate_weekly_data_request_with_cached_url', () async {
      String? receivedUrl;
      await PrefsService.instance.setString(
        PrefsKeys.ELECTRICITY_URL,
        'https://cached.example.com/e',
      );
      final expected = [
        ElectricData(timestamp: DateTime(2026, 3, 2, 10), value: 2.0),
        ElectricData(timestamp: DateTime(2026, 3, 2, 11), value: 1.0),
      ];
      final service = ElectricityService(
        weeklyDataReader: ({String? url}) async {
          receivedUrl = url;
          return expected;
        },
      );

      final list = await service.fetchWeeklyData();

      expect(receivedUrl, 'https://cached.example.com/e');
      expect(list, hasLength(2));
      expect(list[0].value, 2.0);
      expect(list[1].timestamp.hour, 11);
    });

    test('should_delegate_recharge_url_request_with_cached_url', () async {
      String? receivedUrl;
      await PrefsService.instance.setString(
        PrefsKeys.ELECTRICITY_URL,
        'https://cached.example.com/e',
      );
      final service = ElectricityService(
        rechargeUrlReader: ({String? url}) async {
          receivedUrl = url;
          return 'https://x/wxCharge?id=1';
        },
      );

      final rechargeUrl = await service.getRechargeUrl();

      expect(receivedUrl, 'https://cached.example.com/e');
      expect(rechargeUrl, 'https://x/wxCharge?id=1');
    });

    test('should_prefer_wechat_url_scheme_when_available', () async {
      final launched = <String>[];
      final service = ElectricityService(
        rechargeUrlReader: ({String? url}) async =>
            'https://example.com/wxCharge',
      );

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
      final service = ElectricityService(
        rechargeUrlReader: ({String? url}) async =>
            'https://example.com/wxCharge',
      );

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

    test('should_throw_when_recharge_url_is_missing', () async {
      final service = ElectricityService(
        rechargeUrlReader: ({String? url}) async => null,
      );

      await expectLater(
        service.openRechargePage,
        throwsA(isA<String>()),
      );
    });

    test('should_throw_when_no_launcher_is_available', () async {
      final service = ElectricityService(
        rechargeUrlReader: ({String? url}) async =>
            'https://example.com/wxCharge',
      );

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
