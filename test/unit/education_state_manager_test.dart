import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/core/config/api_config.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/services/edu_http_client_manager.dart';
import 'package:ios_club_app/state/bus_tile_store.dart';
import 'package:ios_club_app/state/electricity_store.dart';
import 'package:ios_club_app/state/payment_store.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestBusTileStore extends BusTileStore {
  int loadBusDataCalled = 0;

  @override
  void onInit() {}

  @override
  Future<void> loadBusData() async {
    loadBusDataCalled++;
    isLoading.value = false;
  }
}

class _TestElectricityStore extends ElectricityStore {
  @override
  void onInit() {}

  @override
  Future<void> loadElectricityData() async {}
}

class _TestPaymentStore extends PaymentStore {
  @override
  void onInit() {}

  @override
  Future<void> loadData() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EduHttpClientManager', () {
    setUp(() async {
      Get.testMode = true;
      Get.reset();
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await PrefsService.init();
    });

    tearDown(() {
      Get.reset();
    });

    test('should initialize with default school url when settings is missing',
        () {
      Get.put(EduHttpClientManager());
      expect(
        EduHttpClientManager.instance.baseUrl,
        ApiConfig.getDefaultSchool().eduApiBaseUrl,
      );
    });

    test('should update school config and reinitialize back to settings value',
        () async {
      final settings = Get.put(SettingsStore());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(settings.schoolId, ApiConfig.defaultSchoolId);

      final manager = Get.put(EduHttpClientManager());
      final custom = SchoolConfig(
        id: 'xauat',
        name: '自定义',
        eduApiBaseUrl: 'https://custom.edu.example',
      );

      manager.updateSchoolConfig(custom);
      expect(EduHttpClientManager.instance.baseUrl, custom.eduApiBaseUrl);

      manager.reinitialize();
      expect(
        EduHttpClientManager.instance.baseUrl,
        ApiConfig.getDefaultSchool().eduApiBaseUrl,
      );
    });
  });

  group('State Stores', () {
    setUp(() async {
      Get.testMode = true;
      Get.reset();
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await PrefsService.init();
    });

    tearDown(() {
      Get.reset();
    });

    test('BusTileStore.toggleUseNewApi should persist flag and trigger reload',
        () async {
      final store = _TestBusTileStore();

      expect(store.useNewApi.value, isFalse);
      await store.toggleUseNewApi(true);

      expect(store.useNewApi.value, isTrue);
      expect(store.loadBusDataCalled, 1);
      expect(
        PrefsService.instance.getBool(PrefsKeys.USE_NEW_BUS_API),
        isTrue,
      );
    });

    test(
        'ElectricityStore.toggleTile should toggle visibility via tile service',
        () async {
      final store = _TestElectricityStore();

      await store.toggleTile('电费', false);
      expect(store.tiles.contains('电费'), isFalse);

      await store.toggleTile('电费', true);
      expect(store.tiles.contains('电费'), isTrue);
    });

    test('PaymentStore.toggleTileShow should switch local state and persist',
        () async {
      final store = _TestPaymentStore();

      await store.toggleTileShow(false);
      expect(store.isShowTile.value, isFalse);

      await store.toggleTileShow(true);
      expect(store.isShowTile.value, isTrue);
    });
  });
}
