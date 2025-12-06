import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ios_club_app/features/club/models/resource_model.dart';
import 'package:ios_club_app/features/club/services/data_centre_service.dart';
import 'package:ios_club_app/features/club/services/department_service.dart';
import 'package:ios_club_app/features/club/services/project_service.dart';
import 'package:ios_club_app/features/club/services/resource_service.dart';
import 'package:ios_club_app/features/club/services/staff_service.dart';

import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/components/memberPages/member_data_page.dart';
import 'package:ios_club_app/ui/components/memberPages/staff_data_page.dart';

// 新增导入
import 'package:ios_club_app/ui/components/memberPages/department_page.dart';
import 'package:ios_club_app/ui/components/memberPages/project_page.dart';
import 'package:ios_club_app/ui/components/memberPages/task_page.dart';
import 'package:ios_club_app/ui/components/memberPages/resource_page.dart';

// 使用新的模块化服务
import 'package:ios_club_app/features/club/services/user_service.dart';
import 'package:ios_club_app/ui/components/platform_dialog.dart';

class MemberPage extends StatelessWidget {
  const MemberPage({super.key});

  // 新增方法：获取成员信息
  Future<Map<String, dynamic>> _fetchMemberInfo() async {
    // 使用新的 UserService 获取用户数据
    final userData = await UserService.getUserData();

    // 保持与原有方法兼容的返回格式
    final data = <String, dynamic>{};

    if (userData != null) {
      // 根据MemberModel结构映射数据（注意API返回的是大写开头的字段）
      data['memberData'] = {
        'userName': userData.userName,
        'userId': userData.userId,
        'phoneNum': userData.phoneNum,
        'academy': userData.academy,
        'politicalLandscape': userData.politicalLandscape,
        'gender': userData.gender,
        'className': userData.className,
        'joinTime': userData.joinTime,
        'identity': userData.identity,
      };

      data['info'] = {
        'userName': userData.userName,
        'userId': userData.userId,
        'phoneNum': userData.phoneNum,
        'academy': userData.academy,
        'politicalLandscape': userData.politicalLandscape,
        'gender': userData.gender,
        'className': userData.className,
        'joinTime': userData.joinTime,
        'identity': userData.identity,
        // 添加默认值以避免页面错误
        'tasks': [],
        'projects': [],
        'departments': [],
        'total': 0,
        'staffsCount': 0,
        'resources': [],
      };
    } else {
      // 如果没有用户数据，提供默认结构
      data['memberData'] = {
        'userName': '',
        'userId': '',
        'phoneNum': '',
        'academy': '',
        'politicalLandscape': '',
        'gender': '',
        'className': '',
        'joinTime': '',
        'identity': 'Member',
      };

      data['info'] = {
        'userName': '',
        'userId': '',
        'phoneNum': '',
        'academy': '',
        'politicalLandscape': '',
        'gender': '',
        'className': '',
        'joinTime': '',
        'identity': 'Member',
        'tasks': [],
        'projects': [],
        'departments': [],
        'total': 0,
        'staffsCount': 0,
        'resources': [],
      };
    }

    if (userData != null && userData.identity != 'Member') {
      if (userData.identity != 'Department') {
        data['info']['departments'] =
            await DepartmentService.getAllDepartments();
        final dataCentre = await DataCentreService.getData();
        data['info']['total'] = dataCentre?.members ?? 0;
        data['info']['staffsCount'] = dataCentre?.staffs ?? 0;
        data['info']['resources'] = await ResourceService.getAllResources();
        data['info']['projects'] = await ProjectService.getAllProjects();
      } else {
        final res = await StaffService.getStaffByUserId(userData.userId);
        data['info']['projects'] = res?.projects ?? [];
        data['info']['tasks'] = res?.tasks ?? [];
      }
    } else if (userData != null && userData.identity == 'Member') {
      data['info']['tasks'] = await UserService.getUserTodos();
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: ClubAppBar(title: '社团详情'),
      body: CustomScrollView(
        slivers: [
          // 主内容
          SliverToBoxAdapter(
            child: FutureBuilder(
              future: _fetchMemberInfo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDarkMode ? Colors.white : Colors.blue,
                        ),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return SizedBox(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 60,
                            color: isDarkMode ? Colors.redAccent : Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '加载失败',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            style: TextStyle(
                              fontSize: 15,
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final data = snapshot.data!;
                final identity = data['memberData']['identity'] ?? 'Member';
                final memberData = data['memberData'];
                final infoData = data['info'];
                String role = _mapIdentityToRole(identity);

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // 用户信息卡片
                      _buildUserInfoCard(
                          memberData, role, isTablet, isDarkMode),

                      if (identity != 'Member') ...[
                        const SizedBox(height: 20),
                        _buildTaskSection(infoData, isDarkMode, context),
                        const SizedBox(height: 20),
                        _buildProjectSection(infoData, isDarkMode, context),
                      ],

                      if (identity != 'Member' && identity != 'Department') ...[
                        const SizedBox(height: 20),
                        _buildDepartmentSection(infoData, isDarkMode, context),
                        const SizedBox(height: 20),
                        _buildDataCenterSection(infoData, context, isDarkMode),
                        const SizedBox(height: 20),
                        _buildResourceSection(infoData, context, isDarkMode),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 用户信息卡片
  Widget _buildUserInfoCard(
      Map memberData, String role, bool isTablet, bool isDarkMode) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? const Color(0xFF101010).withValues(alpha: 0.3)
                : const Color(0xFFA0A0A0).withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 头像容器
          Image(
              image: AssetImage('assets/${memberData['gender']}生.webp'),
              height: isTablet ? 200 : 120),
          const SizedBox(height: 20),
          // 用户名
          Text(
            memberData['userName'],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : Colors.black,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          // ID 和身份标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white10 : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'ID: ${memberData['userId']}',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              role,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 任务部分
  Widget _buildTaskSection(Map infoData, bool isDarkMode, context) {
    final tasks = jsonDecode(jsonEncode(infoData['tasks']));
    return _buildSection(
      title: '我的任务',
      icon: Icons.check_circle_outline,
      isEmpty: tasks.isEmpty,
      emptyMessage: '您的任务都已经完成了',
      emptySubtitle: '可以好好休息了',
      items: tasks,
      isDarkMode: isDarkMode,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TaskPage()),
        );
      },
      context: context,
    );
  }

  // 项目部分
  Widget _buildProjectSection(Map infoData, bool isDarkMode, context) {
    final projects = jsonDecode(jsonEncode(infoData['projects']));
    return _buildSection(
      title: '我的项目',
      icon: Icons.folder_outlined,
      isEmpty: projects.isEmpty,
      emptyMessage: '您的项目都已经完成了',
      emptySubtitle: '可以好好休息了',
      items: projects,
      isDarkMode: isDarkMode,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProjectPage()),
        );
      },
      context: context,
    );
  }

  // 部门部分
  Widget _buildDepartmentSection(Map infoData, bool isDarkMode, context) {
    final departments = jsonDecode(jsonEncode(infoData['departments']));
    return _buildSection(
      title: '社团部门',
      icon: Icons.group_outlined,
      items: departments
          .map((d) => {
                'title': d['name'],
                'description': d['description'],
              })
          .toList(),
      isDarkMode: isDarkMode,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DepartmentPage()),
        );
      },
      context: context,
    );
  }

