import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/config/api_config.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/models/bus_model.dart';
import 'package:ios_club_app/features/education/services/edu_http_client_manager.dart';
import 'package:ios_club_app/features/system/tile_edit_controller.dart';
import 'package:ios_club_app/state/bus_tile_store.dart';
import 'package:ios_club_app/state/electricity_store.dart';
import 'package:ios_club_app/state/payment_store.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

BusModel _busModel(int count) {
  return BusModel(
    records: List.generate(
      count,
      (index) => BusItem(
        lineName: 'line-$index',
        description: '',
        departureStation: 'A',
        arrivalStation: 'B',
        runTime: '10:00',
        arrivalStationTime: '10:30',
      ),
    ),
    total: count,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer createContainer({List<Override> overrides = const []}) {
    final container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);
    return container;
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();
  });

  tearDown(EduHttpClientManager.resetForTest);

  group('EduHttpClientManager', () {
    test('should initialize with default school url when settings is missing',
        () {
      EduHttpClientManager.initialize();
      expect(
        EduHttpClientManager.instance.baseUrl,
        ApiConfig.getDefaultSchool().eduApiBaseUrl,
      );
    });

    test('should update school config and reinitialize back to settings value',
        () async {
      final container = createContainer();
      final settings = container.read(settingsStoreProvider.notifier);
      expect(settings.schoolId, ApiConfig.defaultSchoolId);

      final manager = EduHttpClientManager.initialize(
        school: settings.currentSchool,
      );
      final custom = SchoolConfig(
        id: 'xauat',
        name: '自定义',
        eduApiBaseUrl: 'https://custom.edu.example',
      );

      manager.updateSchoolConfig(custom);
      expect(EduHttpClientManager.instance.baseUrl, custom.eduApiBaseUrl);

      manager.reinitialize(school: settings.currentSchool);
      expect(
        EduHttpClientManager.instance.baseUrl,
        ApiConfig.getDefaultSchool().eduApiBaseUrl,
      );
    });
  });

  group('State Stores', () {
    test('BusTileStore.toggleUseNewApi should persist flag and trigger reload',
        () async {
      var loadCount = 0;
      final container = createContainer(overrides: [
        oldBusFetcherProvider.overrideWithValue(() async {
          loadCount++;
          return _busModel(1);
        }),
        newBusFetcherProvider.overrideWithValue(() async {
          loadCount++;
          return _busModel(2);
        }),
      ]);
      final store = container.read(busTileStoreProvider.notifier);

      expect(container.read(busTileStoreProvider).useNewApi, isFalse);
      await store.toggleUseNewApi(true);

      expect(container.read(busTileStoreProvider).useNewApi, isTrue);
      expect(loadCount, greaterThanOrEqualTo(1));
      expect(
        PrefsService.instance.getBool(PrefsKeys.USE_NEW_BUS_API),
        isTrue,
      );
    });

    test('ElectricityStore.toggleTile should update local tile list', () async {
      final touchedTiles = <String>[];
      final container = createContainer(overrides: [
        electricityTileAdderProvider.overrideWithValue(
            (tileId) async => touchedTiles.add('add:$tileId')),
        electricityTileRemoverProvider.overrideWithValue(
          (tileId) async => touchedTiles.add('remove:$tileId'),
        ),
        tileConfigurationReaderProvider.overrideWithValue(
          () async => throw StateError('not needed'),
        ),
      ]);
      final store = container.read(electricityStoreProvider.notifier);

      await store.toggleTile('电费', false);
      expect(container.read(electricityStoreProvider).tiles,
          isNot(contains('电费')));

      await store.toggleTile('电费', true);
      expect(container.read(electricityStoreProvider).tiles, contains('电费'));
      expect(touchedTiles, ['remove:电费', 'add:电费']);
    });

    test('PaymentStore.toggleTileShow should switch local state', () async {
      final touchedTiles = <String>[];
      final container = createContainer(overrides: [
        tileAdderProvider.overrideWithValue(
            (tileId) async => touchedTiles.add('add:$tileId')),
        tileRemoverProvider.overrideWithValue(
          (tileId) async => touchedTiles.add('remove:$tileId'),
        ),
        tileConfigurationReaderProvider.overrideWithValue(
          () async => throw StateError('not needed'),
        ),
      ]);
      final store = container.read(paymentStoreProvider.notifier);

      await store.toggleTileShow(false);
      expect(container.read(paymentStoreProvider).isShowTile, isFalse);

      await store.toggleTileShow(true);
      expect(container.read(paymentStoreProvider).isShowTile, isTrue);
      expect(touchedTiles, ['remove:饭卡', 'add:饭卡']);
    });
  });
}
