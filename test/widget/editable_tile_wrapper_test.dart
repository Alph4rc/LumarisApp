import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/system/tile_edit_controller.dart';
import 'package:ios_club_app/ui/components/tiles/editable_tile_wrapper.dart';
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

  Widget createTestWidget(Widget child) {
    return GetMaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('EditableTileWrapper - Visual Feedback', () {
    testWidgets('should_display_tile_content', (WidgetTester tester) async {
      Get.put(TileEditController());

      await tester.pumpWidget(
        createTestWidget(
          EditableTileWrapper(
            tileId: '电费',
            index: 0,
            child: Container(
              width: 100,
              height: 100,
              color: Colors.red,
              child: const Text('Test Tile'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Tile'), findsOneWidget);
    });

    testWidgets('should_show_edit_indicators_in_edit_mode',
        (WidgetTester tester) async {
      final controller = Get.put(TileEditController());

      await tester.pumpWidget(
        createTestWidget(
          EditableTileWrapper(
            tileId: '电费',
            index: 0,
            child: Container(
              width: 100,
              height: 100,
              color: Colors.red,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter edit mode
      await controller.toggleEditMode();
      await tester.pumpAndSettle();

      // Should show drag indicator
      expect(find.byIcon(Icons.drag_indicator), findsOneWidget);

      // Should show hide button
      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
    });

    testWidgets('should_not_show_edit_indicators_in_normal_mode',
        (WidgetTester tester) async {
      Get.put(TileEditController());

      await tester.pumpWidget(
        createTestWidget(
          EditableTileWrapper(
            tileId: '电费',
            index: 0,
            child: Container(
              width: 100,
              height: 100,
              color: Colors.red,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should not show edit indicators
      expect(find.byIcon(Icons.drag_indicator), findsNothing);
      expect(find.byIcon(Icons.remove_circle_outline), findsNothing);
    });

    testWidgets('should_handle_hide_button_tap',
        (WidgetTester tester) async {
      final controller = Get.put(TileEditController());

      await tester.pumpWidget(
        createTestWidget(
          EditableTileWrapper(
            tileId: '电费',
            index: 0,
            child: Container(
              width: 100,
              height: 100,
              color: Colors.red,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter edit mode
      await controller.toggleEditMode();
      await tester.pumpAndSettle();

      expect(controller.isTileVisible('电费'), true);

      // Tap hide button
      await tester.tap(find.byIcon(Icons.remove_circle_outline));
      await tester.pumpAndSettle();

      expect(controller.isTileVisible('电费'), false);
    });

    testWidgets('should_show_error_when_hiding_last_tile',
        (WidgetTester tester) async {
      final controller = Get.put(TileEditController());

      // Hide all but one tile
      await controller.toggleVisibility('电费');
      await controller.toggleVisibility('校车');

      await tester.pumpWidget(
        createTestWidget(
          EditableTileWrapper(
            tileId: '饭卡',
            index: 0,
            child: Container(
              width: 100,
              height: 100,
              color: Colors.red,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter edit mode
      await controller.toggleEditMode();
      await tester.pumpAndSettle();

      // Try to hide the last tile
      await tester.tap(find.byIcon(Icons.remove_circle_outline));
      await tester.pumpAndSettle();

      // Should show snackbar
      expect(find.text('至少需要保留一个磁贴'), findsOneWidget);
    });
  });

  group('DraggableTileItem', () {
    testWidgets('should_create_draggable_tile', (WidgetTester tester) async {
      bool dragStarted = false;
      bool dragEnded = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DraggableTileItem(
              tileId: '电费',
              index: 0,
              onDragStarted: () => dragStarted = true,
              onDragEnd: () => dragEnded = true,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.red,
                child: const Text('Draggable'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Draggable'), findsOneWidget);
    });
  });

  group('TapReorderTileItem', () {
    testWidgets('should_show_selection_indicator_when_selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapReorderTileItem(
              tileId: '电费',
              index: 0,
              isSelected: true,
              onTap: () {},
              child: Container(
                width: 100,
                height: 100,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show check icon when selected
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should_not_show_selection_indicator_when_not_selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapReorderTileItem(
              tileId: '电费',
              index: 0,
              isSelected: false,
              onTap: () {},
              child: Container(
                width: 100,
                height: 100,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should not show check icon
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('should_call_onTap_when_tapped',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapReorderTileItem(
              tileId: '电费',
              index: 0,
              isSelected: false,
              onTap: () => tapped = true,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TapReorderTileItem));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });
  });
}