  // 通用部分构建器
  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<dynamic> items,
    bool isEmpty = false,
    String? emptyMessage,
    String? emptySubtitle,
    required bool isDarkMode,
    Function(BuildContext context)? onTap,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onTap != null ? () => onTap(context) : null,
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? const Color(0xFF101010).withValues(alpha: 0.3)
                  : const Color(0xFFA0A0A0).withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: isDarkMode ? Colors.white54 : Colors.black38,
                    ),
                ],
              ),
            ),
            if (isEmpty && emptyMessage != null)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 48,
                        color: isDarkMode ? Colors.green : Colors.green,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        emptyMessage,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      if (emptySubtitle != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          emptySubtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            else if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: isDarkMode ? Colors.white38 : Colors.black38,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无内容',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...items.map((item) => _buildListItem(
                    item['title'] ?? item['name'],
                    item['description'],
                    isDarkMode,
                  )),
          ],
        ),
      ),
    );
  }

  // 列表项
  Widget _buildListItem(String title, String subtitle, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.1)
                : const Color(0xFFE5E5E5),
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: 20,
          color: isDarkMode ? Colors.white54 : Colors.black38,
        ),
      ),
    );
  }

  // 数据中心
  Widget _buildDataCenterSection(
      Map infoData, BuildContext context, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade700,
            Colors.blue.shade500,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart_outlined,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '数据中心',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDataCard(
                  '当前成员', '${infoData['total']}', Icons.group_outlined,
                  onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MemberDataPage()),
                );
              }),
              _buildDataCard(
                  '部员数量', '${infoData['staffsCount']}', Icons.person_outlined,
                  onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StaffDataPage()),
                );
              }),
              _buildDataCard(
                  '项目数量',
                  '${(infoData['projects'] as List<dynamic>).length}',
                  Icons.folder_outlined),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDataCard(
                  '任务数量',
                  '${(infoData['tasks'] as List<dynamic>).length}',
                  Icons.check_circle_outline),
              _buildDataCard(
                  '资源数量',
                  '${(infoData['resources'] as List<dynamic>).length}',
                  Icons.inventory_2_outlined),
              _buildDataCard(
                  '部门数量',
                  '${(infoData['departments'] as List<dynamic>).length}',
                  Icons.business_outlined),
            ],
          ),
        ],
      ),
    );
  }

  // 数据卡片
  Widget _buildDataCard(String label, String value, IconData icon,
      {GestureTapCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 资源部分
  Widget _buildResourceSection(
      Map infoData, BuildContext context, bool isDarkMode) {
    final resources = infoData['resources'] as List<ResourceModel>;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ResourcePage()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? const Color(0xFF101010).withValues(alpha: 0.3)
                  : const Color(0xFFA0A0A0).withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '社团资源',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: isDarkMode ? Colors.white54 : Colors.black38,
                  ),
                ],
              ),
            ),
            if (resources.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inventory_outlined,
                        size: 48,
                        color: isDarkMode ? Colors.white38 : Colors.black38,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '当前没有资源',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '去添加一个',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...resources.map((resource) => _buildResourceItem(
                    resource,
                    context,
                    isDarkMode,
                  )),
          ],
        ),
      ),
    );
  }

  // 资源项
  Widget _buildResourceItem(
      ResourceModel resource, BuildContext context, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.1)
                : const Color(0xFFE5E5E5),
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        title: Text(
          resource.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          resource.description ?? '暂无描述',
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        trailing: Icon(
          Icons.open_in_new_outlined,
          size: 20,
          color: Colors.blue,
        ),
        onTap: () {
          // 使用 PlatformDialog 显示跨平台对话框
          PlatformDialog.showConfirmDialog(
            context,
            title: resource.name,
            content: resource.description ?? '暂无描述',
            confirmText: '关闭',
          );
        },
      ),
    );
  }

  // 身份映射
  String _mapIdentityToRole(String identity) {
    switch (identity) {
      case 'Founder':
        return '创始人';
      case 'President':
        return '社长/副社长/团支书';
      case 'Minister':
        return '部长/副部长';
      case 'Department':
        return '部员成员';
      default:
        return '普通成员';
    }
  }
}
