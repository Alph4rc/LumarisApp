import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ios_club_app/core/services/hive_manager.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/request_cache.dart';
import 'package:ios_club_app/features/education/services/education_cache_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'education_cache_service_test_',
    );
    Hive.init(tempDir.path);
    await Hive.openBox(HiveManager.courseBoxName);
    await Hive.openBox(HiveManager.scoreBoxName);
    await Hive.openBox(HiveManager.requestCacheBoxName);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();
    await RequestCache.instance.initialize();
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('should keep login state when clearSession is false', () async {
    final prefs = PrefsService.instance;
    await prefs.setString(PrefsKeys.USER_DATA, '{"studentId":"2026001"}');
    await prefs.setInt(PrefsKeys.LAST_FETCH_TIME, 123);
    await prefs.setString(PrefsKeys.SEMESTER_DATA, '{"data":[]}');

    await EducationCacheService.clearEduCache(clearSession: false);

    expect(prefs.getString(PrefsKeys.USER_DATA), isNotNull);
    expect(prefs.getInt(PrefsKeys.LAST_FETCH_TIME), 123);
    expect(prefs.getString(PrefsKeys.SEMESTER_DATA), isNull);
  });

  test('should remove login state when clearSession is true', () async {
    final prefs = PrefsService.instance;
    await prefs.setString(PrefsKeys.USER_DATA, '{"studentId":"2026001"}');
    await prefs.setInt(PrefsKeys.LAST_FETCH_TIME, 123);
    await prefs.setString(PrefsKeys.SEMESTER_DATA, '{"data":[]}');

    await EducationCacheService.clearEduCache();

    expect(prefs.getString(PrefsKeys.USER_DATA), isNull);
    expect(prefs.getInt(PrefsKeys.LAST_FETCH_TIME), isNull);
    expect(prefs.getString(PrefsKeys.SEMESTER_DATA), isNull);
  });
}
