import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HelperPage extends StatefulWidget {
  const HelperPage({super.key});

  @override
  State<HelperPage> createState() => _HelperPageState();
}

class _HelperPageState extends State<HelperPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  final List<String> _tabs = [
    '功能介绍',
    '使用说明',
    '注意事项',
    '关于应用',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _pageController = PageController();

    // 监听 TabController 变化
    _tabController.addListener(_handleTabChange);

    // 获取版本信息
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    // 加载版本信息，以便在需要时使用
    await PackageInfo.fromPlatform();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _pageController.animateToPage(
        _tabController.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '帮助',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: TabBar(
            controller: _tabController,
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          _tabController.animateTo(index);
        },
        children: [
          _buildFeaturesPage(),
          _buildInstructionsPage(),
          _buildNotesPage(),
          _buildAboutPage(),
        ],
      ),
    );
  }

  Widget _buildFeaturesPage() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          ClubCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildFeatureItem(
                  icon: CupertinoIcons.home,
                  title: '首页',
                  description: '信息中心，展示个人信息、课程、待办事项和考试安排',
                  color: const Color(0xFF007AFF),
                  isTablet: isTablet,
                ),
                _buildDivider(),
                _buildFeatureItem(
                  icon: CupertinoIcons.calendar,
                  title: '课程表',
                  description: '管理周课程安排，支持切换校区和设置提醒',
                  color: const Color(0xFF34C759),
                  isTablet: isTablet,
                ),
                _buildDivider(),
                _buildFeatureItem(
                  icon: CupertinoIcons.chart_bar,
                  title: '成绩查询',
                  description: '查看学期成绩单、绩点计算和分析',
                  color: const Color(0xFFFF9500),
                  isTablet: isTablet,
                ),
                _buildDivider(),
                _buildFeatureItem(
                  icon: CupertinoIcons.person,
                  title: '个人资料',
                  description: '展示学号、姓名、学院等个人信息',
                  color: const Color(0xFF5856D6),
                  isTablet: isTablet,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ClubCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildFeatureItem(
                  icon: CupertinoIcons.bus,
                  title: '校园巴士',
                  description: '查看校区间班车时刻表和路线信息',
                  color: const Color(0xFFFF3B30),
                  isTablet: isTablet,
                ),
                _buildDivider(),
                _buildFeatureItem(
                  icon: CupertinoIcons.person_3,
                  title: '成员管理',
                  description: '社团成员可查看信息和项目进度',
                  color: const Color(0xFF00C7BE),
                  isTablet: isTablet,
                ),
                _buildDivider(),
                _buildFeatureItem(
                  icon: CupertinoIcons.book,
                  title: '培养方案',
                  description: '显示专业培养计划和学分要求',
                  color: const Color(0xFFAF52DE),
                  isTablet: isTablet,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ClubCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildFeatureItem(
                  icon: CupertinoIcons.bolt,
                  title: '电费查询',
                  description: '查看宿舍电量和用电历史记录',
                  color: const Color(0xFFFFCC00),
                  isTablet: isTablet,
                ),
                _buildDivider(),
                _buildFeatureItem(
                  icon: CupertinoIcons.creditcard,
                  title: '饭卡消费',
                  description: '查看饭卡余额和消费明细',
                  color: const Color(0xFFFF2D55),
                  isTablet: isTablet,
                ),
                _buildDivider(),
                _buildFeatureItem(
                  icon: CupertinoIcons.wifi,
                  title: '校园网',
                  description: '查看网络流量使用情况和统计',
                  color: const Color(0xFF5AC8FA),
                  isTablet: isTablet,
                ),
                _buildDivider(),
                _buildFeatureItem(
                  icon: CupertinoIcons.link,
                  title: '常用链接',
                  description: '收集教务系统等常用工具链接',
                  color: const Color(0xFF007AFF),
                  isTablet: isTablet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsPage() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          ClubCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInstructionItem(
                  icon: CupertinoIcons.person_circle,
                  title: '登录与账户',
                  description: '首次使用需登录教务系统账户，社团成员可使用 iMember 账户',
                  color: const Color(0xFF007AFF),
                  isTablet: isTablet,
                ),
                _buildDivider(),
                _buildInstructionItem(
                  icon: CupertinoIcons.calendar_badge_plus,
                  title: '课程管理',
                  description: '进入课程表查看当周课程，左右滑动切换周次，点击课程查看详情',
                  color: const Color(0xFF34C759),
                  isTablet: isTablet,
                ),
                _buildDivider(),
                _buildInstructionItem(
                  icon: CupertinoIcons.bell,
                  title: '日程提醒',
                  description: '在设置中开启课程提醒，应用会在上课前发送通知提醒',
                  color: const Color(0xFFFF9500),
                  isTablet: isTablet,
                ),
                _buildDivider(),
                _buildInstructionItem(
                  icon: CupertinoIcons.arrow_2_circlepath,
                  title: '数据同步',
                  description: '应用自动同步教务系统数据，需要网络连接。下拉刷新可手动更新',
                  color: const Color(0xFF5AC8FA),
                  isTablet: isTablet,
                ),
                _buildDivider(),
                _buildInstructionItem(
                  icon: CupertinoIcons.square_grid_2x2,
                  title: '桌面小组件',
                  description: '在桌面长按添加应用小组件，快速查看课程信息（支持 iOS/Android）',
                  color: const Color(0xFFAF52DE),
                  isTablet: isTablet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          ClubCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildNoteItem(
                  icon: CupertinoIcons.wifi,
                  text: '部分功能需要连接校园网才能正常使用',
                  color: const Color(0xFF5AC8FA),
                ),
                const SizedBox(height: 16),
                _buildNoteItem(
                  icon: CupertinoIcons.arrow_clockwise,
                  text: '请保持应用更新以获得最新功能和修复',
                  color: const Color(0xFF34C759),
                ),
                const SizedBox(height: 16),
                _buildNoteItem(
                  icon: CupertinoIcons.exclamationmark_triangle,
                  text: '数据不准确时，请检查是否正确登录教务系统',
                  color: const Color(0xFFFF9500),
                ),
                const SizedBox(height: 16),
                _buildNoteItem(
                  icon: CupertinoIcons.chat_bubble_text,
                  text: '遇到问题可通过设置页面进行反馈',
                  color: const Color(0xFF007AFF),
                ),
                const SizedBox(height: 16),
                _buildNoteItem(
                  icon: CupertinoIcons.lock_shield,
                  text: '应用不会收集或上传您的个人隐私信息',
                  color: const Color(0xFF5856D6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutPage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // 应用信息卡片
          const SizedBox(height: 16),
          // 平台支持卡片
          ClubCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF34C759).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        CupertinoIcons.device_phone_portrait,
                        size: 20,
                        color: Color(0xFF34C759),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '平台支持',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '跨平台应用，支持以下平台：',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                ...[
                  'iOS（iPhone、iPad）',
                  'Android',
                  'Windows',
                  'macOS',
                  'Linux',
                  'Web',
                  '微信小程序',
                ].map((platform) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.checkmark_circle_fill,
                            size: 18,
                            color: const Color(0xFF34C759),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            platform,
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 开源信息卡片
          ClubCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9500).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        CupertinoIcons.heart,
                        size: 20,
                        color: Color(0xFFFF9500),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '开源项目',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '本应用基于 MIT 许可证开源',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '仓库地址：',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'gitee.com/luckyfishisdashen/iOSClub.AppMobile',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF007AFF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isTablet,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 17 : 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isTablet,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 17 : 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: isDark ? Colors.grey[800] : Colors.grey[300],
      ),
    );
  }
}
