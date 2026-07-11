import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ios_club_app/main_app.dart';
import 'package:ios_club_app/ui/pages/campus_map_page.dart';

import '../ui/pages/under_maintenance_screen.dart';
import '../ui/pages/agreement_page.dart';
import '../ui/pages/author_page.dart';
import '../ui/pages/easter_egg_page.dart';
import '../ui/pages/electricity_page.dart';
import '../ui/pages/helper_page.dart';
import '../ui/pages/home_page.dart';
import '../ui/pages/license_page.dart';
import '../ui/pages/link_page.dart';
import '../ui/pages/login_page.dart';
import '../ui/pages/net_page.dart';
import '../ui/pages/payment_page.dart';
import '../ui/pages/privacy_policy_page.dart';
import '../ui/pages/profile_page.dart';
import '../ui/pages/program_page.dart';
import '../ui/pages/schedulePages/custom_course_manage_page.dart';
import '../ui/pages/schedulePages/html_import_page.dart';
import '../ui/pages/schedulePages/html_import_webview_page.dart';
import '../ui/pages/schedulePages/schedule_setting_page.dart';
import '../ui/pages/schedule_list_page.dart';
import '../ui/pages/school_bus_page.dart';
import '../ui/pages/score_page.dart';
import '../ui/pages/setting_page.dart';
import '../ui/pages/user_agreement_page.dart';

class AppRoutes {
  const AppRoutes._();

  static const home = '/';
  static const schedule = '/Schedule';
  static const score = '/Score';
  static const profile = '/Profile';
  static const login = '/Login';
  static const link = '/Link';
  static const about = '/Profile/About';
  static const scheduleSetting = '/Schedule/ScheduleSetting';
  static const customCourseManage =
      '/Schedule/ScheduleSetting/CustomCourseManage';
  static const schoolBus = '/SchoolBus';
  static const program = '/Profile/Program';
  static const electricity = '/Electricity';
  static const payment = '/Payment';
  static const net = '/Electricity/Net';
  static const helper = '/Profile/Helper';
  static const egg = '/Profile/About/Egg';
  static const license = '/Profile/About/License';
  static const agreement = '/Profile/About/Agreement';
  static const privacyPolicy = '/Profile/About/PrivacyPolicy';
  static const userAgreement = '/Profile/About/UserAgreement';
  static const author = '/Profile/About/Author';
  static const htmlImport = '/Schedule/HtmlImport';
  static const htmlImportWebview = '/Schedule/HtmlImport/Webview';
  static const campusMap = '/CampusMap';
}

class AppRouter {
  const AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainApp(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomePage(),
              routes: [
                _detailRoute('Login', (context, state) => const LoginPage()),
                _detailRoute('Link', (context, state) => const LinkPage()),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.schedule,
              builder: (context, state) => const ScheduleListPage(),
              routes: [
                GoRoute(
                  path: 'ScheduleSetting',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) => const ScheduleSettingPage(),
                  routes: [
                    _detailRoute(
                      'CustomCourseManage',
                      (context, state) => const CustomCourseManagePage(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'HtmlImport',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) => const HtmlImportPage(),
                  routes: [
                    _detailRoute(
                      'Webview',
                      (context, state) => HtmlImportWebViewPage(
                        url: state.extra as String,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.score,
                builder: (context, state) => const ScorePage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfilePage(),
              routes: [
                _detailRoute(
                    'Program', (context, state) => const ProgramPage()),
                _detailRoute('Helper', (context, state) => const HelperPage()),
                GoRoute(
                  path: 'About',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) => const SettingPage(),
                  routes: [
                    _detailRoute(
                        'Egg', (context, state) => const EasterEggPage()),
                    _detailRoute(
                        'License', (context, state) => const LicensePage()),
                    _detailRoute(
                        'Agreement', (context, state) => const AgreementPage()),
                    _detailRoute('PrivacyPolicy',
                        (context, state) => const PrivacyPolicyPage()),
                    _detailRoute('UserAgreement',
                        (context, state) => const UserAgreementPage()),
                    _detailRoute(
                        'Author', (context, state) => const AuthorPage()),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.electricity,
              builder: (context, state) => const ElectricityPage(),
              routes: [
                _detailRoute('Net', (context, state) => const NetPage())
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.schoolBus,
                builder: (context, state) => const SchoolBusPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.payment,
                builder: (context, state) => PaymentPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.campusMap,
                builder: (context, state) => const CampusMapPage()),
          ]),
        ],
      ),
    ],
    errorBuilder: (context, state) => const UnderMaintenanceScreen(),
  );

  static String get currentLocation {
    final uri = router.routerDelegate.currentConfiguration.uri;
    return uri.path.isEmpty ? AppRoutes.home : uri.path;
  }

  static void go(String location, {Object? extra}) {
    router.go(location, extra: extra);
  }

  static Future<T?> push<T extends Object?>(String location, {Object? extra}) {
    return router.push<T>(location, extra: extra);
  }

  static void pop<T extends Object?>([T? result]) {
    if (router.canPop()) {
      router.pop<T>(result);
    }
  }

  static GoRoute _detailRoute(
      String path, Widget Function(BuildContext, GoRouterState) builder) {
    return GoRoute(
      path: path,
      parentNavigatorKey: rootNavigatorKey,
      builder: builder,
    );
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return AppRouter.router;
});
