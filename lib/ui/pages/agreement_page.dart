import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';

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

  void _viewPrivacyPolicy() {
    AppRouter.rootNavigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => const _PrivacyPolicyContentPage(),
      ),
    );
  }

  void _viewUserAgreement() {
    AppRouter.rootNavigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => const _UserAgreementContentPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.clubColors;

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
                      _buildAppIcon(context, isWide),
                      const SizedBox(height: 24),
                      // 标题
                      Text(
                        context.l10n.appName,
                        style: TextStyle(
                          fontSize: isWide ? 30 : 26,
                          fontWeight: FontWeight.bold,
                          color: colors.label,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.agreementWelcomeTitle,
                        style: TextStyle(
                          fontSize: isWide ? 17 : 16,
                          color: colors.secondaryLabel,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // 说明文字
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Text(
                          context.l10n.agreementDescription,
                          style: TextStyle(
                            fontSize: isWide ? 16 : 15,
                            color: colors.label,
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
                          context: context,
                          isWide: isWide,
                          icon: CupertinoIcons.shield_fill,
                          iconColor: colors.primary,
                          title: context.l10n.privacyPolicy,
                          description: context.l10n.agreementPrivacyDescription,
                          onTap: _viewPrivacyPolicy,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: _buildAgreementCard(
                          context: context,
                          isWide: isWide,
                          icon: CupertinoIcons.doc_text_fill,
                          iconColor: colors.purple,
                          title: context.l10n.userAgreement,
                          description: context.l10n.agreementUserDescription,
                          onTap: _viewUserAgreement,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // 提示文字
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Text(
                          context.l10n.agreementReadTip,
                          style: TextStyle(
                            fontSize: isWide ? 14 : 13,
                            color: colors.secondaryLabel,
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
                        child: _buildButtons(context, ref, isWide),
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

  Widget _buildAppIcon(BuildContext context, bool isWide) {
    final colors = context.clubColors;
    final size = isWide ? 100.0 : 90.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: isWide ? ClubRadii.tile : ClubRadii.card,
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor.withValues(alpha: 0.8),
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
    bool isWide,
  ) {
    final colors = context.clubColors;
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
              context.l10n.agreeAndContinue,
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
            color: colors.surfaceRaised,
            child: Text(
              context.l10n.disagree,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: colors.secondaryLabel,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgreementCard({
    required BuildContext context,
    required bool isWide,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final colors = context.clubColors;
    return Material(
      color: colors.surfaceRaised,
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
                        color: colors.label,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: isWide ? 14 : 13,
                        color: colors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: isWide ? 20 : 18,
                color: colors.tertiaryLabel,
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
    final l10n = context.l10n;
    final colors = context.clubColors;
    final textColor = colors.label;
    final titleColor = colors.label;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyPolicyTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildResponsiveContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(l10n.privacyPolicyTitle, titleColor),
            const SizedBox(height: 8),
            _buildSubtitle(context, l10n.privacyPolicyUpdatedAt),
            const SizedBox(height: 8),
            _buildSubtitle(context, l10n.privacyPolicyEffectiveAt),
            const SizedBox(height: 20),
            _buildBodyText(l10n.privacySection1_1, textColor),
            const SizedBox(height: 24),
            _buildSectionTitle(l10n.privacySection1Title, titleColor),
            const SizedBox(height: 12),
            _buildBodyText(l10n.privacySection1_1, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.privacySection1_2, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.privacySection1_3, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.privacySection1_4, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.privacySection1_5, textColor),
            const SizedBox(height: 24),
            _buildSectionTitle(l10n.privacySection2Title, titleColor),
            const SizedBox(height: 12),
            _buildBodyText(l10n.privacySection2_1, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.privacySection2_2, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.privacySection2_3, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.privacySection2_4, textColor),
            const SizedBox(height: 24),
            _buildSectionTitle(l10n.privacySection3Title, titleColor),
            const SizedBox(height: 12),
            _buildBodyText(l10n.privacySection3_1, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.privacySection3_2, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.privacySection3_3, textColor),
            const SizedBox(height: 24),
            _buildSectionTitle(l10n.privacySection4Title, titleColor),
            const SizedBox(height: 12),
            _buildBodyText(l10n.privacySection4_1, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.privacySection4_2, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.privacySection4_3, textColor),
            const SizedBox(height: 24),
            _buildSectionTitle(l10n.privacySection5Title, titleColor),
            const SizedBox(height: 12),
            _buildBodyText(l10n.privacySection5_1, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.privacySection5_2, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.privacySection5_3, textColor),
            const SizedBox(height: 24),
            _buildSectionTitle(l10n.privacySection6Title, titleColor),
            const SizedBox(height: 12),
            _buildBodyText(l10n.privacySection6_1, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.privacySection6_2, textColor),
            const SizedBox(height: 24),
            _buildSectionTitle(l10n.privacySection7Title, titleColor),
            const SizedBox(height: 12),
            _buildBodyText(l10n.privacySection7_1, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.privacySection7_2, textColor),
            const SizedBox(height: 24),
            _buildSectionTitle(l10n.privacySection8Title, titleColor),
            const SizedBox(height: 12),
            _buildBodyText(l10n.privacySection8_1, textColor),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String text, Color color) => Text(text,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold));

  Widget _buildSubtitle(BuildContext context, String text) {
    final colors = context.clubColors;
    return Text(
      text,
      style: TextStyle(fontSize: 13, color: colors.secondaryLabel),
    );
  }

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
    final l10n = context.l10n;
    final colors = context.clubColors;
    final textColor = colors.label;
    final titleColor = colors.label;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.userAgreementTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildResponsiveContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(l10n.userAgreementTitle, titleColor),
            const SizedBox(height: 8),
            _buildSubtitle(context, l10n.userAgreementUpdatedAt),
            const SizedBox(height: 8),
            _buildSubtitle(context, l10n.userAgreementEffectiveAt),
            const SizedBox(height: 20),
            _buildBodyText(l10n.userAgreementIntro, textColor),
            const SizedBox(height: 24),
            _buildSectionTitle(l10n.userAgreementSection1Title, titleColor),
            const SizedBox(height: 12),
            _buildBodyText(l10n.userAgreementSection1_1, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.userAgreementSection1_2, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.userAgreementSection1_3, textColor),
            const SizedBox(height: 24),
            _buildSectionTitle(l10n.userAgreementSection2Title, titleColor),
            const SizedBox(height: 12),
            _buildBodyText(l10n.userAgreementSection2_1, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.userAgreementSection2_2, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.userAgreementSection2_3, textColor),
            const SizedBox(height: 24),
            _buildSectionTitle(l10n.userAgreementSection3Title, titleColor),
            const SizedBox(height: 12),
            _buildBodyText(l10n.userAgreementSection3_1, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.userAgreementSection3_2, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.userAgreementSection3_3, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.userAgreementSection3_4, textColor),
            const SizedBox(height: 24),
            _buildSectionTitle(l10n.userAgreementSection4Title, titleColor),
            const SizedBox(height: 12),
            _buildBodyText(l10n.userAgreementSection4_1, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.userAgreementSection4_2, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.userAgreementSection4_3, textColor),
            const SizedBox(height: 24),
            _buildSectionTitle(l10n.userAgreementSection5Title, titleColor),
            const SizedBox(height: 12),
            _buildBodyText(l10n.userAgreementSection5_1, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.userAgreementSection5_2, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.userAgreementSection5_3, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.userAgreementSection5_4, textColor),
            const SizedBox(height: 24),
            _buildSectionTitle(l10n.userAgreementSection6Title, titleColor),
            const SizedBox(height: 12),
            _buildBodyText(l10n.userAgreementSection6_1, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.userAgreementSection6_2, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.userAgreementSection6_3, textColor),
            const SizedBox(height: 24),
            _buildSectionTitle(l10n.userAgreementSection7Title, titleColor),
            const SizedBox(height: 12),
            _buildBodyText(l10n.userAgreementSection7_1, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.userAgreementSection7_2, textColor),
            const SizedBox(height: 8),
            _buildBodyText(l10n.userAgreementSection7_3, textColor),
            const SizedBox(height: 24),
            _buildSectionTitle(l10n.userAgreementSection8Title, titleColor),
            const SizedBox(height: 12),
            _buildBodyText(l10n.userAgreementSection8_1, textColor),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String text, Color color) => Text(text,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold));

  Widget _buildSubtitle(BuildContext context, String text) {
    final colors = context.clubColors;
    return Text(
      text,
      style: TextStyle(fontSize: 13, color: colors.secondaryLabel),
    );
  }

  Widget _buildSectionTitle(String text, Color color) => Text(text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600));

  Widget _buildBodyText(String text, Color color) =>
      Text(text, style: const TextStyle(fontSize: 15, height: 1.8));
}

/// 响应式内容包裹器：桌面/平板端限制最大宽度并居中
Widget _buildResponsiveContent({
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
