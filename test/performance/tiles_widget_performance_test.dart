@Tags(['performance'])
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/system/tile_edit_controller.dart';
import 'package:ios_club_app/ui/pages/homePages/tiles_widget.dart';
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
  });

  tearDown(() {
    Get.reset();
  });

  Widget createHost() {
    return const GetMaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: TilesWidget(),
        ),
      ),
    );
  }

  testWidgets('tiles_widget_first_build_within_budget', (tester) async {
    Get.put(TileEditController());
    final sw = Stopwatch()..start();
    await tester.pumpWidget(createHost());
    await pumpFrames(tester, count: 10);
    sw.stop();

    expect(find.byType(TilesWidget), findsOneWidget);
    expect(sw.elapsedMilliseconds, lessThan(2500));
  });

  testWidgets('tiles_widget_edit_mode_toggle_within_budget', (tester) async {
    final controller = Get.put(TileEditController());
    await tester.pumpWidget(createHost());
    await pumpFrames(tester, count: 10);

    final sw = Stopwatch()..start();
    await controller.toggleEditMode();
    await pumpFrames(tester, count: 8);
    await controller.toggleEditMode();
    await pumpFrames(tester, count: 8);
    sw.stop();

    expect(controller.isEditMode.value, isFalse);
    expect(sw.elapsedMilliseconds, lessThan(2500));
  });
}
