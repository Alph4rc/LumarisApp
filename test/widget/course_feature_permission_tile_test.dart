import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/system/permissions/course_feature_permissions.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/ui/components/permissions/course_feature_permission_tile.dart';
import 'package:permission_handler/permission_handler.dart';

const MethodChannel _permissionChannel = MethodChannel(
  'flutter.baseflow.com/permissions/methods',
);

Widget _buildApp(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    theme: McThemeData.materialTheme(McColors.light),
    home: Scaffold(body: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late Map<int, PermissionStatus> statuses;
  late int openSettingsCalls;

  setUp(() {
    statuses = {};
    openSettingsCalls = 0;
    messenger.setMockMethodCallHandler(_permissionChannel, (call) async {
      switch (call.method) {
        case 'checkPermissionStatus':
          final status = statuses[call.arguments as int];
          return status?.index ?? PermissionStatus.denied.index;
        case 'shouldShowRequestPermissionRationale':
          return false;
        case 'requestPermissions':
          final requested = (call.arguments as List<Object?>).cast<int>();
          for (final value in requested) {
            statuses[value] = PermissionStatus.granted;
          }
          return {
            for (final value in requested)
              value: PermissionStatus.granted.index,
          };
        case 'openAppSettings':
          openSettingsCalls += 1;
          return true;
      }
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(_permissionChannel, null);
  });

  testWidgets('should_show_granted_status_when_all_permissions_are_granted', (
    tester,
  ) async {
    statuses = {
      Permission.notification.value: PermissionStatus.granted,
      Permission.scheduleExactAlarm.value: PermissionStatus.granted,
      Permission.ignoreBatteryOptimizations.value: PermissionStatus.granted,
    };

    await tester.pumpWidget(
      _buildApp(
        const CourseFeaturePermissionTile(
          feature: CourseFeaturePermission.reminder,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Course Reminder Permissions'), findsOneWidget);
    expect(find.text('Granted'), findsOneWidget);
  });

  testWidgets('should_request_missing_permissions_when_tile_is_tapped', (
    tester,
  ) async {
    statuses = {
      Permission.notification.value: PermissionStatus.granted,
      Permission.scheduleExactAlarm.value: PermissionStatus.denied,
      Permission.ignoreBatteryOptimizations.value: PermissionStatus.granted,
    };

    await tester.pumpWidget(
      _buildApp(
        const CourseFeaturePermissionTile(
          feature: CourseFeaturePermission.reminder,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Partially granted'), findsOneWidget);

    await tester.tap(find.text('Course Reminder Permissions'));
    await tester.pumpAndSettle();

    expect(find.text('Allow'), findsOneWidget);

    await tester.tap(find.text('Allow'));
    await tester.pumpAndSettle();

    expect(find.text('Granted'), findsOneWidget);
    expect(
      statuses[Permission.scheduleExactAlarm.value],
      PermissionStatus.granted,
    );

    // 等待 McFeedback 的提示计时器结束，避免测试结束后仍有挂起的 Timer。
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('should_open_system_settings_when_all_permissions_are_granted', (
    tester,
  ) async {
    statuses = {
      Permission.notification.value: PermissionStatus.granted,
      Permission.scheduleExactAlarm.value: PermissionStatus.granted,
      Permission.ignoreBatteryOptimizations.value: PermissionStatus.granted,
    };

    await tester.pumpWidget(
      _buildApp(
        const CourseFeaturePermissionTile(
          feature: CourseFeaturePermission.reminder,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Course Reminder Permissions'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'This permission is enabled. To turn it off, please adjust it in system settings.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Open Settings'));
    await tester.pumpAndSettle();

    expect(openSettingsCalls, 1);
  });
}
