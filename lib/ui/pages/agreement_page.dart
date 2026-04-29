import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/ui/components/club_radii.dart';

class AgreementPage extends ConsumerWidget {
  const AgreementPage({super.key});

  Future<void> _onAgree(BuildContext context, WidgetRef ref) async {
    await ref
        .read(settingsStoreProvider.notifier)
        .setHasAcceptedAgreement(true);
  }

  void _onDisagree() {
    exit(0);
  }

  void _viewPrivacyPolicy(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _PrivacyPolicyContentPage(),
      ),
    );
  }

  void _viewUserAgreement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _UserAgreementContentPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = PlatformUtils.isDesktop;
            final isTablet = constraints.maxWidth > 600 && !isDesktop;
            final isWide = isDesktop || isTablet;

            // 桌面端内容区最大宽度
            final contentMaxWidth =
                isDesktop ? 520.0 : (isTablet ? 480.0 : double.infinity);
            // 水平内边距
            final horizontalPadding =
                isDesktop ? 48.0 : (isTablet ? 40.0 : 28.0);
            // 顶部间距
            final topSpacing = isDesktop ? 48.0 : (isTablet ? 64.0 : 60.0);

            return Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: topSpacing),
                      // App 图标
                      _buildAppIcon(isDark, isWide),
                      const SizedBox(height: 24),
                      // 标题
                      Text(
                        'iOS Club App',
                        style: TextStyle(
                          fontSize: isWide ? 30 : 26,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '欢迎使用 iOS Club App',
                        style: TextStyle(
                          fontSize: isWide ? 17 : 16,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // 说明文字
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Text(
                          '在使用本应用前，请仔细阅读并同意以下协议。我们将严格遵守相关法律法规，保护您的个人信息安全。',
                          style: TextStyle(
                            fontSize: isWide ? 16 : 15,
                            color: isDark ? Colors.white : Colors.black87,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // 协议卡片区域
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: _buildAgreementCard(
                          isDark: isDark,
                          isWide: isWide,
                          icon: CupertinoIcons.shield_fill,
                          iconColor: CupertinoColors.systemBlue,
                          title: '隐私协议',
                          description: '了解我们如何收集、使用和保护你的个人信息',
                          onTap: () => _viewPrivacyPolicy(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: _buildAgreementCard(
                          isDark: isDark,
                          isWide: isWide,
                          icon: CupertinoIcons.doc_text_fill,
                          iconColor: CupertinoColors.systemPurple,
                          title: '用户协议',
                          description: '了解使用本应用的权利、义务和免责条款',
                          onTap: () => _viewUserAgreement(context),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // 提示文字
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Text(
                          '点击上方卡片可查看协议全文。继续使用即表示你已阅读并同意以上协议。',
                          style: TextStyle(
                            fontSize: isWide ? 14 : 13,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // 按钮区域
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: _buildButtons(context, ref, isDark, isWide),
                      ),
                      SizedBox(height: isDesktop ? 40 : 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppIcon(bool isDark, bool isWide) {
    final size = isWide ? 100.0 : 90.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: isWide ? ClubRadii.tile : ClubRadii.card,
        boxShadow: [
          BoxShadow(
            color:
                (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: isWide ? ClubRadii.tile : ClubRadii.card,
        child: const Image(
          image: AssetImage('assets/icon.webp'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildButtons(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    bool isWide,
  ) {
    final buttonHeight = isWide ? 52.0 : 50.0;
    final fontSize = isWide ? 18.0 : 17.0;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: CupertinoButton.filled(
            onPressed: () => _onAgree(context, ref),
            child: Text(
              '同意并继续',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: CupertinoButton(
            onPressed: _onDisagree,
            color: isDark ? Colors.grey[800] : CupertinoColors.systemGrey5,
            child: Text(
              '不同意',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgreementCard({
    required bool isDark,
    required bool isWide,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isDark ? Colors.grey[850] : CupertinoColors.systemGrey6,
      borderRadius: ClubRadii.panel,
      child: InkWell(
        borderRadius: ClubRadii.panel,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(isWide ? 20 : 18),
          child: Row(
            children: [
              Container(
                width: isWide ? 46 : 42,
                height: isWide ? 46 : 42,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: ClubRadii.navigation,
                ),
                child: Icon(icon, size: isWide ? 24 : 22, color: iconColor),
              ),
              SizedBox(width: isWide ? 16 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isWide ? 17 : 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: isWide ? 14 : 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: isWide ? 20 : 18,
                color:
                    isDark ? Colors.grey[600] : CupertinoColors.tertiaryLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 隐私协议内容页
class _PrivacyPolicyContentPage extends StatelessWidget {
  const _PrivacyPolicyContentPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final titleColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('隐私协议'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildResponsiveContent(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle('iOS Club App 隐私协议', titleColor),
            const SizedBox(height: 8),
            _buildSubtitle('更新日期：2025年1月1日', isDark),
            const SizedBox(height: 8),
            _buildSubtitle('生效日期：2025年1月1日', isDark),
            const SizedBox(height: 20),
            _buildBodyText(
              '欢迎使用 iOS Club App（以下简称"本应用"）。本应用由 iOS Club App Team（以下简称"我们"）开发和运营。'
              '我们深知个人信息对您的重要性，将严格遵守法律法规，遵循合法、正当、必要和诚信原则，'
              '保护您的个人信息安全。本隐私协议旨在向您说明我们如何收集、使用、存储和保护您的个人信息，'
              '以及您享有的相关权利。请您在使用本应用前仔细阅读本隐私协议。',
              textColor,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('一、我们收集的信息', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
                '1.1 账号信息：当您使用教务系统登录功能时，我们需要收集您的学号和密码，用于验证您的身份并获取教务系统数据。这些信息仅存储在您的设备本地。',
                textColor),
            const SizedBox(height: 8),
            _buildBodyText(
                '1.2 课程与成绩信息：在您授权登录后，本应用会从学校教务系统获取您的课程表、考试成绩、培养方案等教育相关数据，并在您的设备本地进行存储和展示。',
                textColor),
            const SizedBox(height: 8),
            _buildBodyText(
                '1.3 校园生活信息：在您使用相关功能时，本应用会从学校相关系统获取您的电费余额、饭卡消费记录、校园网流量使用情况等信息。',
                textColor),
            const SizedBox(height: 8),
            _buildBodyText(
                '1.4 设备信息：为提供更好的服务体验，本应用可能收集您的设备型号、操作系统版本等，用于统计分析和问题排查。',
                textColor),
            const SizedBox(height: 24),
            _buildSectionTitle('二、我们如何使用信息', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
                '2.1 为您提供核心服务：我们使用您的学号和密码向学校教务系统进行身份认证，以获取并展示您的课程、成绩等信息。\n2.2 改善服务质量：我们可能使用设备信息和应用使用统计数据来分析和优化应用性能。\n2.3 桌面小组件：如果您使用桌面小组件功能，本应用会在设备本地存储必要的课程数据。\n2.4 通知提醒：如果您开启了课程提醒功能，本应用会在您的设备上设置本地通知。',
                textColor),
            const SizedBox(height: 24),
            _buildSectionTitle('三、信息的存储与安全', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
                '3.1 本地存储：您的个人信息均存储在您的设备本地，我们不会将这些信息上传至我们的服务器。\n3.2 传输安全：本应用与学校服务器之间的数据传输采用加密通信。\n3.3 数据清除：您可以随时在设置中清除缓存数据，或通过退出登录来清除账号相关数据。',
                textColor),
            const SizedBox(height: 24),
            _buildSectionTitle('四、第三方服务', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
                '4.1 学校教务系统：本应用需要与西安建筑科技大学教务系统进行数据交互。\n4.2 应用更新服务：本应用通过 Gitee 平台检查版本更新信息。\n4.3 本应用不会将您的个人信息分享、出售或出租给任何第三方。',
                textColor),
            const SizedBox(height: 24),
            _buildSectionTitle('五、您的权利', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
                '您可以在应用内查看、更正、删除您的个人信息，也可以通过退出登录或卸载应用撤回同意。', textColor),
            const SizedBox(height: 24),
            _buildSectionTitle('六、联系我们', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
                '开发团队：iOS Club App Team\n所属组织：西安建筑科技大学 iOS Club\n代码仓库：https://gitee.com/luckyfishisdashen/iOSClub.AppMobile',
                textColor),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String text, Color color) => Text(text,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold));

  Widget _buildSubtitle(String text, bool isDark) => Text(text,
      style: TextStyle(
          fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600]));

  Widget _buildSectionTitle(String text, Color color) => Text(text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600));

  Widget _buildBodyText(String text, Color color) =>
      Text(text, style: const TextStyle(fontSize: 15, height: 1.8));
}

/// 用户协议内容页
class _UserAgreementContentPage extends StatelessWidget {
  const _UserAgreementContentPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final titleColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('用户协议'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildResponsiveContent(
        isDark: isDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle('iOS Club App 用户协议', titleColor),
            const SizedBox(height: 8),
            _buildSubtitle('更新日期：2025年1月1日', isDark),
            const SizedBox(height: 8),
            _buildSubtitle('生效日期：2025年1月1日', isDark),
            const SizedBox(height: 20),
            _buildBodyText(
              '欢迎使用 iOS Club App（以下简称"本应用"）。本应用由 iOS Club App Team'
              '（以下简称"我们"）开发和运营。请您在使用本应用前仔细阅读本用户协议'
              '（以下简称"本协议"）。您使用本应用即表示您已阅读、理解并同意接受本协议的全部内容。',
              textColor,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('一、服务说明', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
                '1.1 本应用是西安建筑科技大学 iOS Club 开发的校园助手应用，旨在为在校学生提供便捷的校园信息服务，包括课程管理、成绩查询、校车时刻、电费查询、饭卡消费记录、校园网流量查询、培养方案查看等功能。\n1.2 本应用的部分功能需要连接学校内部网络才能正常使用。\n1.3 本应用显示的课程、成绩等信息来源于学校教务系统，仅供参考。如有差异，以学校官方系统数据为准。',
                textColor),
            const SizedBox(height: 24),
            _buildSectionTitle('二、用户账号与安全', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
                '2.1 您需要使用学校教务系统账号登录本应用的教务相关功能。\n2.2 您的登录凭据仅存储在您的设备本地，我们不会收集或上传您的密码。\n2.3 如您发现账号存在安全风险，应及时修改密码。',
                textColor),
            const SizedBox(height: 24),
            _buildSectionTitle('三、知识产权', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
                '3.1 本应用的源代码基于 MIT 许可证开源发布。\n3.2 本应用的名称、图标、UI 设计等归 iOS Club App Team 所有。\n3.3 本应用中涉及的学校名称、标识等归西安建筑科技大学所有。',
                textColor),
            const SizedBox(height: 24),
            _buildSectionTitle('四、免责声明', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
                '4.1 本应用按"现状"提供，我们不对本应用的准确性、可靠性做任何保证。\n4.2 由于网络故障、学校服务器问题或其他不可抗力因素导致的服务中断，我们不承担责任。\n4.3 本应用中的课程、成绩等信息仅供参考，以学校官方系统数据为准。',
                textColor),
            const SizedBox(height: 24),
            _buildSectionTitle('五、协议的修改与终止', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
                '5.1 我们保留随时修改本协议的权利。修改后的协议将在应用内发布。\n5.2 如您在协议修改后继续使用本应用，即视为您同意修改后的协议。',
                textColor),
            const SizedBox(height: 24),
            _buildSectionTitle('六、联系我们', titleColor),
            const SizedBox(height: 12),
            _buildBodyText(
                '开发团队：iOS Club App Team\n所属组织：西安建筑科技大学 iOS Club\n代码仓库：https://gitee.com/luckyfishisdashen/iOSClub.AppMobile',
                textColor),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String text, Color color) => Text(text,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold));

  Widget _buildSubtitle(String text, bool isDark) => Text(text,
      style: TextStyle(
          fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600]));

  Widget _buildSectionTitle(String text, Color color) => Text(text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600));

  Widget _buildBodyText(String text, Color color) =>
      Text(text, style: const TextStyle(fontSize: 15, height: 1.8));
}

/// 响应式内容包裹器：桌面/平板端限制最大宽度并居中
Widget _buildResponsiveContent({
  required bool isDark,
  required Widget child,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isDesktop = PlatformUtils.isDesktop;
      final isTablet = constraints.maxWidth > 600 && !isDesktop;
      final maxWidth = isDesktop ? 720.0 : (isTablet ? 600.0 : double.infinity);
      final padding = isDesktop ? 48.0 : (isTablet ? 32.0 : 20.0);

      return SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}
