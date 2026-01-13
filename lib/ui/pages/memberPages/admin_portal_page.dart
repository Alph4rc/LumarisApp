import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/ui/pages/memberPages/article_management_page.dart';
import 'package:ios_club_app/ui/pages/memberPages/category_management_page.dart';
import 'package:ios_club_app/ui/pages/memberPages/client_app_management_page.dart';
import 'package:ios_club_app/ui/pages/memberPages/data_dashboard_page.dart';
import 'package:ios_club_app/ui/pages/memberPages/logs_monitoring_page.dart';
import 'package:ios_club_app/ui/pages/memberPages/member_data_page.dart';
import 'package:ios_club_app/ui/pages/memberPages/department_page.dart';
import 'package:ios_club_app/ui/pages/memberPages/project_page.dart';
import 'package:ios_club_app/ui/pages/memberPages/task_page.dart';
import 'package:ios_club_app/ui/pages/memberPages/resource_page.dart';
import 'package:ios_club_app/ui/pages/memberPages/staff_data_page.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/components/club_card.dart';

/// 社团管理主入口页面
/// 提供所有管理功能的统一入口
class AdminPortalPage extends StatelessWidget {
  const AdminPortalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const ClubAppBar(
        title: '社团管理中心',
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 核心管理模块
                _buildSectionHeader('核心管理', Icons.settings),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildManagementCard(
                        context,
                        title: '成员管理',
                        subtitle: '查看和管理社团成员',
                        icon: Icons.people,
                        color: Colors.blue,
                        onTap: () => Get.to(() => const MemberDataPage()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildManagementCard(
                        context,
                        title: '部门管理',
                        subtitle: '组织架构与部门',
                        icon: Icons.business,
                        color: Colors.green,
                        onTap: () => Get.to(() => const DepartmentPage()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildManagementCard(
                        context,
                        title: '项目管理',
                        subtitle: '社团项目与任务',
                        icon: Icons.work,
                        color: Colors.orange,
                        onTap: () => Get.to(() => const ProjectPage()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildManagementCard(
                        context,
                        title: '部员管理',
                        subtitle: '部门成员信息',
                        icon: Icons.person,
                        color: Colors.purple,
                        onTap: () => Get.to(() => const StaffDataPage()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 内容管理模块
                _buildSectionHeader('内容管理', Icons.article),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildManagementCard(
                        context,
                        title: '文章管理',
                        subtitle: '发布和管理文章',
                        icon: Icons.description,
                        color: Colors.teal,
                        onTap: () => Get.to(() => const ArticleManagementPage()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildManagementCard(
                        context,
                        title: '分类管理',
                        subtitle: '文章分类与排序',
                        icon: Icons.category,
                        color: Colors.indigo,
                        onTap: () => Get.to(() => const CategoryManagementPage()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildManagementCard(
                        context,
                        title: '资源管理',
                        subtitle: '社团资源库',
                        icon: Icons.folder,
                        color: Colors.amber,
                        onTap: () => Get.to(() => const ResourcePage()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildManagementCard(
                        context,
                        title: '任务管理',
                        subtitle: '待办事项',
                        icon: Icons.task_alt,
                        color: Colors.pink,
                        onTap: () => Get.to(() => const TaskPage()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 数据分析模块
                _buildSectionHeader('数据分析', Icons.analytics),
                const SizedBox(height: 12),
                _buildWideManagementCard(
                  context,
                  title: '数据统计仪表板',
                  subtitle: '成员数据可视化分析',
                  icon: Icons.dashboard,
                  color: Colors.deepPurple,
                  onTap: () => Get.to(() => const DataDashboardPage()),
                ),
                const SizedBox(height: 24),

                // 系统管理模块
                _buildSectionHeader('系统管理', Icons.admin_panel_settings),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildManagementCard(
                        context,
                        title: '日志监控',
                        subtitle: '系统日志与性能',
                        icon: Icons.monitor_heart,
                        color: Colors.red,
                        onTap: () => Get.to(() => const LogsMonitoringPage()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildManagementCard(
                        context,
                        title: '客户端应用',
                        subtitle: 'OAuth应用管理',
                        icon: Icons.apps,
                        color: Colors.cyan,
                        onTap: () => Get.to(() => const ClientAppManagementPage()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 快捷统计卡片
                _buildQuickStatsCard(context, isDarkMode),
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildManagementCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ClubCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDarkMode ? 0.3 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWideManagementCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ClubCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDarkMode ? 0.3 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard(BuildContext context, bool isDarkMode) {
    return ClubCard(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
                    Colors.blue.withValues(alpha: 0.3),
                    Colors.purple.withValues(alpha: 0.3),
                  ]
                : [
                    Colors.blue.withValues(alpha: 0.1),
                    Colors.purple.withValues(alpha: 0.1),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: isDarkMode ? Colors.yellow[200] : Colors.orange,
                ),
                const SizedBox(width: 8),
                const Text(
                  '管理提示',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '欢迎使用社团管理中心！',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• 可以通过文章管理发布社团动态\n'
              '• 使用数据仪表板查看成员统计\n'
              '• 日志监控可以帮助追踪系统状态\n'
              '• 所有管理操作都会被记录',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
