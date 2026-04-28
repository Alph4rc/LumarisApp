import 'package:get/get.dart';
import 'package:ios_club_app/ui/pages/author_page.dart';
import 'package:ios_club_app/ui/pages/easter_egg_page.dart';
import 'package:ios_club_app/ui/pages/helper_page.dart';
import 'package:ios_club_app/ui/pages/license_page.dart';
import 'package:ios_club_app/ui/pages/agreement_page.dart';
import 'package:ios_club_app/ui/pages/privacy_policy_page.dart';
import 'package:ios_club_app/ui/pages/user_agreement_page.dart';
import 'package:ios_club_app/ui/pages/login_page.dart';
import 'package:ios_club_app/ui/pages/net_page.dart';
import 'package:ios_club_app/ui/pages/electricity_page.dart';
import 'package:ios_club_app/ui/pages/payment_page.dart';
import 'package:ios_club_app/ui/pages/program_page.dart';

import 'package:ios_club_app/ui/pages/setting_page.dart';
import 'package:ios_club_app/ui/pages/home_page.dart';
import 'package:ios_club_app/ui/pages/link_page.dart';
import 'package:ios_club_app/ui/pages/profile_page.dart';
import 'package:ios_club_app/ui/pages/schedule_list_page.dart';
import 'package:ios_club_app/ui/pages/schedulePages/schedule_setting_page.dart';
import 'package:ios_club_app/ui/pages/schedulePages/custom_course_manage_page.dart';
import 'package:ios_club_app/ui/pages/school_bus_page.dart';
import 'package:ios_club_app/ui/pages/score_page.dart';

/// 应用路由配置类
///
/// 管理应用中所有页面的路由信息，使用GetX框架进行路由管理。
/// 包含所有页面的路由名称和对应的页面组件。
class AppRouter {
  /// 获取所有页面路由配置
  ///
  /// 返回一个包含所有页面路由信息的列表，每个路由包含名称和对应的页面组件。
  ///
  /// @return 页面路由配置列表
  static List<GetPage> get getPages => [
        /// 首页
        GetPage(
          name: '/',
          page: () => const HomePage(),
        ),

        /// 课表页面
        GetPage(
          name: '/Schedule',
          page: () => const ScheduleListPage(),
        ),

        /// 成绩页面
        GetPage(
          name: '/Score',
          page: () => const ScorePage(),
        ),

        /// 个人中心页面
        GetPage(
          name: '/Profile',
          page: () => const ProfilePage(),
        ),

        /// 登录页面
        GetPage(
          name: '/Login',
          page: () => const LoginPage(),
        ),

        /// 链接页面
        GetPage(
          name: '/Link',
          page: () => const LinkPage(),
        ),

        /// 设置页面
        GetPage(
          name: '/About',
          page: () => const SettingPage(),
        ),

        /// 课表设置页面
        GetPage(
          name: '/ScheduleSetting',
          page: () => const ScheduleSettingPage(),
        ),

        /// 自定义课程管理页面
        GetPage(
          name: '/CustomCourseManage',
          page: () => const CustomCourseManagePage(),
        ),

        /// 校车页面
        GetPage(
          name: '/SchoolBus',
          page: () => const SchoolBusPage(),
        ),

        /// 培养方案页面
        GetPage(
          name: '/Program',
          page: () => const ProgramPage(),
        ),

        /// 电费页面
        GetPage(
          name: '/Electricity',
          page: () => const ElectricityPage(),
        ),

        /// 饭卡页面
        GetPage(
          name: '/Payment',
          page: () => PaymentPage(),
        ),

        /// 网络页面
        GetPage(
          name: '/Net',
          page: () => const NetPage(),
        ),

        /// 帮助页面
        GetPage(name: '/Helper', page: () => HelperPage()),

        /// 彩蛋页面
        GetPage(
          name: '/Egg',
          page: () => const EasterEggPage(),
        ),

        /// 许可证页面
        GetPage(
          name: '/License',
          page: () => const LicensePage(),
        ),

        /// 协议授权页面
        GetPage(
          name: '/Agreement',
          page: () => const AgreementPage(),
        ),

        /// 隐私协议页面
        GetPage(
          name: '/PrivacyPolicy',
          page: () => const PrivacyPolicyPage(),
        ),

        /// 用户协议页面
        GetPage(
          name: '/UserAgreement',
          page: () => const UserAgreementPage(),
        ),

        /// 作者页面
        GetPage(
          name: '/Author',
          page: () => const AuthorPage(),
        ),
      ];
}
