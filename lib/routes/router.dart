import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  static const about = '/About';
  static const scheduleSetting = '/ScheduleSetting';
  static const customCourseManage = '/CustomCourseManage';
  static const schoolBus = '/SchoolBus';
  static const program = '/Program';
  static const electricity = '/Electricity';
  static const payment = '/Payment';
  static const net = '/Net';
  static const helper = '/Helper';
  static const egg = '/Egg';
  static const license = '/License';
  static const agreement = '/Agreement';
  static const privacyPolicy = '/PrivacyPolicy';
  static const userAgreement = '/UserAgreement';
  static const author = '/Author';
  static const htmlImport = '/HtmlImport';
  static const htmlImportWebview = '/HtmlImportWebview';
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
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.schedule,
        builder: (context, state) => const ScheduleListPage(),
      ),
      GoRoute(
        path: AppRoutes.score,
        builder: (context, state) => const ScorePage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.link,
        builder: (context, state) => const LinkPage(),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) => const SettingPage(),
      ),
      GoRoute(
        path: AppRoutes.scheduleSetting,
        builder: (context, state) => const ScheduleSettingPage(),
      ),
      GoRoute(
        path: AppRoutes.customCourseManage,
        builder: (context, state) => const CustomCourseManagePage(),
      ),
      GoRoute(
        path: AppRoutes.htmlImport,
        builder: (context, state) => const HtmlImportPage(),
      ),
      GoRoute(
        path: AppRoutes.htmlImportWebview,
        builder: (context, state) =>
            HtmlImportWebViewPage(url: state.extra as String),
      ),
      GoRoute(
        path: AppRoutes.schoolBus,
        builder: (context, state) => const SchoolBusPage(),
      ),
      GoRoute(
        path: AppRoutes.program,
        builder: (context, state) => const ProgramPage(),
      ),
      GoRoute(
        path: AppRoutes.electricity,
        builder: (context, state) => const ElectricityPage(),
      ),
      GoRoute(
        path: AppRoutes.payment,
        builder: (context, state) => PaymentPage(),
      ),
      GoRoute(
        path: AppRoutes.net,
        builder: (context, state) => const NetPage(),
      ),
      GoRoute(
        path: AppRoutes.helper,
        builder: (context, state) => const HelperPage(),
      ),
      GoRoute(
        path: AppRoutes.egg,
        builder: (context, state) => const EasterEggPage(),
      ),
      GoRoute(
        path: AppRoutes.license,
        builder: (context, state) => const LicensePage(),
      ),
      GoRoute(
        path: AppRoutes.agreement,
        builder: (context, state) => const AgreementPage(),
      ),
      GoRoute(
        path: AppRoutes.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
      GoRoute(
        path: AppRoutes.userAgreement,
        builder: (context, state) => const UserAgreementPage(),
      ),
      GoRoute(
        path: AppRoutes.author,
        builder: (context, state) => const AuthorPage(),
      ),
      GoRoute(path: AppRoutes.campusMap,
      builder: (context, state) => const CampusMapPage())
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
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return AppRouter.router;
});
