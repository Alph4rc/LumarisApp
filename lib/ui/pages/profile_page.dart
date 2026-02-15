import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/core/models/info_model.dart';
import 'package:ios_club_app/core/services/data_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/ui/components/optimized_image.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';

import 'package:ios_club_app/core/models/course_color_manager.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/state/user_store.dart';
import 'package:ios_club_app/ui/components/study_credit_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserStore userStore = UserStore.to;
  final SettingsStore settingsStore = SettingsStore.to;

  bool _isLoading = true;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // 检查是否已有登录信息
    final prefs = PrefsService.instance;
    final username = prefs.getString(PrefsKeys.USERNAME);
    final iosName = prefs.getString(PrefsKeys.CLUB_NAME);

    // 重置 _username
    _username = '';

    if (userStore.isLogin && username != null) {
      _username = username;
    }
    if (userStore.isLoginMember && iosName != null) {
      if (username == iosName) {
        _username = iosName;
      } else if (username != null) {
        _username = '$username & $iosName';
      } else {
        _username = iosName;
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _enterLoginMode({bool isOnlyLoginMember = false}) async {
    final result = await Get.toNamed('/Login', arguments: {'isOnlyLoginMember': isOnlyLoginMember});
    // 如果登录成功返回 true
    if (result == true) {
      _checkLoginStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Obx(() => _buildProfileContent(context)),
    );
  }

  List<ProfileButtonItem> get profileButtonItems {
    return [
      ProfileButtonItem(
          icon: CupertinoIcons.link_circle, title: '建大导航', route: '/Link'),
      ProfileButtonItem(icon: Icons.settings, title: '设置/关于', route: '/About'),
      ProfileButtonItem(
          title: '校车', icon: Icons.directions_bus_rounded, route: '/SchoolBus'),
      ProfileButtonItem(
          icon: Icons.apple,
          title: userStore.isLoginMember ? '社团详情' : '登录社团iMember',
          onPressed: () {
            if (!userStore.isLoginMember) {
              _enterLoginMode(isOnlyLoginMember: true);
            } else {
              Navigator.pushNamed(context, '/iMember');
            }
          }),
      if (!kIsWeb)
        ProfileButtonItem(
            icon: CupertinoIcons.bolt_fill, title: '电费', route: '/Electricity'),
      if (userStore.isLogin)
        ProfileButtonItem(icon: Icons.toc, title: '培养方案', route: '/Program'),
      ProfileButtonItem(
          icon: Icons.monetization_on_outlined, title: '饭卡', route: '/Payment'),
      if (!kIsWeb)
        ProfileButtonItem(
            icon: Icons.wifi_outlined, title: '校园网', route: '/Net'),
      if (!userStore.isLogin)
        ProfileButtonItem(
            icon: Icons.login,
            title: '登录教务系统',
            onPressed: () {
              _enterLoginMode(isOnlyLoginMember: false);
            }),
      ProfileButtonItem(
          icon: Icons.help_outline, title: '帮助', route: '/Helper'),
    ];
  }

  Widget _buildProfileContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Header Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '我的',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  // Optional: Add a profile edit button or settings icon here if needed
                ],
              ),
              const SizedBox(height: 20),

              // User Info Card
              _buildUserInfoCard(context, isDark),
              const SizedBox(height: 32),

              // Services Section
              Text(
                '应用与服务',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? 6 : 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  return profileButtonItems[index].build(context);
                },
                itemCount: profileButtonItems.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),

              if (userStore.isLogin) ...[
                const SizedBox(height: 32),
                Text(
                  '学业概览',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStudyInfoList(),
              ],
              
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.black12,
                width: 1,
              ),
            ),
            child: ClipOval(
              child: LazyLoadImage.assets(
                'assets/icon.webp',
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _username.isNotEmpty ? _username : '未登录',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  userStore.isLogin && userStore.isLoginMember
                      ? '教务系统 & iMember'
                      : userStore.isLogin
                          ? '教务系统已连接'
                          : userStore.isLoginMember
                              ? 'iMember已连接'
                              : '点击登录以访问更多功能',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? Colors.white24 : Colors.black26,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildStudyInfoList() {
    return FutureBuilder(
      future: DataService.getInfoList().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          AppLogger.warning('[ProfilePage] 获取信息列表超时');
          return <InfoModel>[];
        },
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('加载失败: ${snapshot.error}'),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data?.length ?? 0,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) => StudyCreditCard(data: snapshot.data![index]),
        );
      },
    );
  }
}

class ProfileButtonItem {
  final String title;
  final IconData icon;
  String route = '';
  Function? onPressed;

  ProfileButtonItem({
    required this.title,
    required this.icon,
    this.route = '',
    this.onPressed,
  });

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // 生成图标背景色
    final Color baseColor = CourseColorManager.generateSoftColor(title, isDark: false);
    
    return GestureDetector(
      onTap: () {
        if (route.isEmpty) {
          onPressed?.call();
        } else {
          Get.toNamed(route);
        }
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                size: 30,
                color: baseColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }
}
