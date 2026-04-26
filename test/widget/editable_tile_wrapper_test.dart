import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/system/tile_edit_controller.dart';
import 'package:ios_club_app/ui/components/tiles/editable_tile_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
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
      await pumpFrames(tester);

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
      await pumpFrames(tester);

      // Enter edit mode
      await controller.toggleEditMode();
      await pumpFrames(tester);

      // Should show hide button
      expect(find.byIcon(Icons.remove), findsOneWidget);

      await controller.forceExitEditMode();
      await pumpFrames(tester);
    }, timeout: const Timeout(Duration(seconds: 15)));

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
      await pumpFrames(tester);

      // Should not show edit indicators
      expect(find.byIcon(Icons.remove), findsNothing);
    });

    testWidgets('should_handle_hide_button_tap', (WidgetTester tester) async {
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
      await pumpFrames(tester);

      // Enter edit mode
      await controller.toggleEditMode();
      await pumpFrames(tester);

      expect(controller.isTileVisible('电费'), true);

      // Tap hide button
      await tester.tap(find.byIcon(Icons.remove));
      await pumpFrames(tester);

      expect(controller.isTileVisible('电费'), false);

      await controller.forceExitEditMode();
      await pumpFrames(tester);
    });

    testWidgets('should_allow_hiding_last_tile',
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
      await pumpFrames(tester);

      // Enter edit mode
      await controller.toggleEditMode();
      await pumpFrames(tester);

      // Try to hide the last tile
      await tester.tap(find.byIcon(Icons.remove));
      await pumpFrames(tester);

      // Verify that it was hidden successfully (visibility is false)
      expect(controller.isTileVisible('饭卡'), isFalse);

      await controller.forceExitEditMode();
      await pumpFrames(tester);
    });
  });
}
