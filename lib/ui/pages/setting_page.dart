import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/core/utils/request_cache.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/ui/components/club_modal_bottom_sheet.dart';
import 'package:ios_club_app/ui/pages/settingPages/version_setting.dart';
import 'package:ios_club_app/features/education/services/education_cache_service.dart';
import 'package:ios_club_app/features/education/services/education_refresh_service.dart';
import 'package:ios_club_app/platform/android/background_service.dart';
import 'package:ios_club_app/platform/ios/background_service.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:ios_club_app/state/user_store.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/components/platform_dialog.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';

import 'package:ios_club_app/ui/pages/settingPages/show_tomorrow_setting.dart';
import 'package:ios_club_app/ui/pages/settingPages/remind_setting.dart';

import 'package:ios_club_app/ui/pages/settingPages/home_page_setting.dart';
import 'package:ios_club_app/ui/pages/settingPages/font_family_setting.dart';
import 'package:ios_club_app/ui/pages/settingPages/todo_remind_setting.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userState = ref.watch(userStoreProvider);
    final userStore = ref.read(userStoreProvider.notifier);
    final settings = ref.watch(settingsStoreProvider);
    final settingsStore = ref.read(settingsStoreProvider.notifier);

    return Scaffold(
      appBar: ClubAppBar(
        title: '设置',
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          final horizontalPadding = isTablet ? 32.0 : 16.0;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // App 图标区域
                _buildAppHeader(context, isDark),
                const SizedBox(height: 32),
                // 基本设置
                _buildSectionTitle('基本设置', isDark),
                const SizedBox(height: 12),
                _buildSettingsGroup([
                  _buildRefreshTile(context, isDark),
                  const ShowTomorrowSetting(),
                  if (PlatformUtils.isMobile) const RemindSetting(),
                  //const TodoListSetting(),
                  const TodoRemindSetting(), // 添加待办提醒设置
                  const HomePageSetting(), // 添加首页设置
                  // if (PlatformUtils.isMobile)
                  //   const HapticFeedbackSetting(), // 添加触觉反馈设置
                  if (PlatformUtils.isDesktop && !PlatformUtils.isMacOS)
                    const FontFamilySetting(), // 添加字体设置
                ]),
                const SizedBox(height: 24),
                // 版本信息
                _buildSectionTitle('版本', isDark),
                const SizedBox(height: 12),
                _buildSettingsGroup([
                  const VersionSetting(),
                ]),
                const SizedBox(height: 24),
                // 移动端小组件
                if (PlatformUtils.isMobile) _buildSectionTitle('小组件', isDark),
                if (PlatformUtils.isMobile) const SizedBox(height: 12),
                if (PlatformUtils.isMobile)
                  _buildSettingsGroup([
                    _buildWidgetTile(context, isDark),
                  ]),
                if (PlatformUtils.isMobile) const SizedBox(height: 24),
                // 关于我们
                _buildSectionTitle('关于', isDark),
                const SizedBox(height: 12),
                _buildSettingsGroup([
                  _buildTeamTile(isDark),
                  _buildLicenseTile(isDark),
                  _buildPrivacyPolicyTile(isDark),
                  _buildUserAgreementTile(isDark),
                ]),
                const SizedBox(height: 24),
                // 其他
                _buildSectionTitle('其他', isDark),
                const SizedBox(height: 12),
                _buildSettingsGroup([
                  _buildClearCacheTile(context, isDark),
                  if (userState.isLogin)
                    _buildLogoutTile(context, isDark, userStore),
                  ClubListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    leading: Icon(
                      CupertinoIcons.grid,
                      size: 20,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : CupertinoColors.tertiaryLabel,
                    ),
                    title: const Text('显示课表网格线'),
                    trailing: CupertinoSwitch(
                      value: settings.showCourseGrid,
                      onChanged: (value) {
                        settingsStore.setShowCourseGrid(value);
                      },
                    ),
                  ),
                  if (kDebugMode)
                    ClubListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      leading: Icon(
                        CupertinoIcons.checkmark_shield,
                        size: 20,
                        color: isDark
                            ? Colors.orange.withValues(alpha: 0.7)
                            : CupertinoColors.systemOrange,
                      ),
                      title: const Text('协议授权状态 [Debug]'),
                      subtitle: const Text('关闭后下次启动将重新显示授权页'),
                      subtitleTextStyle: const TextStyle(fontSize: 12),
                      trailing: CupertinoSwitch(
                        value: settings.hasAcceptedAgreement,
                        onChanged: (value) {
                          settingsStore.setHasAcceptedAgreement(value);
                        },
                      ),
                    ),
                ]),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppHeader(BuildContext context, bool isDark) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: ClubRadii.tile,
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: ClubRadii.tile,
            child: const Image(
              image: AssetImage('assets/icon.webp'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'iOS Club App',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '试着把大学囊括其中',
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? Colors.white.withValues(alpha: 0.6)
                : CupertinoColors.secondaryLabel,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : CupertinoColors.secondaryLabel,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return ClubCard(
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildRefreshTile(BuildContext context, bool isDark) {
    return ClubListTile(
      leading: Icon(
        CupertinoIcons.refresh,
        size: 20,
        color: CupertinoColors.systemBlue,
      ),
      title: const Text('刷新数据'),
      showChevron: true,
      onTap: () async {
        showClubSnackBar(context, const Text('正在刷新数据...'));
        final re = await EducationRefreshService.refresh();
        if (re) {
          await _syncHomeWidget();
        }
        if (context.mounted) {
          showClubSnackBar(context, Text('刷新数据${re ? '成功' : '失败'}'));
        }
      },
    );
  }

  Future<void> _syncHomeWidget() async {
    if (PlatformUtils.isAndroid) {
      await BackgroundService.updateWidget();
      return;
    }

    if (PlatformUtils.isIOS) {
      await IOSBackgroundService.updateWidget();
    }
  }

  Widget _buildTeamTile(bool isDark) {
    return ClubListTile(
      leading: Icon(
        CupertinoIcons.person_2_fill,
        size: 20,
        color: CupertinoColors.systemOrange,
      ),
      title: const Text('制作团队'),
      subtitle: const Text('iOS Club App 开发组'),
      onTap: () {
        AppRouter.push(AppRoutes.author);
      },
    );
  }

  Widget _buildLicenseTile(bool isDark) {
    return ClubListTile(
      leading: Icon(
        CupertinoIcons.doc_text_fill,
        size: 20,
        color: CupertinoColors.systemGreen,
      ),
      title: const Text('开源协议'),
      subtitle: const Text('MIT License'),
      onTap: () {
        AppRouter.push(AppRoutes.license);
      },
    );
  }

  Widget _buildPrivacyPolicyTile(bool isDark) {
    return ClubListTile(
      leading: Icon(
        CupertinoIcons.shield_fill,
        size: 20,
        color: CupertinoColors.systemBlue,
      ),
      title: const Text('隐私协议'),
      subtitle: const Text('了解我们如何保护你的隐私'),
      onTap: () {
        AppRouter.push(AppRoutes.privacyPolicy);
      },
    );
  }

  Widget _buildUserAgreementTile(bool isDark) {
    return ClubListTile(
      leading: Icon(
        CupertinoIcons.doc_text_fill,
        size: 20,
        color: CupertinoColors.systemPurple,
      ),
      title: const Text('用户协议'),
      subtitle: const Text('使用本应用即表示你同意本协议'),
      onTap: () {
        AppRouter.push(AppRoutes.userAgreement);
      },
    );
  }

  Widget _buildLogoutTile(
    BuildContext context,
    bool isDark,
    UserStore userStore,
  ) {
    return ClubListTile(
      leading: Icon(
        Icons.logout_outlined,
        size: 20,
        color: isDark
            ? Colors.white.withValues(alpha: 0.5)
            : CupertinoColors.tertiaryLabel,
      ),
      title: const Text('退出教务系统'),
      onTap: () async {
        final result = await PlatformDialog.showConfirmDialog(
          context,
          title: "确定退出登录吗？",
          content: "退出后需要重新登录才能访问教务系统数据",
          confirmText: '退出登录',
          cancelText: '取消',
        );

        if (result == true) {
          await userStore.logout();
          AppRouter.go(AppRoutes.profile);
        }
      },
    );
  }

  Widget _buildWidgetTile(BuildContext context, bool isDark) {
    return ClubListTile(
      leading: Icon(
        Icons.widgets,
        size: 20,
        color: CupertinoColors.systemBlue,
      ),
      title: const Text('添加到桌面'),
      showChevron: true,
      onTap: () {
        // 直接打开安卓小组件设置
        _openWidgetSettings(context);
      },
    );
  }

  void _openWidgetSettings(BuildContext context) async {
    try {
      // 尝试直接打开小组件设置页面
      if (PlatformUtils.isAndroid) {
        final intent = AndroidIntent(
          action: 'android.settings.ACTION_APPLICATION_DETAILS_SETTINGS',
          data: Uri.encodeFull('package: com.example.ios_club_app'),
        );
        await intent.launch();
      }
    } catch (e) {
      // 如果无法直接打开设置，则显示说明
      if (context.mounted) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        _showWidgetInstructions(context, isDark);
      }
    }
  }

  Widget _buildClearCacheTile(BuildContext context, bool isDark) {
    return ClubListTile(
      leading: Icon(
        CupertinoIcons.trash_fill,
        size: 20,
        color: CupertinoColors.systemRed,
      ),
      title: const Text('清除缓存'),
      showChevron: true,
      onTap: () async {
        final result = await PlatformDialog.showConfirmDialog(
          context,
          title: '确定清除缓存吗？',
          content: '这将删除所有缓存的数据，下次打开应用需要重新加载数据',
          confirmText: '清除缓存',
          cancelText: '取消',
        );

        if (result == true) {
          if (context.mounted) {
            showClubSnackBar(context, const Text('正在清除缓存...'));
          }
          // 使用 EduService.clearEduCache() 进行全面清理
          await EducationCacheService.clearEduCache();
          // 同时也清理 RequestCache 以防万一 (EduService 内部已经调用了，这里可以保留或移除，保留无害)
          await RequestCache.instance.clear();

          if (context.mounted) {
            showClubSnackBar(context, const Text('缓存清除成功'));
          }
        }
      },
    );
  }

  void _showWidgetInstructions(BuildContext context, bool isDark) {
    showClubModalBottomSheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '添加小组件到桌面',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '请按照以下步骤操作：',
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          _buildInstructionStep(
            isDark,
            '1',
            '长按手机桌面空白处',
          ),
          const SizedBox(height: 8),
          _buildInstructionStep(
            isDark,
            '2',
            '点击"小组件"或"Widgets"选项',
          ),
          const SizedBox(height: 8),
          _buildInstructionStep(
            isDark,
            '3',
            '找到"iOS Club App"并选择合适的小组件',
          ),
          const SizedBox(height: 8),
          _buildInstructionStep(
            isDark,
            '4',
            '将小组件拖拽到桌面合适位置',
          ),
          const SizedBox(height: 24),
          Text(
            '提示：小组件可以显示今日课程等信息，方便快速查看',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.6)
                  : Colors.black.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(bool isDark, String step, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: CupertinoColors.systemBlue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
