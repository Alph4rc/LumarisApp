import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/theme/club_smooth_corners.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthorPage extends StatelessWidget {
  const AuthorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.clubColors;

    return Scaffold(
      backgroundColor: colors.groupedBackground,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            title: Text(
              l10n.aboutAuthor,
              style: TextStyle(
                color: colors.label,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: colors.groupedBackground,
            centerTitle: false,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: Column(
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 32),
                      _buildSectionHeader(context, l10n.coreTeam),
                      _buildTeamSection(context),
                      const SizedBox(height: 32),
                      _buildSectionHeader(context, l10n.specialThanks),
                      _buildThanksSection(context),
                      const SizedBox(height: 32),
                      _buildSectionHeader(context, l10n.contactUs),
                      _buildContactSection(context),
                      const SizedBox(height: 48),
                      _buildFooter(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.clubColors;
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          width: 100,
          height: 100,
          decoration: ShapeDecoration(
            shape: ClubSmoothCorners.shape(ClubRadii.tile),
            shadows: [
              BoxShadow(
                color: colors.shadowColor,
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -2,
              ),
            ],
          ),
          child: ClubSmoothCorners.clip(
            borderRadius: ClubRadii.tile,
            child: Image.asset(
              'assets/icon.webp',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Lumaris Team',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colors.label,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.tagline,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: colors.secondaryLabel,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: context.clubColors.secondaryLabel,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTeamSection(BuildContext context) {
    final colors = context.clubColors;
    final members = [
      {'name': 'LuckyFish', 'role': 'Lead Developer'},
      {'name': 'zealous', 'role': 'Developer'},
      {'name': '乔博睿', 'role': 'Developer'},
      {'name': 'YoChine_Lanee', 'role': 'Developer'},
      {'name': 'To-fly-high', 'role': 'Developer'}
    ];

    return ClubCard(
      child: Column(
        children: List.generate(members.length, (index) {
          final member = members[index];
          final isFirst = index == 0;
          final isLast = index == members.length - 1;

          return Column(
            children: [
              ClubListTile(
                borderRadius: BorderRadius.vertical(
                  top: isFirst ? ClubRadii.cardRadius : Radius.zero,
                  bottom: isLast ? ClubRadii.cardRadius : Radius.zero,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: ShapeDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    shape: ClubSmoothCorners.shape(ClubRadii.control),
                  ),
                  child: Icon(
                    CupertinoIcons.person_fill,
                    size: 20,
                    color: colors.primary,
                  ),
                ),
                title: Text(
                  member['name']!,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  member['role']!,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.secondaryLabel,
                  ),
                ),
                showChevron: true,
                onTap: () {
                  // Future: Show profile or GitHub
                },
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 64,
                  thickness: 0.5,
                  color: colors.separator.withValues(alpha: 0.1),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildThanksSection(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.clubColors;
    return ClubCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.heart_fill,
                color: colors.danger,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.thanksTitle,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: colors.label,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.thanksContent,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: colors.label.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.clubColors;
    final items = [
      {
        'title': l10n.githubRepository,
        'icon': CupertinoIcons.doc_text_fill,
        'color': colors.secondaryLabel,
        'url': 'https://github.com/iOS-Club-XAUAT/ios_club_app'
      },
      {
        'title': l10n.joinUs,
        'icon': CupertinoIcons.person_2_fill,
        'color': colors.primary,
        'url': 'https://iosclub.org'
      },
    ];

    return ClubCard(
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isFirst = index == 0;
          final isLast = index == items.length - 1;

          return Column(
            children: [
              ClubListTile(
                borderRadius: BorderRadius.vertical(
                  top: isFirst ? ClubRadii.cardRadius : Radius.zero,
                  bottom: isLast ? ClubRadii.cardRadius : Radius.zero,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                leading: Icon(
                  item['icon'] as IconData,
                  color: item['color'] as Color,
                  size: 22,
                ),
                title: Text(
                  item['title'] as String,
                  style: const TextStyle(fontSize: 17),
                ),
                showChevron: true,
                onTap: () async {
                  final url = Uri.parse(item['url'] as String);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 56,
                  thickness: 0.5,
                  color: colors.separator.withValues(alpha: 0.1),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.clubColors;
    return Column(
      children: [
        Text(
          '© 2026 Lumaris Team',
          style: TextStyle(
            fontSize: 13,
            color: colors.tertiaryLabel,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.madeWithLove,
          style: TextStyle(
            fontSize: 12,
            color: colors.quaternaryLabel,
          ),
        ),
      ],
    );
  }
}
