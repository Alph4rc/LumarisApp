import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/core/models/user_data.dart';
import 'package:ios_club_app/core/services/club_service.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/education/services/edu_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/user_store.dart';
import 'package:ios_club_app/ui/components/optimized_image.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final UserStore userStore = UserStore.to;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  
  bool _obscureText = true;
  bool _isLoading = false;
  bool _isLoginMember = false;
  bool _isOnlyLoginMember = false;

  @override
  void initState() {
    super.initState();
    // 从路由参数获取登录模式
    final args = Get.arguments;
    if (args != null && args is Map && args['isOnlyLoginMember'] == true) {
      _isOnlyLoginMember = true;
    }
    // 如果是仅登录社团账号，默认不需要勾选"同时登录社团账号"
    if (_isOnlyLoginMember) {
      _isLoginMember = false;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
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

      bool eduLoginSuccess = true;
      bool clubLoginSuccess = true;

      // 登录教务系统账号（添加超时保护：最多20秒）
      if (!_isOnlyLoginMember) {
        AppLogger.debug('[LoginPage] 登录教务系统');
        eduLoginSuccess = await _loginToEduSystem().timeout(
          const Duration(seconds: 20),
          onTimeout: () {
            AppLogger.warning('[LoginPage] 教务系统登录超时');
            if (mounted) {
              showClubSnackBar(context, const Text('教务系统登录超时，请检查网络连接'));
            }
            return false;
          },
        );
      }

      // 登录社团账号（添加超时保护：最多10秒）
      if (_isOnlyLoginMember || _isLoginMember) {
        AppLogger.debug('[LoginPage] 登录社团账号');
        clubLoginSuccess = await _loginToClub().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            AppLogger.warning('[LoginPage] 社团账号登录超时');
            if (mounted) {
              showClubSnackBar(context, const Text('社团账号登录超时，请检查网络连接'));
            }
            return false;
          },
        );
      }

      // 检查登录结果
      if (!eduLoginSuccess || !clubLoginSuccess) {
        return;
      }

      // 保存登录信息
      await _saveLoginInfo();

      // 登录成功，返回上一页并传递成功标志
      if (mounted) {
        Get.back(result: true);
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
    final result = await EduService.loginFromData(
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

    return result;
  }

  /// 保存登录信息
  Future<void> _saveLoginInfo() async {
    final prefs = PrefsService.instance;

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text(
                    _isOnlyLoginMember ? '登录社团账号' : '登录教务系统账号',
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
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
                          ? Colors.grey[800]
                          : Colors.grey[100],
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[300]
                            : Colors.grey[700],
                      ),
                      hintText: '学号',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[100],
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[300]
                            : Colors.grey[700],
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
                            ? Colors.grey[800]
                            : Colors.grey[100],
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[700],
                        ),
                        hintText: '姓名（登录社团账号时必填）',
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
                        const SizedBox(width: 1),
                        TextButton(
                          onPressed: () async {
                            const url = 'https://swjw.xauat.edu.cn/security-center/password-reset/identity-check-form';
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
                  if (!_isOnlyLoginMember) const SizedBox(height: 16),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
