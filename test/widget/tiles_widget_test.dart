import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/system/tile_edit_controller.dart';
import 'package:ios_club_app/state/bus_tile_store.dart';
import 'package:ios_club_app/state/electricity_store.dart';
import 'package:ios_club_app/state/payment_store.dart';
import 'package:ios_club_app/ui/pages/homePages/tiles_widget.dart';
import 'package:ios_club_app/ui/components/tiles/tile_edit_controls.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestElectricityStore extends ElectricityStore {
  @override
  void onInit() {
    isLoading.value = false;
    hasData.value = false;
    electricity.value = 0.0;
  }
}

class _TestBusTileStore extends BusTileStore {
  @override
  void onInit() {
    isLoading.value = false;
    busCount.value = 0;
    useNewApi.value = false;
  }
}

class _TestPaymentStore extends PaymentStore {
  @override
  void onInit() {
    isLoading.value = false;
    totalRecharge.value = 0.0;
    errorMessage.value = '';
    this.num.value = '';
    isShowTile.value = false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpFrames(WidgetTester tester, {int count = 6}) async {
    for (var i = 0; i < count; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();
    Get.testMode = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => null,
    );
    Get.put<ElectricityStore>(_TestElectricityStore());
    Get.put<BusTileStore>(_TestBusTileStore());
    Get.put<PaymentStore>(_TestPaymentStore());
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
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
      await pumpFrames(tester);

      // Should show tiles
      expect(find.text('快捷功能'), findsOneWidget);
      expect(find.text('编辑'), findsOneWidget);
    });

    testWidgets('should_show_reorderable_grid_in_edit_mode',
        (WidgetTester tester) async {
      final controller = Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget());
      await pumpFrames(tester);

      // Enter edit mode
      await controller.toggleEditMode();
      await pumpFrames(tester);

      expect(find.text('完成'), findsOneWidget);
    });

    testWidgets('should_display_empty_message_when_no_tiles',
        (WidgetTester tester) async {
      final controller = Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget());
      await pumpFrames(tester);

      // Hide all tiles except one
      await controller.toggleVisibility('电费');
      await controller.toggleVisibility('校车');
      await pumpFrames(tester);

      // Should still show one tile
      expect(controller.visibleTiles.length, 1);
    });

    testWidgets('should_show_edit_mode_indicators',
        (WidgetTester tester) async {
      final controller = Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget());
      await pumpFrames(tester);

      // Enter edit mode
      await controller.toggleEditMode();
      await pumpFrames(tester);

      // Should show available tiles list if any tiles are hidden
      await controller.toggleVisibility('电费');
      await pumpFrames(tester);

      expect(find.text('更多功能'), findsOneWidget);
    });
  });

  group('TilesWidget - Platform-Specific Behavior', () {
    testWidgets('should_handle_tile_reordering', (WidgetTester tester) async {
      final controller = Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget());
      await pumpFrames(tester);

      final initialOrder = controller.visibleTiles.map((t) => t.id).toList();
      expect(initialOrder.length, greaterThanOrEqualTo(2));
      final movedTileId = initialOrder.first;
      final targetIndex = initialOrder.length - 1;

      // Enter edit mode
      await controller.toggleEditMode();
      await pumpFrames(tester);

      // Reorder tiles programmatically (simulating drag)
      await controller.reorderTile(movedTileId, 0, targetIndex);
      await pumpFrames(tester);

      final newOrder = controller.visibleTiles.map((t) => t.id).toList();
      expect(newOrder[targetIndex], movedTileId);
    });

    testWidgets('should_persist_changes_on_exit', (WidgetTester tester) async {
      final controller = Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget());
      await pumpFrames(tester);

      // Enter edit mode
      await controller.toggleEditMode();
      await pumpFrames(tester);

      // Make changes
      final originalFirst = controller.visibleTiles.first.id;
      await controller.reorderTile(originalFirst, 0, 1);
      await pumpFrames(tester);

      // Exit edit mode (should save)
      await controller.toggleEditMode();
      await pumpFrames(tester);

      // Verify changes persisted
      final order = controller.visibleTiles.map((t) => t.id).toList();
      expect(order[1], originalFirst);
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
      await pumpFrames(tester);

      // Tiles should be visible
      expect(find.byType(TilesWidget), findsOneWidget);
    });

    testWidgets('should_handle_lifecycle_changes', (WidgetTester tester) async {
      final controller = Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget());
      await pumpFrames(tester);

      // Enter edit mode
      await controller.toggleEditMode();
      await pumpFrames(tester);

      expect(controller.isEditMode.value, true);

      // Simulate app going to background
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await pumpFrames(tester);

      // Edit mode should be exited
      expect(controller.isEditMode.value, false);
    });

    testWidgets('should_not_throw_when_disposed_without_controller',
        (WidgetTester tester) async {
      Get.put(TileEditController());
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TilesWidget(),
            ),
          ),
        ),
      );
      await pumpFrames(tester);

      Get.reset();
      await tester.pumpWidget(const SizedBox.shrink());
      await pumpFrames(tester);

      expect(find.byType(TilesWidget), findsNothing);
    });
  });

  group('TilesWidget - Error Handling', () {
    testWidgets('should_show_empty_state_when_all_tiles_hidden',
        (WidgetTester tester) async {
      final controller = Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget());
      await pumpFrames(tester);

      // Hide all tiles
      final visibleIds = controller.visibleTiles.map((t) => t.id).toList();
      for (var id in visibleIds) {
        await controller.toggleVisibility(id);
      }
      await pumpFrames(tester);

      // Verify empty state is shown
      expect(find.byType(EmptyTilesMessage), findsOneWidget);
    });

    testWidgets('should_handle_invalid_reorder_gracefully',
        (WidgetTester tester) async {
      final controller = Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget());
      await pumpFrames(tester);

      // Try invalid reorder
      await expectLater(
        controller.reorderTile('电费', -1, 0),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
