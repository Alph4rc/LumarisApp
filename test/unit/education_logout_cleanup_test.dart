import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/services/education_logout_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();
  });

  test('should clear account artifacts and keep tile layout', () async {
    final prefs = PrefsService.instance;

    await prefs.setString(PrefsKeys.CUSTOM_COURSE_DATA, '[]');
    await prefs.setString(PrefsKeys.GUEST_COURSE_DATA, '[]');
    await prefs.setString(PrefsKeys.ELECTRICITY_URL, 'https://example.com');
    await prefs.setString(
      PrefsKeys.ELECTRICITY_SUBSCRIPTION_EMAIL,
      'user@example.com',
    );
    await prefs.setString(PrefsKeys.PAYMENT_PASSWORD, '123456');
    await prefs.setString(PrefsKeys.COURSE_REMINDER_PLAN, '{}');
    await prefs.setString(PrefsKeys.LAST_REMIND_DATE, '2026-01-01');
    await prefs.setString(
      PrefsKeys.TILE_CONFIGURATIONS,
      '{"configurations":[]}',
    );

    await EducationLogoutService.clearAccountArtifacts();

    expect(prefs.getString(PrefsKeys.CUSTOM_COURSE_DATA), isNull);
    expect(prefs.getString(PrefsKeys.GUEST_COURSE_DATA), isNull);
    expect(prefs.getString(PrefsKeys.ELECTRICITY_URL), isNull);
    expect(prefs.getString(PrefsKeys.ELECTRICITY_SUBSCRIPTION_EMAIL), isNull);
    expect(prefs.getString(PrefsKeys.PAYMENT_PASSWORD), isNull);
    expect(prefs.getString(PrefsKeys.COURSE_REMINDER_PLAN), isNull);
    expect(prefs.getString(PrefsKeys.LAST_REMIND_DATE), isNull);

    // 磁贴布局按产品要求保留。
    expect(prefs.getString(PrefsKeys.TILE_CONFIGURATIONS), isNotNull);
  });
}
