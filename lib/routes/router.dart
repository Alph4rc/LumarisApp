import 'package:get/get.dart';
import 'package:ios_club_app/ui/../ui/pages/author_page.dart';
import 'package:ios_club_app/ui/../ui/pages/easter_egg_page.dart';
import 'package:ios_club_app/ui/../ui/pages/helper_page.dart';
import 'package:ios_club_app/ui/../ui/pages/license_page.dart';
import 'package:ios_club_app/ui/../ui/pages/net_page.dart';
import 'package:ios_club_app/ui/../ui/pages/electricity_page.dart';
import 'package:ios_club_app/ui/../ui/pages/payment_page.dart';
import 'package:ios_club_app/ui/../ui/pages/program_page.dart';
import 'package:ios_club_app/core/utils/performance_monitor.dart';

import '../ui/pages/setting_page.dart';
import '../ui/pages/home_page.dart';
import '../ui/pages/link_page.dart';
import '../ui/pages/member_page.dart';
import '../ui/pages/profile_page.dart';
import '../ui/pages/schedule_list_page.dart';
import '../ui/pages/schedule/pages/schedule_setting_page.dart';
import '../ui/pages/schedule/pages/custom_course_manage_page.dart';
import '../ui/pages/school_bus_page.dart';
import '../ui/pages/score_page.dart';

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
          page: () =>
              PageRenderTimeMonitor(pageName: '首页', child: const HomePage()),
        ),

        /// 课表页面
        GetPage(
          name: '/Schedule',
          page: () => PageRenderTimeMonitor(
              pageName: '课表页面', child: const ScheduleListPage()),
        ),

        /// 成绩页面
        GetPage(
          name: '/Score',
          page: () =>
              PageRenderTimeMonitor(pageName: '成绩页面', child: const ScorePage()),
        ),

        /// 个人中心页面
        GetPage(
          name: '/Profile',
          page: () => PageRenderTimeMonitor(
              pageName: '个人中心页面', child: const ProfilePage()),
        ),

        /// 链接页面
        GetPage(
          name: '/Link',
          page: () =>
              PageRenderTimeMonitor(pageName: '链接页面', child: const LinkPage()),
        ),

        /// 设置页面
        GetPage(
          name: '/About',
          page: () => PageRenderTimeMonitor(
              pageName: '设置页面', child: const SettingPage()),
        ),

        /// 课表设置页面
        GetPage(
          name: '/ScheduleSetting',
          page: () => PageRenderTimeMonitor(
              pageName: '课表设置页面', child: const ScheduleSettingPage()),
        ),

        /// 自定义课程管理页面
        GetPage(
          name: '/CustomCourseManage',
          page: () => PageRenderTimeMonitor(
              pageName: '自定义课程管理页面', child: const CustomCourseManagePage()),
        ),

        /// 校车页面
        GetPage(
          name: '/SchoolBus',
          page: () => PageRenderTimeMonitor(
              pageName: '校车页面', child: const SchoolBusPage()),
        ),

        /// 成员页面
        GetPage(
          name: '/iMember',
          page: () => PageRenderTimeMonitor(
              pageName: '成员页面', child: const MemberPage()),
        ),

        /// 培养方案页面
        GetPage(
          name: '/Program',
          page: () => PageRenderTimeMonitor(
              pageName: '培养方案页面', child: const ProgramPage()),
        ),

        /// 电费页面
        GetPage(
          name: '/Electricity',
          page: () => PageRenderTimeMonitor(
              pageName: '电费页面', child: const ElectricityPage()),
        ),

        /// 饭卡页面
        GetPage(
          name: '/Payment',
          page: () =>
              PageRenderTimeMonitor(pageName: '饭卡页面', child: PaymentPage()),
        ),

        /// 网络页面
        GetPage(
          name: '/Net',
          page: () =>
              PageRenderTimeMonitor(pageName: '网络页面', child: const NetPage()),
        ),

        /// 帮助页面
        GetPage(
            name: '/Helper',
            page: () =>
                PageRenderTimeMonitor(pageName: '帮助页面', child: HelperPage())),

        /// 彩蛋页面
        GetPage(
          name: '/Egg',
          page: () => PageRenderTimeMonitor(
              pageName: '彩蛋页面', child: const EasterEggPage()),
        ),

        /// 许可证页面
        GetPage(
          name: '/License',
          page: () => PageRenderTimeMonitor(
              pageName: '许可证页面', child: const LicensePage()),
        ),

        /// 作者页面
        GetPage(
          name: '/Author',
          page: () => PageRenderTimeMonitor(
              pageName: '作者页面', child: const AuthorPage()),
        ),
      ];
}
