import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ios_club_app/features/education/models/user_data.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/education/services/education_cache_service.dart';
import 'package:ios_club_app/features/education/services/education_refresh_service.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/user_store.dart';
import 'package:ios_club_app/ui/components/club_radii.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/ui/components/optimized_image.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ios_club_app/core/services/secure_storage_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final UserStore userStore = UserStore.to;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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

    try {
      AppLogger.debug('[LoginPage] 开始登录');

      // 登录教务系统账号（添加超时保护：最多20秒）
      AppLogger.debug('[LoginPage] 登录教务系统');
      final eduLoginSuccess = await _loginToEduSystem().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          AppLogger.warning('[LoginPage] 教务系统登录超时');
          if (mounted) {
            showClubSnackBar(context, const Text('教务系统登录超时，请检查网络连接'));
          }
          return false;
        },
      );

      // 检查登录结果
      if (!eduLoginSuccess) {
        return;
      }

      // 保存登录信息
      final saveLoginInfoSuccess = await _saveLoginInfo();

      if (!saveLoginInfoSuccess && mounted) {
        showClubSnackBar(
          context,
          const Text('登录成功，但安全存储不可用，下次启动后可能需要重新输入账号密码'),
        );
      }

      // 登录成功，返回上一页并传递成功标志
      if (mounted) {
        AppRouter.pop(true);
      }

      AppLogger.debug('[LoginPage] 登录成功');
    } on TimeoutException catch (e) {
      AppLogger.warning('[LoginPage] 登录超时: $e');
      if (mounted) {
        showClubSnackBar(context, const Text('登录超时，请检查网络连接后重试'));
      }
    } catch (e, stackTrace) {
      AppLogger.error('[LoginPage] 登录失败', error: e, stackTrace: stackTrace);
      if (mounted) {
        showClubSnackBar(context, Text('登录失败: ${e.toString()}'));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 登录教务系统
  Future<bool> _loginToEduSystem() async {
    await EducationCacheService.clearEduCache();
    final result = await EducationRefreshService.loginAndRefresh(
      _usernameController.text,
      _passwordController.text,
    );

    if (!result && mounted) {
      showClubSnackBar(
        context,
        const Text('登录失败，请检查用户名和密码'),
      );
    }

    return result;
  }

  /// 保存登录信息
  Future<bool> _saveLoginInfo() async {
    final prefs = PrefsService.instance;
    final secureStorage = SecureStorageService.instance;
    var saveSuccess = true;

    await prefs.setString(PrefsKeys.USERNAME, _usernameController.text);
    saveSuccess = await secureStorage.write(
          key: PrefsKeys.USERNAME,
          value: _usernameController.text,
        ) &&
        saveSuccess;
    saveSuccess = await secureStorage.write(
          key: PrefsKeys.PASSWORD,
          value: _passwordController.text,
        ) &&
        saveSuccess;

    final userDataString = prefs.getString(PrefsKeys.USER_DATA);
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      await userStore.setUserData(UserData.fromJson(userData));
    }

    return saveSuccess;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final groupBackgroundColor =
        isDark ? const Color(0xFF1C1C1E) : Colors.white;

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: LoadingStateView(
            title: '正在登录教务系统',
            subtitle: '正在验证账号并同步课程、成绩等基础数据，首次登录可能需要几秒',
          ),
        ),
      );
    }

    return Scaffold(
      // 简约风格通常使用系统背景色，Material 3 默认背景色已足够适配
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => AppRouter.pop(),
          icon: Icon(
            Icons.arrow_back_ios_new, // 更现代的返回图标
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Logo
                Container(
                  decoration: BoxDecoration(
                    borderRadius: ClubRadii.tile,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: ClubRadii.tile,
                    child: LazyLoadImage.assets(
                      'assets/icon.webp',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  '登录教务系统',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '请使用您的账号继续',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 40),

                // Grouped Inputs
                Container(
                  decoration: BoxDecoration(
                    color: groupBackgroundColor,
                    borderRadius: ClubRadii.navigation,
                  ),
                  child: Column(
                    children: [
                      _buildCupertinoLikeTextField(
                        context,
                        controller: _usernameController,
                        hintText: '学号',
                        icon: Icons.person_outline,
                        isFirst: true,
                        isLast: false,
                      ),
                      const Divider(height: 1, indent: 48),
                      // Indent to align with text
                      _buildCupertinoLikeTextField(
                        context,
                        controller: _passwordController,
                        hintText: '统一身份认证密码',
                        icon: Icons.lock_outline,
                        obscureText: _obscureText,
                        isPassword: true,
                        isFirst: false,
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Options Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                        const url =
                            'https://swjw.xauat.edu.cn/security-center/password-reset/identity-check-form';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      child: const Text('忘记密码?'),
                    )
                  ],
                ),

                const SizedBox(height: 32),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: CupertinoButton.filled(
                    onPressed: _login,
                    child: const Text(
                      '登录',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Footer info or extra spacing
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCupertinoLikeTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    bool isPassword = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 17),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.color
              ?.withValues(alpha: 0.4),
        ),
        prefixIcon: Icon(
          icon,
          color: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.color
              ?.withValues(alpha: 0.5),
          size: 22,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.5),
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        isDense: true,
      ),
    );
  }
}
