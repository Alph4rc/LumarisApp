import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/main_app.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/ui/pages/agreement_page.dart';
import 'package:ios_club_app/ui/pages/home_page.dart';
import 'package:ios_club_app/ui/pages/link_page.dart';
import 'package:ios_club_app/ui/pages/login_page.dart';
import 'package:ios_club_app/ui/pages/profile_page.dart';
import 'package:ios_club_app/ui/pages/schedule_list_page.dart';
import 'package:ios_club_app/ui/pages/score_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();
    AppRouter.go(AppRoutes.agreement);
  });

  Widget buildMatchedRoute(BuildContext context, String location) {
    final match = AppRouter.router.configuration.findMatch(Uri.parse(location));
    expect(match.isError, isFalse);

    final state = match.last.buildState(
      AppRouter.router.configuration,
      match,
    );
    return match.last.route.builder!(context, state);
  }

  testWidgets('matches and builds the core route table', (tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(),
    ));
    final context = tester.element(find.byType(SizedBox));

    expect(buildMatchedRoute(context, AppRoutes.home), isA<HomePage>());
    expect(
      buildMatchedRoute(context, AppRoutes.schedule),
      isA<ScheduleListPage>(),
    );
    expect(buildMatchedRoute(context, AppRoutes.score), isA<ScorePage>());
    expect(buildMatchedRoute(context, AppRoutes.profile), isA<ProfilePage>());
    expect(buildMatchedRoute(context, AppRoutes.login), isA<LoginPage>());
    expect(buildMatchedRoute(context, AppRoutes.link), isA<LinkPage>());
  });

  testWidgets('login route can return true when popped', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: AppRouter.router),
      ),
    );
    await tester.pumpAndSettle();

    final resultFuture = AppRouter.push<bool>(AppRoutes.login);
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);

    AppRouter.pop(true);
    await tester.pumpAndSettle();

    await expectLater(resultFuture, completion(isTrue));
  });

  testWidgets('go switches the active route without GetX routing',
      (tester) async {
    AppRouter.go(AppRoutes.login);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: AppRouter.router),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);

    AppRouter.go(AppRoutes.agreement);
    await tester.pumpAndSettle();

    expect(AppRouter.currentLocation, AppRoutes.agreement);
    expect(find.byType(AgreementPage), findsOneWidget);
  });

  testWidgets('main shell can switch layouts without duplicating global keys',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await PrefsService.instance.setBool(PrefsKeys.AGREEMENT_ACCEPTED, true);

    final childKey = GlobalKey();
    final routedChild = SizedBox(key: childKey);

    Future<void> pumpShell(Size size) async {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MainApp(child: routedChild),
          ),
        ),
      );
      await tester.pump();
    }

    await pumpShell(const Size(390, 844));
    expect(find.byKey(childKey), findsOneWidget);

    await pumpShell(const Size(1024, 768));
    expect(find.byKey(childKey), findsOneWidget);
    expect(tester.takeException(), isNull);

    debugDefaultTargetPlatformOverride = null;
  });
}
