import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/ui/pages/permission_page/permission_page.dart';
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
    home: child,
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
        case 'requestPermissions':
          final requested = (call.arguments as List<Object?>).cast<int>();
          return {
            for (final value in requested)
              value: statuses[value]?.index ?? PermissionStatus.denied.index,
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

  testWidgets('should_show_platform_hint_when_permissions_are_not_managed', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(const PermissionPage(isMobileOverride: false)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('No permission management needed on this platform'),
      findsOneWidget,
    );
    expect(find.text('Notifications'), findsNothing);
  });

  testWidgets('should_render_permission_statuses_when_mobile', (tester) async {
    statuses = {
      Permission.notification.value: PermissionStatus.granted,
      Permission.locationWhenInUse.value: PermissionStatus.denied,
      Permission.scheduleExactAlarm.value: PermissionStatus.granted,
      Permission.ignoreBatteryOptimizations.value: PermissionStatus.granted,
    };

    await tester.pumpWidget(
      _buildApp(const PermissionPage(isMobileOverride: true)),
    );
    await tester.pumpAndSettle();

    expect(find.text('3/4 granted'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Granted'), findsNWidgets(3));
    expect(find.text('Not granted'), findsOneWidget);
    expect(find.text('Exact Alarms'), findsOneWidget);
    expect(find.text('Background Running'), findsOneWidget);
  });

  testWidgets('should_open_system_settings_when_granted_row_is_tapped', (
    tester,
  ) async {
    statuses = {
      Permission.notification.value: PermissionStatus.granted,
      Permission.locationWhenInUse.value: PermissionStatus.denied,
    };

    await tester.pumpWidget(
      _buildApp(const PermissionPage(isMobileOverride: true)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Notifications'));
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

  testWidgets('should_request_denied_permission_and_refresh_status', (
    tester,
  ) async {
    statuses = {
      Permission.notification.value: PermissionStatus.granted,
      Permission.locationWhenInUse.value: PermissionStatus.denied,
      Permission.scheduleExactAlarm.value: PermissionStatus.granted,
      Permission.ignoreBatteryOptimizations.value: PermissionStatus.granted,
    };

    await tester.pumpWidget(
      _buildApp(const PermissionPage(isMobileOverride: true)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Location'));
    await tester.pumpAndSettle();

    statuses[Permission.locationWhenInUse.value] = PermissionStatus.granted;

    await tester.tap(find.text('Allow'));
    await tester.pumpAndSettle();

    expect(find.text('All permissions granted'), findsOneWidget);
    expect(find.text('Granted'), findsNWidgets(4));
  });
}
