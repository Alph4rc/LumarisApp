import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/models/electric_data.dart';
import 'package:ios_club_app/core/models/tile_configuration.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/models/bus_model.dart';
import 'package:ios_club_app/features/education/models/payment_model.dart';
import 'package:ios_club_app/features/system/tile_edit_controller.dart';
import 'package:ios_club_app/state/bus_tile_store.dart';
import 'package:ios_club_app/state/electricity_store.dart';
import 'package:ios_club_app/state/payment_store.dart';
import 'package:ios_club_app/state/tile_store_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

BusModel _busModel(int count) {
  return BusModel(
    total: count,
    records: List.generate(
      count,
      (index) => BusItem(
        lineName: 'line-$index',
        description: '',
        departureStation: 'A',
        arrivalStation: 'B',
        runTime: '10:00',
        arrivalStationTime: '01:00',
      ),
    ),
  );
}

ProviderContainer _container(List<Override> overrides) {
  final container = ProviderContainer(overrides: [
    tileConfigurationReaderProvider.overrideWithValue(
      () async => TileConfigurationList.defaultConfig(),
    ),
    tileConfigurationWriterProvider.overrideWithValue((config) async {}),
    availableTilesReaderProvider.overrideWithValue(
      () => const ['电费', '校车', '饭卡'],
    ),
    tileStoreAutoLoadProvider.overrideWithValue(false),
    ...overrides,
  ]);
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();
  });

  group('PaymentStore', () {
    test('should_set_login_error_when_student_id_is_empty', () async {
      final container = _container([
        studentIsLoginReaderProvider.overrideWithValue(() => true),
        paymentStudentIdReaderProvider.overrideWithValue(() async => ''),
      ]);
      final store = container.read(paymentStoreProvider.notifier);

      await store.loadData();

      final state = container.read(paymentStoreProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, '请先登录教务处账号');
      expect(state.records, isEmpty);
    });

    test('should_set_login_error_when_student_id_is_null', () async {
      final container = _container([
        studentIsLoginReaderProvider.overrideWithValue(() => false),
      ]);
      final store = container.read(paymentStoreProvider.notifier);

      await store.loadData();

      final state = container.read(paymentStoreProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, '请先登录教务处账号');
      expect(state.records, isEmpty);
    });

    test('should_load_payment_records_and_tile_visibility_when_student_exists',
        () async {
      final container = _container([
        studentIsLoginReaderProvider.overrideWithValue(() => true),
        paymentStudentIdReaderProvider
            .overrideWithValue(() async => 'student-1'),
        paymentDataFetcherProvider.overrideWithValue((cardNumber) async {
          expect(cardNumber, 'student-1');
          return const PaymentData(
            [
              PaymentModel(
                turnoverType: '充值',
                datetimeStr: '2026-04-27 10:00:00',
                resume: '测试充值',
                amount: 1000,
              ),
            ],
            1000,
          );
        }),
        tileVisibilityReaderProvider.overrideWithValue((tileId) async {
          expect(tileId, '饭卡');
          return true;
        }),
      ]);
      final store = container.read(paymentStoreProvider.notifier);

      await store.loadData();

      final state = container.read(paymentStoreProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, '');
      expect(state.records, hasLength(1));
      expect(state.totalRecharge, 1000);
      expect(state.isShowTile, isTrue);
    });

    test('should_toggle_tile_and_reload_tile_edit_controller', () async {
      final touchedTiles = <String>[];
      final container = _container([
        tileAdderProvider.overrideWithValue(
            (tileId) async => touchedTiles.add('add:$tileId')),
        tileRemoverProvider.overrideWithValue(
          (tileId) async => touchedTiles.add('remove:$tileId'),
        ),
      ]);
      final store = container.read(paymentStoreProvider.notifier);

      await store.toggleTileShow(true);
      await store.toggleTileShow(false);

      expect(container.read(paymentStoreProvider).isShowTile, isFalse);
      expect(touchedTiles, ['add:饭卡', 'remove:饭卡']);
    });
  });

  group('ElectricityStore', () {
    test('should_load_electricity_value_weekly_data_and_visible_tile',
        () async {
      final weekly = [
        ElectricData(timestamp: DateTime(2026, 4, 27, 8), value: 1.5),
      ];
      final container = _container([
        electricityReaderProvider.overrideWithValue(() async => 23.5),
        electricityWeeklyReaderProvider.overrideWithValue(() async => weekly),
        electricityTileVisibilityReaderProvider
            .overrideWithValue((_) async => true),
      ]);
      final store = container.read(electricityStoreProvider.notifier);

      await store.loadElectricityData();

      final state = container.read(electricityStoreProvider);
      expect(state.isLoading, isFalse);
      expect(state.hasData, isTrue);
      expect(state.electricity, 23.5);
      expect(state.tiles, contains('电费'));
      expect(state.weeklyData, weekly);
    });

    test('should_keep_has_data_false_when_electricity_value_is_missing',
        () async {
      final container = _container([
        electricityReaderProvider.overrideWithValue(() async => null),
        electricityWeeklyReaderProvider.overrideWithValue(() async => []),
        electricityTileVisibilityReaderProvider
            .overrideWithValue((_) async => false),
      ]);
      final store = container.read(electricityStoreProvider.notifier);

      await store.loadElectricityData();

      final state = container.read(electricityStoreProvider);
      expect(state.isLoading, isFalse);
      expect(state.hasData, isFalse);
      expect(state.tiles, isNot(contains('电费')));
      expect(state.weeklyData, isEmpty);
    });

    test('should_refresh_electricity_without_touching_tile_visibility',
        () async {
      final container = _container([
        electricityReaderProvider.overrideWithValue(() async => 18.0),
        electricityWeeklyReaderProvider.overrideWithValue(
          () async => [
            ElectricData(timestamp: DateTime(2026, 4, 27, 9), value: 2),
          ],
        ),
      ]);
      final store = container.read(electricityStoreProvider.notifier);

      await store.refreshElectricityData();

      final state = container.read(electricityStoreProvider);
      expect(state.isLoading, isFalse);
      expect(state.hasData, isTrue);
      expect(state.electricity, 18.0);
      expect(state.weeklyData.single.value, 2);
    });

    test('should_toggle_tile_and_reload_tile_edit_controller', () async {
      final touchedTiles = <String>[];
      final container = _container([
        electricityTileAdderProvider.overrideWithValue(
            (tileId) async => touchedTiles.add('add:$tileId')),
        electricityTileRemoverProvider.overrideWithValue(
          (tileId) async => touchedTiles.add('remove:$tileId'),
        ),
      ]);
      final store = container.read(electricityStoreProvider.notifier);

      await store.toggleTile('电费', true);
      await store.toggleTile('电费', false);

      expect(container.read(electricityStoreProvider).tiles,
          isNot(contains('电费')));
      expect(touchedTiles, ['add:电费', 'remove:电费']);
    });
  });

  group('BusTileStore', () {
    test('should_load_old_bus_data_when_preference_is_false', () async {
      var oldCalls = 0;
      final container = _container([
        busPreferenceReaderProvider.overrideWithValue(() async => false),
        oldBusFetcherProvider.overrideWithValue(() async {
          oldCalls++;
          return _busModel(2);
        }),
        newBusFetcherProvider.overrideWithValue(() async => _busModel(9)),
      ]);
      final store = container.read(busTileStoreProvider.notifier);

      await store.loadBusData();

      final state = container.read(busTileStoreProvider);
      expect(state.isLoading, isFalse);
      expect(state.useNewApi, isFalse);
      expect(state.busCount, 2);
      expect(oldCalls, 1);
    });

    test('should_load_new_bus_data_when_preference_is_true', () async {
      var newCalls = 0;
      final container = _container([
        busPreferenceReaderProvider.overrideWithValue(() async => true),
        oldBusFetcherProvider.overrideWithValue(() async => _busModel(2)),
        newBusFetcherProvider.overrideWithValue(() async {
          newCalls++;
          return _busModel(3);
        }),
      ]);
      final store = container.read(busTileStoreProvider.notifier);

      await store.loadBusData();

      final state = container.read(busTileStoreProvider);
      expect(state.isLoading, isFalse);
      expect(state.useNewApi, isTrue);
      expect(state.busCount, 3);
      expect(newCalls, 1);
    });

    test('should_persist_preference_and_reload_when_toggling_new_api',
        () async {
      var savedPreference = false;
      final container = _container([
        busPreferenceReaderProvider
            .overrideWithValue(() async => savedPreference),
        busPreferenceWriterProvider
            .overrideWithValue((value) async => savedPreference = value),
        oldBusFetcherProvider.overrideWithValue(() async => _busModel(1)),
        newBusFetcherProvider.overrideWithValue(() async => _busModel(4)),
      ]);
      final store = container.read(busTileStoreProvider.notifier);

      await store.toggleUseNewApi(true);

      final state = container.read(busTileStoreProvider);
      expect(savedPreference, isTrue);
      expect(state.useNewApi, isTrue);
      expect(state.busCount, 4);
      expect(state.isLoading, isFalse);
    });
  });
}
