import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/system/tile_edit_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Clear shared preferences and initialize
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();

    // Initialize GetX
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('TileEditController', () {
    test('should_initialize_with_default_configuration', () async {
      final controller = TileEditController();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.isEditMode.value, false);
      expect(controller.config.value.configurations.length, 3);
      expect(controller.isLoading.value, false);
    });

    test('should_toggle_edit_mode_on_and_off', () async {
      final controller = TileEditController();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.isEditMode.value, false);

      await controller.toggleEditMode();
      expect(controller.isEditMode.value, true);

      await controller.toggleEditMode();
      expect(controller.isEditMode.value, false);
    });

    test('should_reorder_tiles_correctly', () async {
      final controller = TileEditController();
      await Future.delayed(const Duration(milliseconds: 100));

      final initialOrder = controller.visibleTiles.map((t) => t.id).toList();
      expect(initialOrder[0], '电费');

      await controller.reorderTile('电费', 0, 2);

      final newOrder = controller.visibleTiles.map((t) => t.id).toList();
      expect(newOrder[0], '校车');
      expect(newOrder[2], '电费');
    });

    test('should_toggle_tile_visibility', () async {
      final controller = TileEditController();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.visibleTiles.length, 3);
      expect(controller.isTileVisible('电费'), true);

      await controller.toggleVisibility('电费');

      expect(controller.visibleTiles.length, 2);
      expect(controller.isTileVisible('电费'), false);
    });

    test('should_force_exit_edit_mode_and_save', () async {
      final controller = TileEditController();
      await Future.delayed(const Duration(milliseconds: 100));

      await controller.toggleEditMode();
      expect(controller.isEditMode.value, true);

      await controller.forceExitEditMode();
      expect(controller.isEditMode.value, false);
    });

    test('should_reload_configuration_from_storage', () async {
      final controller = TileEditController();
      await Future.delayed(const Duration(milliseconds: 100));

      final initialCount = controller.config.value.configurations.length;

      await controller.reload();

      expect(controller.config.value.configurations.length, initialCount);
    });

    test('should_get_visible_tiles_list', () async {
      final controller = TileEditController();
      await Future.delayed(const Duration(milliseconds: 100));

      final visible = controller.visibleTiles;

      expect(visible.length, 3);
      expect(visible.every((t) => t.isVisible), true);
    });

    test('should_get_all_tiles_list', () async {
      final controller = TileEditController();
      await Future.delayed(const Duration(milliseconds: 100));

      final all = controller.allTiles;

      expect(all.length, 3);
    });

    test('should_check_if_tile_is_visible', () async {
      final controller = TileEditController();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.isTileVisible('电费'), true);
      expect(controller.isTileVisible('不存在'), false);
    });
  });
}
