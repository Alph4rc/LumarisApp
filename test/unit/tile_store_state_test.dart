import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/core/models/electric_data.dart';
import 'package:ios_club_app/features/education/models/bus_model.dart';
import 'package:ios_club_app/features/education/models/payment_model.dart';
import 'package:ios_club_app/features/system/tile_edit_controller.dart';
import 'package:ios_club_app/state/bus_tile_store.dart';
import 'package:ios_club_app/state/electricity_store.dart';
import 'package:ios_club_app/state/payment_store.dart';

class _SpyTileEditController extends TileEditController {
  int reloadCount = 0;

  @override
  // Avoid loading persisted tile configuration in this isolated spy.
  // ignore: must_call_super
  void onInit() {}

  @override
  Future<void> reload() async {
    reloadCount++;
  }
}

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
    PaymentStore.resetTestOverrides();
    ElectricityStore.resetTestOverrides();
    BusTileStore.resetTestOverrides();
  });

  tearDown(() {
    PaymentStore.resetTestOverrides();
    ElectricityStore.resetTestOverrides();
    BusTileStore.resetTestOverrides();
    Get.reset();
  });

  group('PaymentStore', () {
    test('should_set_login_error_when_student_id_is_empty', () async {
      PaymentStore.setTestOverrides(
        studentIdReader: () => true,
      );
      final store = PaymentStore();

      await store.loadData();

      expect(store.isLoading.value, isFalse);
      expect(store.errorMessage.value, '请先登录教务处账号');
      expect(store.records, isEmpty);
    });

    test('should_set_login_error_when_student_id_is_null', () async {
      PaymentStore.setTestOverrides(
        studentIdReader: () => false,
      );
      final store = PaymentStore();

      await store.loadData();

      expect(store.isLoading.value, isFalse);
      expect(store.errorMessage.value, '请先登录教务处账号');
      expect(store.records, isEmpty);
    });

    test('should_load_payment_records_and_tile_visibility_when_student_exists',
        () async {
      PaymentStore.setTestOverrides(
        studentIdReader: () => true,
        paymentDataFetcher: (cardNumber) async {
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
        },
        tileVisibilityReader: (tileId) async {
          expect(tileId, '饭卡');
          return true;
        },
      );
      final store = PaymentStore();

      await store.loadData();

      expect(store.isLoading.value, isFalse);
      expect(store.errorMessage.value, '');
      expect(store.records, hasLength(1));
      expect(store.totalRecharge.value, 1000);
      expect(store.isShowTile.value, isTrue);
    });

    test('should_toggle_tile_and_reload_tile_edit_controller', () async {
      final touchedTiles = <String>[];
      PaymentStore.setTestOverrides(
        tileAdder: (tileId) async => touchedTiles.add('add:$tileId'),
        tileRemover: (tileId) async => touchedTiles.add('remove:$tileId'),
      );
      final controller = Get.put<TileEditController>(_SpyTileEditController())
          as _SpyTileEditController;
      final store = PaymentStore();

      await store.toggleTileShow(true);
      await store.toggleTileShow(false);

      expect(store.isShowTile.value, isFalse);
      expect(touchedTiles, ['add:饭卡', 'remove:饭卡']);
      expect(controller.reloadCount, 2);
    });
  });

  group('ElectricityStore', () {
    test('should_load_electricity_value_weekly_data_and_visible_tile',
        () async {
      final weekly = [
        ElectricData(timestamp: DateTime(2026, 4, 27, 8), value: 1.5),
      ];
      ElectricityStore.setTestOverrides(
        electricityReader: () async => 23.5,
        weeklyReader: () async => weekly,
        tileVisibilityReader: (_) async => true,
      );
      final store = ElectricityStore();

      await store.loadElectricityData();

      expect(store.isLoading.value, isFalse);
      expect(store.hasData.value, isTrue);
      expect(store.electricity.value, 23.5);
      expect(store.tiles, contains('电费'));
      expect(store.weeklyData, weekly);
    });

    test('should_keep_has_data_false_when_electricity_value_is_missing',
        () async {
      ElectricityStore.setTestOverrides(
        electricityReader: () async => null,
        weeklyReader: () async => [],
        tileVisibilityReader: (_) async => false,
      );
      final store = ElectricityStore();

      await store.loadElectricityData();

      expect(store.isLoading.value, isFalse);
      expect(store.hasData.value, isFalse);
      expect(store.tiles, isNot(contains('电费')));
      expect(store.weeklyData, isEmpty);
    });

    test('should_refresh_electricity_without_touching_tile_visibility',
        () async {
      ElectricityStore.setTestOverrides(
        electricityReader: () async => 18.0,
        weeklyReader: () async => [
          ElectricData(timestamp: DateTime(2026, 4, 27, 9), value: 2),
        ],
      );
      final store = ElectricityStore();

      await store.refreshElectricityData();

      expect(store.isLoading.value, isFalse);
      expect(store.hasData.value, isTrue);
      expect(store.electricity.value, 18.0);
      expect(store.weeklyData.single.value, 2);
    });

    test('should_toggle_tile_and_reload_tile_edit_controller', () async {
      final touchedTiles = <String>[];
      ElectricityStore.setTestOverrides(
        tileAdder: (tileId) async => touchedTiles.add('add:$tileId'),
        tileRemover: (tileId) async => touchedTiles.add('remove:$tileId'),
      );
      final controller = Get.put<TileEditController>(_SpyTileEditController())
          as _SpyTileEditController;
      final store = ElectricityStore();

      await store.toggleTile('电费', true);
      await store.toggleTile('电费', false);

      expect(store.tiles, isNot(contains('电费')));
      expect(touchedTiles, ['add:电费', 'remove:电费']);
      expect(controller.reloadCount, 2);
    });
  });

  group('BusTileStore', () {
    test('should_load_old_bus_data_when_preference_is_false', () async {
      var oldCalls = 0;
      BusTileStore.setTestOverrides(
        preferenceReader: () async => false,
        oldBusFetcher: () async {
          oldCalls++;
          return _busModel(2);
        },
        newBusFetcher: () async => _busModel(9),
      );
      final store = BusTileStore();

      await store.loadBusData();

      expect(store.isLoading.value, isFalse);
      expect(store.useNewApi.value, isFalse);
      expect(store.busCount.value, 2);
      expect(oldCalls, 1);
    });

    test('should_load_new_bus_data_when_preference_is_true', () async {
      var newCalls = 0;
      BusTileStore.setTestOverrides(
        preferenceReader: () async => true,
        oldBusFetcher: () async => _busModel(2),
        newBusFetcher: () async {
          newCalls++;
          return _busModel(3);
        },
      );
      final store = BusTileStore();

      await store.loadBusData();

      expect(store.isLoading.value, isFalse);
      expect(store.useNewApi.value, isTrue);
      expect(store.busCount.value, 3);
      expect(newCalls, 1);
    });

    test('should_persist_preference_and_reload_when_toggling_new_api',
        () async {
      var savedPreference = false;
      BusTileStore.setTestOverrides(
        preferenceReader: () async => savedPreference,
        preferenceWriter: (value) async => savedPreference = value,
        oldBusFetcher: () async => _busModel(1),
        newBusFetcher: () async => _busModel(4),
      );
      final store = BusTileStore();

      await store.toggleUseNewApi(true);

      expect(savedPreference, isTrue);
      expect(store.useNewApi.value, isTrue);
      expect(store.busCount.value, 4);
      expect(store.isLoading.value, isFalse);
    });
  });
}
