import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/features/education/models/info_model.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/animations/animations.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/education/services/info_service.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/club_radii.dart';
import 'package:ios_club_app/ui/components/optimized_image.dart';

import 'package:ios_club_app/core/models/course_color_manager.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/state/user_store.dart';
import 'package:ios_club_app/ui/components/study_credit_card.dart';

import 'package:ios_club_app/core/services/secure_storage_service.dart';

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
  int _dataRefreshKey = 0;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // 检查是否已有登录信息
    final prefs = PrefsService.instance;
    final secureStorage = SecureStorageService.instance;
    final username = await secureStorage.read(key: PrefsKeys.USERNAME) ??
        prefs.getString(PrefsKeys.USERNAME);

    // 重置 _username
    _username = '';

    if (username != null && username.isNotEmpty) {
      _username = username;
    }

    if (!userStore.isLogin) {
      // 没有登录信息，进入游客模式
      // await _enterGuestMode(); // 其实这里不需要做什么，只是确认状态
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _enterLoginMode({bool isOnlyLoginMember = false}) async {
    final result = await Get.toNamed('/Login',
        arguments: {'isOnlyLoginMember': isOnlyLoginMember});
    // 如果登录成功返回 true
    if (result == true) {
      await _checkLoginStatus();
      // 强制刷新数据
      if (mounted) {
        setState(() {
          _dataRefreshKey++;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Obx(() => _buildProfileContent()),
    );
  }

  List<ProfileButtonItem> get profileButtonItems {
    return [
      ProfileButtonItem(
          icon: CupertinoIcons.link_circle, title: '建大导航', route: '/Link'),
      ProfileButtonItem(icon: Icons.settings, title: '设置/关于', route: '/About'),
      ProfileButtonItem(
          title: '校车', icon: Icons.directions_bus_rounded, route: '/SchoolBus'),
      if (!kIsWeb)
        ProfileButtonItem(
            icon: CupertinoIcons.bolt_fill, title: '电费', route: '/Electricity'),
      if (userStore.isLogin)
        ProfileButtonItem(icon: Icons.toc, title: '培养方案', route: '/Program'),
      ProfileButtonItem(
          icon: Icons.monetization_on_outlined, title: '饭卡', route: '/Payment'),
      // if (!kIsWeb)
      //   ProfileButtonItem(
      //       icon: Icons.wifi_outlined, title: '校园网', route: '/Net'),
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

  Widget _buildProfileContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    // 判断是否为平板布局（宽度大于600）
    final isTablet = screenWidth > 600;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    LazyLoadImage.assets(
                      'assets/icon.webp',
                      width: 48,
                      height: 48,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _username.isNotEmpty ? _username : '未登录',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          userStore.isLogin ? '教务系统账号' : '游客',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          AnimatedCard(
            delay: const Duration(milliseconds: 100),
            child: ClubCard(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 6 : 3,
                    ),
                    itemBuilder: (context, index) {
                      return AnimatedCard(
                        delay: Duration(milliseconds: 50 * index),
                        child: Center(
                          child: profileButtonItems[index].build(),
                        ),
                      );
                    },
                    itemCount: profileButtonItems.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                  )),
            ),
          ),
          if (userStore.isLogin) const SizedBox(height: 16),
          if (userStore.isLogin)
            FutureBuilder(
                key: ValueKey('info_data_$_dataRefreshKey'),
                // 添加超时保护：最多10秒
                future: InfoService.getInfoList().timeout(
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
                        padding: EdgeInsets.all(16.0),
                        child: CupertinoActivityIndicator(),
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

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) =>
                        StudyCreditCard(data: snapshot.data![index]),
                  );
                }),
        ],
      ),
    );
  }
}

class ProfileButtonItem {
  final String title;
  final IconData icon;
  String route = '';
  Function? onPressed;

  ProfileButtonItem(
      {required this.title,
      required this.icon,
      this.route = '',
      this.onPressed});

  Widget build() {
    return Material(
        borderRadius: ClubRadii.panel,
        color: Colors.transparent,
        child: InkWell(
          borderRadius: ClubRadii.panel,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                    tag: title,
                    child: Icon(icon,
                        size: 32,
                        color: CourseColorManager.generateSoftColor(title,
                            isDark: true))),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                )
              ],
            ),
          ),
          onTap: () {
            if (route.isEmpty) {
              onPressed?.call();
            } else {
              Get.toNamed(route);
            }
          },
        ));
  }
}
