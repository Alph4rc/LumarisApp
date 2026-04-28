import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/core/config/api_config.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> _flushAsyncTasks() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  group('SettingsStore', () {
    setUp(() async {
      Get.testMode = true;
      Get.reset();
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await PrefsService.init();
    });

    tearDown(() {
      Get.reset();
    });

    test('should load default values when prefs is empty', () async {
      final store = Get.put(SettingsStore());
      await _flushAsyncTasks();

      expect(store.isRemind, isFalse);
      expect(store.remindTime, 15);
      expect(store.isShowTomorrow, isFalse);
      expect(store.pageIndex, 0);
      expect(store.enableHapticFeedback, isFalse);
      expect(store.updateIgnored, isFalse);
      expect(store.fontFamily, '');
      expect(store.showCourseGrid, isFalse);
      expect(store.todoRemindEnabled, isFalse);
      expect(store.scheduleBackground, '');
      expect(store.customBackgroundImage, '');
      expect(store.schoolId, ApiConfig.defaultSchoolId);
      expect(store.currentSchool.id, ApiConfig.defaultSchoolId);
    });

    test('should load existing values from prefs', () async {
      final prefs = PrefsService.instance;
      await prefs.setBool(PrefsKeys.IS_REMIND, true);
      await prefs.setInt(PrefsKeys.NOTIFICATION_TIME, 30);
      await prefs.setBool(PrefsKeys.IS_SHOW_TOMORROW, true);
      await prefs.setInt(PrefsKeys.PAGE_DATA, 2);
      await prefs.setBool(PrefsKeys.ENABLE_HAPTIC_FEEDBACK, true);
      await prefs.setBool(PrefsKeys.UPDATE_IGNORED, true);
      await prefs.setString(PrefsKeys.FONT_FAMILY, 'PingFang SC');
      await prefs.setBool(PrefsKeys.SHOW_COURSE_GRID, true);
      await prefs.setBool(PrefsKeys.TODO_REMIND_ENABLED, true);
      await prefs.setString(PrefsKeys.SCHEDULE_BACKGROUND, 'paper');
      await prefs.setString(PrefsKeys.CUSTOM_BACKGROUND_IMAGE, '/tmp/bg.jpg');
      await prefs.setString(PrefsKeys.SCHOOL_ID, 'xauat');

      final store = Get.put(SettingsStore());
      await _flushAsyncTasks();

      expect(store.isRemind, isTrue);
      expect(store.remindTime, 30);
      expect(store.isShowTomorrow, isTrue);
      expect(store.pageIndex, 2);
      expect(store.enableHapticFeedback, isTrue);
      expect(store.updateIgnored, isTrue);
      expect(store.fontFamily, 'PingFang SC');
      expect(store.showCourseGrid, isTrue);
      expect(store.todoRemindEnabled, isTrue);
      expect(store.scheduleBackground, 'paper');
      expect(store.customBackgroundImage, '/tmp/bg.jpg');
      expect(store.schoolId, 'xauat');
    });

    test('should update and persist common settings', () async {
      final store = Get.put(SettingsStore());
      await _flushAsyncTasks();

      await store.setIsRemind(true);
      await store.setRemindTime(45);
      await store.setIsShowTomorrow(true);
      await store.setPageIndex(1);
      await store.setEnableHapticFeedback(true);
      await store.setUpdateIgnored(true);
      await store.setFontFamily('Source Han Sans');
      await store.setShowCourseGrid(true);
      await store.setTodoRemindEnabled(true);
      await store.setScheduleBackground('wave');
      await store.setCustomBackgroundImage('/tmp/custom.png');

      final prefs = PrefsService.instance;
      expect(store.isRemind, isTrue);
      expect(store.remindTime, 45);
      expect(store.isShowTomorrow, isTrue);
      expect(store.pageIndex, 1);
      expect(store.enableHapticFeedback, isTrue);
      expect(store.updateIgnored, isTrue);
      expect(store.fontFamily, 'Source Han Sans');
      expect(store.showCourseGrid, isTrue);
      expect(store.todoRemindEnabled, isTrue);
      expect(store.scheduleBackground, 'wave');
      expect(store.customBackgroundImage, '/tmp/custom.png');

      expect(prefs.getBool(PrefsKeys.IS_REMIND), isTrue);
      expect(prefs.getInt(PrefsKeys.NOTIFICATION_TIME), 45);
      expect(prefs.getBool(PrefsKeys.IS_SHOW_TOMORROW), isTrue);
      expect(prefs.getInt(PrefsKeys.PAGE_DATA), 1);
      expect(prefs.getBool(PrefsKeys.ENABLE_HAPTIC_FEEDBACK), isTrue);
      expect(prefs.getBool(PrefsKeys.UPDATE_IGNORED), isTrue);
      expect(prefs.getString(PrefsKeys.FONT_FAMILY), 'Source Han Sans');
      expect(prefs.getBool(PrefsKeys.SHOW_COURSE_GRID), isTrue);
      expect(prefs.getBool(PrefsKeys.TODO_REMIND_ENABLED), isTrue);
      expect(prefs.getString(PrefsKeys.SCHEDULE_BACKGROUND), 'wave');
      expect(
        prefs.getString(PrefsKeys.CUSTOM_BACKGROUND_IMAGE),
        '/tmp/custom.png',
      );
    });

    test('should throw when setting invalid school id', () async {
      final store = Get.put(SettingsStore());
      await _flushAsyncTasks();

      await expectLater(
        store.setSchoolId('invalid-school'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should fallback currentSchool to default when school id is unknown',
        () async {
      final prefs = PrefsService.instance;
      await prefs.setString(PrefsKeys.SCHOOL_ID, 'unknown-school');
      final store = Get.put(SettingsStore());
      await _flushAsyncTasks();

      expect(store.schoolId, 'unknown-school');
      expect(store.currentSchool.id, ApiConfig.defaultSchoolId);
    });
  });
}
