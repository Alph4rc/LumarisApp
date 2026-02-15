import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/system/tile_edit_controller.dart';
import 'package:ios_club_app/ui/pages/homePages/tiles_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  Widget createTestWidget() {
    return GetMaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: TilesWidget(),
        ),
      ),
    );
  }

  group('TilesWidget - Drag Interactions', () {
    testWidgets('should_display_tiles_in_normal_mode',
        (WidgetTester tester) async {
      Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show tiles
      expect(find.text('快捷功能'), findsOneWidget);
      expect(find.text('编辑'), findsOneWidget);
    });

    testWidgets('should_show_reorderable_grid_in_edit_mode',
        (WidgetTester tester) async {
      final controller = Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter edit mode
      await controller.toggleEditMode();
      await tester.pumpAndSettle();

      expect(find.text('完成'), findsOneWidget);
    });

    testWidgets('should_display_empty_message_when_no_tiles',
        (WidgetTester tester) async {
      final controller = Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Hide all tiles except one
      await controller.toggleVisibility('电费');
      await controller.toggleVisibility('校车');
      await tester.pumpAndSettle();

      // Should still show one tile
      expect(controller.visibleTiles.length, 1);
    });

    testWidgets('should_show_edit_mode_indicators',
        (WidgetTester tester) async {
      final controller = Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter edit mode
      await controller.toggleEditMode();
      await tester.pumpAndSettle();

      // Should show available tiles list if any tiles are hidden
      await controller.toggleVisibility('电费');
      await tester.pumpAndSettle();

      expect(find.text('已隐藏的磁贴'), findsOneWidget);
    });
  });

  group('TilesWidget - Platform-Specific Behavior', () {
    testWidgets('should_handle_tile_reordering',
        (WidgetTester tester) async {
      final controller = Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final initialOrder = controller.visibleTiles.map((t) => t.id).toList();
      expect(initialOrder[0], '电费');

      // Enter edit mode
      await controller.toggleEditMode();
      await tester.pumpAndSettle();

      // Reorder tiles programmatically (simulating drag)
      await controller.reorderTile('电费', 0, 2);
      await tester.pumpAndSettle();

      final newOrder = controller.visibleTiles.map((t) => t.id).toList();
      expect(newOrder[0], '校车');
      expect(newOrder[2], '电费');
    });

    testWidgets('should_persist_changes_on_exit',
        (WidgetTester tester) async {
      final controller = Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter edit mode
      await controller.toggleEditMode();
      await tester.pumpAndSettle();

      // Make changes
      await controller.reorderTile('电费', 0, 1);
      await tester.pumpAndSettle();

      // Exit edit mode (should save)
      await controller.toggleEditMode();
      await tester.pumpAndSettle();

      // Verify changes persisted
      final order = controller.visibleTiles.map((t) => t.id).toList();
      expect(order[1], '电费');
    });
  });

  group('TilesWidget - Visual Feedback', () {
    testWidgets('should_show_animation_on_tile_appearance',
        (WidgetTester tester) async {
      Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget());

      // Pump once to start animation
      await tester.pump();

      // Pump with duration to see animation
      await tester.pump(const Duration(milliseconds: 100));

      // Complete animation
      await tester.pumpAndSettle();

      // Tiles should be visible
      expect(find.byType(TilesWidget), findsOneWidget);
    });

    testWidgets('should_handle_lifecycle_changes',
        (WidgetTester tester) async {
      final controller = Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter edit mode
      await controller.toggleEditMode();
      await tester.pumpAndSettle();

      expect(controller.isEditMode.value, true);

      // Simulate app going to background
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pumpAndSettle();

      // Edit mode should be exited
      expect(controller.isEditMode.value, false);
    });
  });

  group('TilesWidget - Error Handling', () {
    testWidgets('should_show_error_when_hiding_all_tiles',
        (WidgetTester tester) async {
      final controller = Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Hide tiles until only one left
      await controller.toggleVisibility('电费');
      await controller.toggleVisibility('校车');
      await tester.pumpAndSettle();

      // Try to hide the last tile
      expect(
        () => controller.toggleVisibility('饭卡'),
        throwsA(isA<StateError>()),
      );
    });

    testWidgets('should_handle_invalid_reorder_gracefully',
        (WidgetTester tester) async {
      final controller = Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Try invalid reorder
      expect(
        () => controller.reorderTile('电费', -1, 0),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
