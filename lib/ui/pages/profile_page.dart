import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/core/models/user_data.dart';
import 'package:ios_club_app/core/services/data_service.dart';
import 'package:ios_club_app/features/education/services/edu_service.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/optimized_image.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ios_club_app/core/models/course_color_manager.dart';
import 'package:ios_club_app/core/services/club_service.dart';
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

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = true;
  bool _isLoginMember = false;
  bool _isOnlyLoginMember = false;
  bool _showLoginForm = false; // 新增状态，控制是否显示登录表单
  String _username = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // 检查是否已有登录信息
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(PrefsKeys.USERNAME);
    final iosName = prefs.getString(PrefsKeys.CLUB_NAME);

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

    if (!userStore.isLogin && !userStore.isLoginMember) {
      // 没有登录信息，进入游客模式
      await _enterGuestMode();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      showClubSnackBar(
        context,
        const Text('用户名和密码不能为空'),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool eduLoginSuccess = true;
    bool clubLoginSuccess = true;

    // 登录教务系统账号
    if (!_isOnlyLoginMember) {
      eduLoginSuccess = await _loginToEduSystem();
    }

    // 登录社团账号
    if (_isOnlyLoginMember || _isLoginMember) {
      clubLoginSuccess = await _loginToClub();
    }

    // 检查登录结果
    if (!eduLoginSuccess || !clubLoginSuccess) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // 保存登录信息
    await _saveLoginInfo();

    // 更新UI状态
    setState(() {
      _isLoading = false;
      _isOnlyLoginMember = false;
      _showLoginForm = false;
    });

    // 清空输入框
    _usernameController.clear();
    _passwordController.clear();
    if (_isLoginMember) {
      _nameController.clear();
    }
  }

  /// 登录教务系统
  Future<bool> _loginToEduSystem() async {
    bool result = false;
    for (var i = 0; i < 3; i++) {
      result = await EduService.loginFromData(
        _usernameController.text,
        _passwordController.text,
      );
      if (result) break;
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        showClubSnackBar(
          context,
          const Text('正在重试'),
        );
      }
    }

    if (!result && mounted) {
      showClubSnackBar(
        context,
        const Text('登录失败，请检查用户名和密码'),
      );
    }

    if (result) {
      setState(() {
        _username = _usernameController.text;
      });
    }

    return result;
  }

  /// 登录社团账号
  Future<bool> _loginToClub() async {
    // 验证输入
    if (_isOnlyLoginMember && _usernameController.text.isEmpty) {
      if (mounted) {
        showClubSnackBar(
          context,
          const Text('登录社团账号时姓名不能为空'),
        );
      }
      return false;
    }

    if (_isLoginMember && _nameController.text.isEmpty) {
      if (mounted) {
        showClubSnackBar(
          context,
          const Text('登录社团账号时姓名不能为空'),
        );
      }
      return false;
    }

    bool result = false;
    if (_isOnlyLoginMember) {
      // 仅登录社团账号：用户名(姓名)和密码(学号)
      result = await ClubService.loginMember(
        _usernameController.text,
        _passwordController.text,
      );
    } else if (_isLoginMember) {
      // 同时登录两个账号：姓名和学号
      result = await ClubService.loginMember(
        _nameController.text,
        _usernameController.text,
      );
    }

    if (!result && mounted) {
      showClubSnackBar(
        context,
        const Text('社团账号登陆失败'),
      );
    }

    if (result) {
      setState(() {
        _username = _isOnlyLoginMember
            ? _usernameController.text
            : _nameController.text;
      });
    }

    return result;
  }

  /// 保存登录信息
  Future<void> _saveLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();

    if (_isOnlyLoginMember) {
      // 仅登录社团账号
      await prefs.setString(PrefsKeys.CLUB_NAME, _usernameController.text);
      await prefs.setString(PrefsKeys.CLUB_ID, _passwordController.text);
      userStore.setLoginMember();
    } else if (!_isOnlyLoginMember && !_isLoginMember) {
      // 仅登录教务系统
      await prefs.setString(PrefsKeys.USERNAME, _usernameController.text);
      await prefs.setString(PrefsKeys.PASSWORD, _passwordController.text);
      final userDataString = prefs.getString(PrefsKeys.USER_DATA);
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        userStore.setUserData(UserData.fromJson(userData));
      }
    }

    // 同时登录两个账号的情况
    if (_isLoginMember) {
      await prefs.setString(PrefsKeys.CLUB_NAME, _nameController.text);
      await prefs.setString(PrefsKeys.CLUB_ID, _passwordController.text);
      userStore.setLoginMember();
    }
  }

  Future<void> _enterGuestMode() async {
    // 更新 UserStore 状态
    await userStore.logout();

    setState(() {
      _isLoading = false;
      _showLoginForm = false; // 确保隐藏登录表单
    });
  }

  Future<void> _enterLoginMode() async {
    setState(() {
      _isLoading = false;
      _showLoginForm = true; // 显示登录表单
    });

    _usernameController.clear();
    _passwordController.clear();
    _nameController.clear();
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

    // 根据状态决定显示登录表单还是用户信息界面
    if (_showLoginForm) {
      return Scaffold(
        body: _buildLoginForm(),
      );
    } else {
      return Scaffold(
        body: Obx(() => _buildProfileContent()),
      );
    }
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
        child: Column(
      children: [
        if (_isOnlyLoginMember)
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          _isOnlyLoginMember = false;
                          _passwordController.clear();
                          _showLoginForm = false; // 添加这行代码来隐藏登录表单
                        });
                      },
                      icon: const Icon(Icons.arrow_back)),
                  const Text(
                    '登录社团账号',
                    style: TextStyle(fontSize: 22),
                  ),
                  SizedBox(
                    width: 40,
                  )
                ],
              )),
        if (!_isOnlyLoginMember)
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            _isLoginMember = false;
                            _nameController.clear();
                            _showLoginForm = false; // 添加这行代码来隐藏登录表单
                          });
                        },
                        icon: const Icon(Icons.arrow_back)),
                    const Text(
                      '登录教务系统账号',
                      style: TextStyle(fontSize: 22),
                    ),
                    SizedBox(
                      width: 40,
                    )
                  ])),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LazyLoadImage.assets(
                  'assets/icon.webp',
                  width: 160,
                  height: 160,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800] // 暗色模式下的背景
                        : Colors.grey[100],
                    prefixIcon: Icon(Icons.person_outline,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[300] // 暗色模式下的图标颜色
                            : Colors.grey[700] // 亮色模式下的图标颜色
                        ),
                    hintText: '学号',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 密码输入框
                TextField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800] // 暗色模式下的背景
                        : Colors.grey[100],
                    prefixIcon: Icon(Icons.lock_outline,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[300] // 暗色模式下的图标颜色
                            : Colors.grey[700] // 亮色模式下的图标颜色
                        ),
                    hintText: _isOnlyLoginMember ? 'iMember 密码（初始值为手机号）' : '统一身份认证密码',
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                if (_isLoginMember) const SizedBox(height: 16),
                if (_isLoginMember)
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800] // 暗色模式下的背景
                          : Colors.grey[100],
                      prefixIcon: Icon(Icons.person_outline,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300] // 暗色模式下的图标颜色
                              : Colors.grey[700] // 亮色模式下的图标颜色
                          ),
                      hintText: '姓名（登录社团账号时必填）',
                      //李嘉俊
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                if (!_isOnlyLoginMember)
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!userStore.isLoginMember)
                          Row(
                            children: [
                              Checkbox(
                                value: _isLoginMember,
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _isLoginMember = value;
                                  });
                                },
                              ),
                              const Text('登录社团账号'),
                            ],
                          ),
                        SizedBox(
                          width: 1,
                        ),
                        TextButton(
                            onPressed: () async {
                              if (await canLaunchUrl(Uri.parse(
                                  'https://swjw.xauat.edu.cn/security-center/password-reset/identity-check-form'))) {
                                await launchUrl(
                                    Uri.parse(
                                        'https://swjw.xauat.edu.cn/security-center/password-reset/identity-check-form'),
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                            child: Text('忘记密码?'))
                      ]),
                if (!_isOnlyLoginMember) const SizedBox(height: 16),
                // 登录按钮
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '登录',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ))
      ],
    ));
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
              setState(() {
                _isOnlyLoginMember = true;
                _showLoginForm = true;
              });
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
              setState(() {
                _isLoading = true;
                _showLoginForm = true;
              });
              _enterLoginMode();
            }),
      ProfileButtonItem(
          icon: Icons.help_outline, title: '帮助', route: '/Helper'),
    ];
  }

  Widget _buildProfileContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: isTablet ? 32 : 16),
          _buildUserInfoCard(),
          const SizedBox(height: 16),
          _buildActionsGrid(),
          const SizedBox(height: 16),
          if (userStore.isLogin) _buildStudyCredits(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // 用户信息卡片
  Widget _buildUserInfoCard() {
    return ClubCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildUserAvatar(),
          ],
        ),
      ),
    );
  }

  // 头像和用户名区域
  Widget _buildUserAvatar() {
    return Row(
      children: [
        // 头像容器
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LazyLoadImage.assets(
              'assets/icon.webp',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // 用户名和学号
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _username.isNotEmpty ? _username : '游客模式',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              _buildAccountTags()
            ],
          ),
        ),
      ],
    );
  }

  // 账号类型标签
  Widget _buildAccountTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (userStore.isLogin)
          _buildTag('教务系统', Icons.school, Colors.blue),
        if (userStore.isLoginMember)
          _buildTag('iMember', Icons.apple, Colors.grey[800]!),
        if (!userStore.isLogin && !userStore.isLoginMember)
          _buildTag('游客', Icons.person_outline, Colors.grey),
      ],
    );
  }

  // 单个标签组件
  Widget _buildTag(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // 功能按钮网格
  Widget _buildActionsGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return ClubCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 6 : 3,
            childAspectRatio: 1.0,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: profileButtonItems.length,
          itemBuilder: (context, index) {
            return _buildActionItem(profileButtonItems[index]);
          },
        ),
      ),
    );
  }

  // 单个功能按钮项
  Widget _buildActionItem(ProfileButtonItem item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color =
        CourseColorManager.generateSoftColor(item.title, isDark: isDark);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (item.route.isNotEmpty) {
            Get.toNamed(item.route);
          } else {
            item.onPressed?.call();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 图标容器
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              // 文字标签
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 学分卡片区域
  Widget _buildStudyCredits() {
    return FutureBuilder(
      future: DataService.getInfoList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: snapshot.data!.map((data) {
            return StudyCreditCard(data: data);
          }).toList(),
        );
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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
}
