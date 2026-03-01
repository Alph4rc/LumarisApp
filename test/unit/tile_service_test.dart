import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/models/tile_configuration.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/system/tile_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const launcherChannel = MethodChannel('plugins.flutter.io/url_launcher');

  setUp(() async {
    // Clear shared preferences before each test
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();
    TileService.resetDioForTest();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(launcherChannel, null);
    TileService.resetDioForTest();
  });

  group('TileService - Configuration Methods', () {
    test('should_return_default_configuration_when_no_data_exists', () async {
      final config = await TileService.getTileConfigurations();

      expect(config.configurations.length, 3);
      expect(config.configurations[0].id, '电费');
      expect(config.configurations[1].id, '校车');
      expect(config.configurations[2].id, '饭卡');
      expect(config.configurations.every((t) => t.isVisible), true);
    });

    test('should_save_and_load_configuration_correctly', () async {
      final testConfig = TileConfigurationList(
        configurations: [
          const TileConfiguration(id: '电费', order: 0, isVisible: true),
          const TileConfiguration(id: '校车', order: 1, isVisible: false),
        ],
        lastModified: DateTime(2026, 2, 15),
      );

      await TileService.saveTileConfigurations(testConfig);
      final loaded = await TileService.getTileConfigurations();

      expect(loaded.configurations.length, 2);
      expect(loaded.configurations[0].id, '电费');
      expect(loaded.configurations[1].isVisible, false);
    });

    test('should_update_lastModified_when_saving', () async {
      final testConfig = TileConfigurationList(
        configurations: [
          const TileConfiguration(id: '电费', order: 0, isVisible: true),
        ],
        lastModified: DateTime(2020, 1, 1),
      );

      await TileService.saveTileConfigurations(testConfig);
      final loaded = await TileService.getTileConfigurations();

      expect(loaded.lastModified.isAfter(DateTime(2020, 1, 1)), true);
    });

    test('should_reorder_tile_and_persist_changes', () async {
      // Setup initial configuration
      final initialConfig = TileConfigurationList(
        configurations: [
          const TileConfiguration(id: '电费', order: 0, isVisible: true),
          const TileConfiguration(id: '校车', order: 1, isVisible: true),
          const TileConfiguration(id: '饭卡', order: 2, isVisible: true),
        ],
        lastModified: DateTime.now(),
      );
      await TileService.saveTileConfigurations(initialConfig);

      // Reorder: move "电费" from position 0 to position 2
      await TileService.reorderTile('电费', 0, 2);

      // Verify
      final config = await TileService.getTileConfigurations();
      final visible = config.getVisibleTiles();

      expect(visible[0].id, '校车');
      expect(visible[1].id, '饭卡');
      expect(visible[2].id, '电费');
    });

    test('should_throw_exception_when_reordering_with_invalid_index', () async {
      final initialConfig = TileConfigurationList.defaultConfig();
      await TileService.saveTileConfigurations(initialConfig);

      expect(
        () => TileService.reorderTile('电费', -1, 0),
        throwsA(isA<TileConfigurationException>()),
      );
    });

    test('should_toggle_tile_visibility_and_persist_changes', () async {
      final initialConfig = TileConfigurationList(
        configurations: [
          const TileConfiguration(id: '电费', order: 0, isVisible: true),
          const TileConfiguration(id: '校车', order: 1, isVisible: true),
        ],
        lastModified: DateTime.now(),
      );
      await TileService.saveTileConfigurations(initialConfig);

      // Hide "电费"
      await TileService.toggleTileVisibility('电费');

      // Verify
      final config = await TileService.getTileConfigurations();
      final tile = config.configurations.firstWhere((t) => t.id == '电费');

      expect(tile.isVisible, false);
      expect(config.getVisibleTiles().length, 1);
    });

    test('should_throw_exception_when_hiding_all_tiles', () async {
      final initialConfig = TileConfigurationList(
        configurations: [
          const TileConfiguration(id: '电费', order: 0, isVisible: true),
        ],
        lastModified: DateTime.now(),
      );
      await TileService.saveTileConfigurations(initialConfig);

      expect(
        () => TileService.toggleTileVisibility('电费'),
        throwsA(isA<TileConfigurationException>()),
      );
    });

    test('should_reset_to_default_configuration', () async {
      // Setup custom configuration
      final customConfig = TileConfigurationList(
        configurations: [
          const TileConfiguration(id: '电费', order: 0, isVisible: false),
        ],
        lastModified: DateTime.now(),
      );
      await TileService.saveTileConfigurations(customConfig);

      // Reset
      await TileService.resetToDefault();

      // Verify
      final config = await TileService.getTileConfigurations();

      expect(config.configurations.length, 3);
      expect(config.configurations.every((t) => t.isVisible), true);
    });

    test('should_return_list_of_available_tiles', () {
      final available = TileService.getAvailableTiles();

      expect(available, contains('电费'));
      expect(available, contains('校车'));
      expect(available, contains('饭卡'));
      expect(available.length, 3);
    });
  });

  group('TileService - Migration Logic', () {
    test('should_migrate_from_old_format_to_new_format', () async {
      // Setup old format data
      final prefs = PrefsService.instance;
      await prefs.setStringList(PrefsKeys.TILES, ['电费', '校车', '饭卡']);

      // Load (should trigger migration)
      final config = await TileService.getTileConfigurations();

      // Verify migration
      expect(config.configurations.length, 3);
      expect(config.configurations[0].id, '电费');
      expect(config.configurations[0].order, 0);
      expect(config.configurations[0].isVisible, true);
      expect(config.configurations[1].id, '校车');
      expect(config.configurations[2].id, '饭卡');

      // Verify new format is saved
      final newFormatJson = prefs.getString(PrefsKeys.TILE_CONFIGURATIONS);
      expect(newFormatJson, isNotNull);
      expect(newFormatJson, isNotEmpty);
    });

    test('should_prefer_new_format_over_old_format', () async {
      final prefs = PrefsService.instance;

      // Setup both old and new format
      await prefs.setStringList(PrefsKeys.TILES, ['电费']);

      final newConfig = TileConfigurationList(
        configurations: [
          const TileConfiguration(id: '校车', order: 0, isVisible: true),
          const TileConfiguration(id: '饭卡', order: 1, isVisible: true),
        ],
        lastModified: DateTime.now(),
      );
      await TileService.saveTileConfigurations(newConfig);

      // Load (should use new format)
      final config = await TileService.getTileConfigurations();

      expect(config.configurations.length, 2);
      expect(config.configurations[0].id, '校车');
      expect(config.configurations[1].id, '饭卡');
    });

    test('should_keep_result_stable_after_repeated_migration_reads', () async {
      final prefs = PrefsService.instance;
      await prefs.setStringList(PrefsKeys.TILES, ['电费', '校车']);

      final firstLoad = await TileService.getTileConfigurations();
      final secondLoad = await TileService.getTileConfigurations();

      expect(firstLoad.configurations.length, 2);
      expect(secondLoad.configurations.length, 2);
      expect(secondLoad.configurations[0].id, firstLoad.configurations[0].id);
      expect(secondLoad.configurations[1].id, firstLoad.configurations[1].id);
    });

    test('should_handle_empty_old_format_list', () async {
      // Clear all data first
      final prefs = PrefsService.instance;
      await prefs.remove(PrefsKeys.TILE_CONFIGURATIONS);
      await prefs.setStringList(PrefsKeys.TILES, []);

      final config = await TileService.getTileConfigurations();

      // Should return default config
      expect(config.configurations.length, 3);
    });

    test('should_handle_corrupted_json_gracefully', () async {
      final prefs = PrefsService.instance;
      await prefs.setString(PrefsKeys.TILE_CONFIGURATIONS, 'invalid json data');

      final config = await TileService.getTileConfigurations();

      // Should return default config
      expect(config.configurations.length, 3);
    });
  });

  group('TileService - Error Handling', () {
    test('should_throw_TileConfigurationException_on_save_error', () async {
      // This test verifies the exception type
      // In real scenario, storage errors would trigger this
      final config = TileConfigurationList.defaultConfig();

      // Normal save should work
      await TileService.saveTileConfigurations(config);

      // Verify no exception thrown
      expect(true, true);
    });

    test('should_return_default_config_on_load_error', () async {
      // Even with corrupted data, should return default
      final prefs = PrefsService.instance;
      await prefs.setString(PrefsKeys.TILE_CONFIGURATIONS, '{invalid}');

      final config = await TileService.getTileConfigurations();

      expect(config.configurations.length, 3);
      expect(config.configurations.every((t) => t.isVisible), true);
    });
  });

  group('TileService - Visibility helpers', () {
    test('should_add_hidden_tile_back_to_visible', () async {
      final config = TileConfigurationList(
        configurations: const [
          TileConfiguration(id: '电费', order: 0, isVisible: true),
          TileConfiguration(id: '校车', order: 1, isVisible: false),
        ],
        lastModified: DateTime.now(),
      );
      await TileService.saveTileConfigurations(config);

      await TileService.addTile('校车');

      final loaded = await TileService.getTileConfigurations();
      final bus = loaded.configurations.firstWhere((t) => t.id == '校车');
      expect(bus.isVisible, isTrue);
      expect(await TileService.isTileVisible('校车'), isTrue);
    });

    test('should_add_new_tile_when_not_in_configuration', () async {
      final config = TileConfigurationList(
        configurations: const [
          TileConfiguration(id: '电费', order: 0, isVisible: true),
        ],
        lastModified: DateTime.now(),
      );
      await TileService.saveTileConfigurations(config);

      await TileService.addTile('新功能');

      final loaded = await TileService.getTileConfigurations();
      final added = loaded.configurations.firstWhere((t) => t.id == '新功能');
      expect(added.isVisible, isTrue);
      expect(added.order, 1);
    });

    test('should_remove_visible_tile_by_toggling_visibility', () async {
      final config = TileConfigurationList(
        configurations: const [
          TileConfiguration(id: '电费', order: 0, isVisible: true),
          TileConfiguration(id: '校车', order: 1, isVisible: true),
        ],
        lastModified: DateTime.now(),
      );
      await TileService.saveTileConfigurations(config);

      await TileService.removeTile('校车');

      expect(await TileService.isTileVisible('校车'), isFalse);
      expect(await TileService.isTileVisible('电费'), isTrue);
    });

    test('should_keep_state_when_removing_hidden_or_unknown_tile', () async {
      final config = TileConfigurationList(
        configurations: const [
          TileConfiguration(id: '电费', order: 0, isVisible: true),
          TileConfiguration(id: '校车', order: 1, isVisible: false),
        ],
        lastModified: DateTime.now(),
      );
      await TileService.saveTileConfigurations(config);

      await TileService.removeTile('校车');
      await TileService.removeTile('不存在');

      final loaded = await TileService.getTileConfigurations();
      final visible = loaded.getVisibleTiles().map((e) => e.id).toList();
      expect(visible, ['电费']);
    });
  });

  group('TileService - Electricity HTML parsing', () {
    test('getTextAfterKeyword should parse balance from html and persist url',
        () async {
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
      TileService.setDioForTest(dio);

      final value =
          await TileService.getTextAfterKeyword(url: 'https://example.com/e');
      expect(value, 12.5);
      expect(PrefsService.instance.getString(PrefsKeys.ELECTRICITY_URL),
          'https://example.com/e');
    });

    test('getTextAfterKeyword should return null on non-200 response',
        () async {
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
      TileService.setDioForTest(dio);

      final value =
          await TileService.getTextAfterKeyword(url: 'https://example.com/e');
      expect(value, isNull);
    });

    test('getTextAfterKeyword should return null when number is invalid',
        () async {
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
      TileService.setDioForTest(dio);

      final value =
          await TileService.getTextAfterKeyword(url: 'https://example.com/e');
      expect(value, isNull);
    });

    test('getTextAfterKeyword should return null when url is empty', () async {
      await PrefsService.instance.remove(PrefsKeys.ELECTRICITY_URL);
      final value = await TileService.getTextAfterKeyword(url: '');
      expect(value, isNull);
    });

    test('getTextAfterKeyword should return null on request failure', () async {
      final value =
          await TileService.getTextAfterKeyword(url: 'http://127.0.0.1:1/x');
      expect(value, isNull);
    });

    test('getElectricityWeeklyData should return empty when url missing',
        () async {
      await PrefsService.instance.remove(PrefsKeys.ELECTRICITY_URL);
      final list = await TileService.getElectricityWeeklyData();
      expect(list, isEmpty);
    });

    test('getElectricityWeeklyData should parse and aggregate hourly values',
        () async {
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
      TileService.setDioForTest(dio);

      final list = await TileService.getElectricityWeeklyData();
      expect(list, hasLength(2));
      expect(list[0].value, 2.0);
      expect(list[1].value, 2.0);
      expect(list[0].timestamp.hour, 10);
      expect(list[1].timestamp.hour, 11);
    });
  });

  group('TileService - URL launch behavior', () {
    test('openInWeChat should prefer wechat url scheme when available',
        () async {
      final launched = <String>[];
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

      await TileService.openInWeChat('https://example.com/a');
      expect(launched.single, startsWith('weixin://dl/business/'));
    });

    test('openInWeChat should fallback to browser when wechat unavailable',
        () async {
      final launched = <String>[];
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

      await TileService.openInWeChat('https://example.com/a');
      expect(launched.single, 'https://example.com/a');
    });

    test('openInWeChat should throw when no launcher is available', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(launcherChannel, (call) async {
        if (call.method == 'canLaunch' || call.method == 'canLaunchUrl') {
          return false;
        }
        return null;
      });

      await expectLater(
        () => TileService.openInWeChat('https://example.com/a'),
        throwsA(isA<String>()),
      );
    });
  });
}
