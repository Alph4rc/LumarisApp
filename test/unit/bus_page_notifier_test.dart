import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/models/tile_configuration.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/models/bus_model.dart';
import 'package:ios_club_app/features/system/tile_service.dart';
import 'package:ios_club_app/state/bus_page_notifier.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer createContainer(List<Override> overrides) {
    final container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);
    return container;
  }

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PrefsService.init();
  });

  setUp(() async {
    await PrefsService.instance.clear();
  });

  group('BusPageNotifier', () {
    test('should_use_tile_configuration_for_show_bus_setting', () async {
      await PrefsService.instance.setStringList(PrefsKeys.TILES, [
        '电费',
        '校车',
        '饭卡',
      ]);
      await TileService.saveTileConfigurations(
        TileConfigurationList(
          configurations: const [
            TileConfiguration(id: '电费', order: 0, isVisible: true),
            TileConfiguration(id: '校车', order: 1, isVisible: false),
            TileConfiguration(id: '饭卡', order: 2, isVisible: true),
          ],
          lastModified: DateTime.now(),
        ),
      );

      final container = createContainer([
        busPageFetcherProvider.overrideWithValue(
          ({String? dayDate, bool forceRefresh = false}) async =>
              BusModel(total: 0, records: []),
        ),
      ]);

      container.read(busControllerProvider);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final state = container.read(busControllerProvider);
      expect(state.isShowBus, isFalse);
      expect(state.tiles, isNot(contains('校车')));
    });

    test('should_update_tile_configuration_when_toggling_show_bus', () async {
      await TileService.saveTileConfigurations(
        TileConfigurationList(
          configurations: const [
            TileConfiguration(id: '电费', order: 0, isVisible: true),
            TileConfiguration(id: '校车', order: 1, isVisible: false),
            TileConfiguration(id: '饭卡', order: 2, isVisible: true),
          ],
          lastModified: DateTime.now(),
        ),
      );

      final container = createContainer([
        busPageAutoLoadProvider.overrideWithValue(false),
      ]);
      final notifier = container.read(busControllerProvider.notifier);

      await notifier.toggleShowBus(true);

      var state = container.read(busControllerProvider);
      expect(await TileService.isTileVisible('校车'), isTrue);
      expect(state.isShowBus, isTrue);
      expect(state.tiles, contains('校车'));

      await notifier.toggleShowBus(false);

      state = container.read(busControllerProvider);
      expect(await TileService.isTileVisible('校车'), isFalse);
      expect(state.isShowBus, isFalse);
      expect(state.tiles, isNot(contains('校车')));
    });
  });
}
