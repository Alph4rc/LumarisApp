import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/plan_course.dart';
import 'package:ios_club_app/state/program_page_notifier.dart';
import 'package:ios_club_app/state/tile_store_providers.dart';
import 'package:ios_club_app/state/bus_page_notifier.dart';
import 'package:ios_club_app/ui/pages/electricity_page.dart';
import 'package:ios_club_app/ui/pages/payment_page.dart';
import 'package:ios_club_app/ui/pages/program_page.dart';
import 'package:ios_club_app/ui/pages/school_bus_page.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

Widget _wrapWithApp(Widget child) {
  return MaterialApp(
    theme: ClubTheme.lightTheme(),
    darkTheme: ClubTheme.darkTheme(),
    home: child,
  );
}

void main() {
  testWidgets('ProgramPage should not expose pull to refresh', (tester) async {
    final container = ProviderContainer(
      overrides: [
        programAutoLoadProvider.overrideWithValue(false),
        programsFetcherProvider.overrideWithValue(
          ({bool forceRefresh = false}) async => [
            PlanCourseList(
              term: '1',
              courses: [
                PlanCourse(
                  name: '高等数学',
                  courseTypeName: '必修',
                  credits: 4,
                  examMode: '考试',
                ),
              ],
            ),
          ],
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(programControllerProvider.notifier).loadPrograms();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _wrapWithApp(const ProgramPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RefreshIndicator), findsNothing);
  });

  testWidgets('PaymentPage should expose pull to refresh', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tileStoreAutoLoadProvider.overrideWithValue(false),
        ],
        child: _wrapWithApp(const PaymentPage()),
      ),
    );

    expect(find.byType(RefreshIndicator), findsOneWidget);
  });

  testWidgets('ElectricityPage should expose pull to refresh', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tileStoreAutoLoadProvider.overrideWithValue(false),
        ],
        child: _wrapWithApp(const ElectricityPage()),
      ),
    );

    expect(find.byType(RefreshIndicator), findsOneWidget);
  });

  testWidgets('SchoolBusPage should expose pull to refresh', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          busPageAutoLoadProvider.overrideWithValue(false),
        ],
        child: _wrapWithApp(const SchoolBusPage()),
      ),
    );

    expect(find.byType(RefreshIndicator), findsOneWidget);
  });
}
