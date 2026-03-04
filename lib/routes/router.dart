import 'package:get/get.dart';
import 'package:ios_club_app/ui/pages/author_page.dart';
import 'package:ios_club_app/ui/pages/easter_egg_page.dart';
import 'package:ios_club_app/ui/pages/helper_page.dart';
import 'package:ios_club_app/ui/pages/license_page.dart';
import 'package:ios_club_app/ui/pages/login_page.dart';
import 'package:ios_club_app/ui/pages/net_page.dart';
import 'package:ios_club_app/ui/pages/electricity_page.dart';
import 'package:ios_club_app/ui/pages/payment_page.dart';
import 'package:ios_club_app/ui/pages/program_page.dart';
import 'package:ios_club_app/core/utils/performance_monitor.dart';

import 'package:ios_club_app/ui/pages/setting_page.dart';
import 'package:ios_club_app/ui/pages/home_page.dart';
import 'package:ios_club_app/ui/pages/link_page.dart';
import 'package:ios_club_app/ui/pages/member_page.dart';
import 'package:ios_club_app/ui/pages/profile_page.dart';
import 'package:ios_club_app/ui/pages/schedule_list_page.dart';
import 'package:ios_club_app/ui/pages/schedulePages/schedule_setting_page.dart';
import 'package:ios_club_app/ui/pages/schedulePages/custom_course_manage_page.dart';
import 'package:ios_club_app/ui/pages/school_bus_page.dart';
import 'package:ios_club_app/ui/pages/score_page.dart';
import 'package:ios_club_app/ui/pages/memberPages/admin_portal_page.dart';
import 'package:ios_club_app/ui/pages/memberPages/article_management_page.dart';
import 'package:ios_club_app/ui/pages/memberPages/category_management_page.dart';
import 'package:ios_club_app/ui/pages/memberPages/data_dashboard_page.dart';
import 'package:ios_club_app/ui/pages/memberPages/logs_monitoring_page.dart';
import 'package:ios_club_app/ui/pages/memberPages/client_app_management_page.dart';

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

        /// 登录页面
        GetPage(
          name: '/Login',
          page: () =>
              PageRenderTimeMonitor(pageName: '登录页面', child: const LoginPage()),
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

        /// 社团管理主入口
        GetPage(
          name: '/AdminPortal',
          page: () => PageRenderTimeMonitor(
              pageName: '社团管理中心', child: const AdminPortalPage()),
        ),

        /// 文章管理页面
        GetPage(
          name: '/ArticleManagement',
          page: () => PageRenderTimeMonitor(
              pageName: '文章管理', child: const ArticleManagementPage()),
        ),

        /// 分类管理页面
        GetPage(
          name: '/CategoryManagement',
          page: () => PageRenderTimeMonitor(
              pageName: '分类管理', child: const CategoryManagementPage()),
        ),

        /// 数据统计仪表板
        GetPage(
          name: '/DataDashboard',
          page: () => PageRenderTimeMonitor(
              pageName: '数据统计', child: const DataDashboardPage()),
        ),

        /// 日志监控页面
        GetPage(
          name: '/LogsMonitoring',
          page: () => PageRenderTimeMonitor(
              pageName: '系统监控', child: const LogsMonitoringPage()),
        ),

        /// 客户端应用管理
        GetPage(
          name: '/ClientAppManagement',
          page: () => PageRenderTimeMonitor(
              pageName: '客户端应用管理', child: const ClientAppManagementPage()),
        ),
      ];
}
