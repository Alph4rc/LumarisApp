import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/system/tile_edit_controller.dart';
import 'package:ios_club_app/ui/components/tiles/tile_edit_controls.dart';
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

  group('TileEditControls', () {
    testWidgets('should_display_edit_button_when_not_in_edit_mode',
        (WidgetTester tester) async {
      Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget(const TileEditControls()));
      await tester.pumpAndSettle();

      expect(find.text('编辑'), findsOneWidget);
      expect(find.text('完成'), findsNothing);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('should_display_done_button_when_in_edit_mode',
        (WidgetTester tester) async {
      final controller = Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget(const TileEditControls()));
      await tester.pumpAndSettle();

      // Enter edit mode
      await controller.toggleEditMode();
      await tester.pumpAndSettle();

      expect(find.text('完成'), findsOneWidget);
      expect(find.text('编辑'), findsNothing);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should_toggle_edit_mode_when_button_tapped',
        (WidgetTester tester) async {
      final controller = Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget(const TileEditControls()));
      await tester.pumpAndSettle();

      expect(controller.isEditMode.value, false);

      // Tap edit button
      await tester.tap(find.text('编辑'));
      await tester.pumpAndSettle();

      expect(controller.isEditMode.value, true);

      // Tap done button
      await tester.tap(find.text('完成'));
      await tester.pumpAndSettle();

      expect(controller.isEditMode.value, false);
    });

    testWidgets('should_animate_button_transition',
        (WidgetTester tester) async {
      final controller = Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget(const TileEditControls()));
      await tester.pumpAndSettle();

      // Tap edit button
      await tester.tap(find.text('编辑'));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 100)); // Mid animation

      // Should be animating
      expect(controller.isEditMode.value, true);

      await tester.pumpAndSettle(); // Complete animation
      expect(find.text('完成'), findsOneWidget);
    });

    testWidgets('should_display_title_text', (WidgetTester tester) async {
      Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget(const TileEditControls()));
      await tester.pumpAndSettle();

      expect(find.text('快捷功能'), findsOneWidget);
    });
  });

  group('EmptyTilesMessage', () {
    testWidgets('should_display_empty_state_message',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const EmptyTilesMessage()));
      await tester.pumpAndSettle();

      expect(find.text('暂无快捷功能'), findsOneWidget);
      expect(find.text('请在编辑模式中添加'), findsOneWidget);
      expect(find.byIcon(Icons.widgets_outlined), findsOneWidget);
    });
  });

  group('AvailableTilesList', () {
    testWidgets('should_not_display_when_no_hidden_tiles',
        (WidgetTester tester) async {
      Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget(const AvailableTilesList()));
      await tester.pumpAndSettle();

      // All tiles visible by default, so list should be hidden
      expect(find.text('已隐藏的磁贴'), findsNothing);
    });

    testWidgets('should_display_hidden_tiles_list',
        (WidgetTester tester) async {
      final controller = Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget(const AvailableTilesList()));
      await tester.pumpAndSettle();

      // Hide a tile
      await controller.toggleVisibility('电费');
      await tester.pumpAndSettle();

      expect(find.text('已隐藏的磁贴'), findsOneWidget);
      expect(find.text('电费'), findsOneWidget);
    });

    testWidgets('should_show_tile_when_chip_tapped',
        (WidgetTester tester) async {
      final controller = Get.put(TileEditController());
      await tester.pumpWidget(createTestWidget(const AvailableTilesList()));
      await tester.pumpAndSettle();

      // Hide a tile
      await controller.toggleVisibility('电费');
      await tester.pumpAndSettle();

      expect(controller.isTileVisible('电费'), false);

      // Tap the chip to show it again
      await tester.tap(find.text('电费'));
      await tester.pumpAndSettle();

      expect(controller.isTileVisible('电费'), true);
    });
  });

  group('EditModeIndicator', () {
    testWidgets('should_show_border_in_edit_mode',
        (WidgetTester tester) async {
      final controller = Get.put(TileEditController());
      await tester.pumpWidget(
        createTestWidget(
          EditModeIndicator(
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

      // Find the AnimatedContainer
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    testWidgets('should_not_show_border_when_not_in_edit_mode',
        (WidgetTester tester) async {
      Get.put(TileEditController());
      await tester.pumpWidget(
        createTestWidget(
          EditModeIndicator(
            child: Container(
              width: 100,
              height: 100,
              color: Colors.red,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNull);
    });
  });
}
