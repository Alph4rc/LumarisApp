import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthorPage extends StatelessWidget {
  const AuthorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Apple-style background color
    final backgroundColor = isDark
        ? const Color(0xFF000000)
        : const Color(0xFFF2F2F7);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            title: const Text(
              '关于作者',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: false,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: backgroundColor,
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
                      _buildHeader(context, isDark),
                      const SizedBox(height: 32),
                      _buildSectionHeader('核心团队'),
                      _buildTeamSection(context, isDark),
                      const SizedBox(height: 32),
                      _buildSectionHeader('特别致谢'),
                      _buildThanksSection(context, isDark),
                      const SizedBox(height: 32),
                      _buildSectionHeader('联系我们'),
                      _buildContactSection(context, isDark),
                      const SizedBox(height: 48),
                      _buildFooter(context, isDark),
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

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              'assets/iOS_Club_Logo.webp',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'iOS Club App Team',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '致力于为建大学子提供更好的服务',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: isDark
                ? CupertinoColors.systemGrey
                : CupertinoColors.secondaryLabel,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: CupertinoColors.systemGrey,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTeamSection(BuildContext context, bool isDark) {
    final members = [
      {'name': 'LuckyFish', 'role': 'Lead Developer'},
      {'name': 'zealous', 'role': 'Developer'},
      {'name': '乔博睿', 'role': 'Developer'},
    ];

    return ClubCard(
      child: Column(
        children: members.asMap().entries.map((entry) {
          final index = entry.key;
          final member = entry.value;
          final isLast = index == members.length - 1;

          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark
                        ? CupertinoColors.systemGrey6.darkColor
                        : CupertinoColors.systemGrey6,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.person_fill,
                    size: 20,
                    color: CupertinoColors.systemBlue,
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
                    color: isDark
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.secondaryLabel,
                  ),
                ),
                trailing: const Icon(
                  CupertinoIcons.chevron_forward,
                  size: 14,
                  color: CupertinoColors.systemGrey3,
                ),
                onTap: () {
                  // Future: Show profile or GitHub
                },
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 68,
                  thickness: 0.5,
                  color: isDark
                      ? CupertinoColors.systemGrey.withValues(alpha: 0.2)
                      : CupertinoColors.systemGrey4.withValues(alpha: 0.5),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildThanksSection(BuildContext context, bool isDark) {
    return ClubCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.heart_fill,
                color: CupertinoColors.systemRed,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '致谢',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '感谢所有为本项目贡献代码、提出建议和报告问题的开发者和用户。你们的支持是我们前进的动力。特别感谢所有测试人员在开发阶段的辛勤付出。',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: isDark
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.label.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, bool isDark) {
    final items = [
      {
        'title': 'GitHub 仓库',
        'icon': CupertinoIcons.doc_text_fill,
        'color': CupertinoColors.systemGrey,
        'url': 'https://github.com/iOS-Club-XAUAT/ios_club_app'
      },
      {
        'title': '加入我们',
        'icon': CupertinoIcons.person_2_fill,
        'color': CupertinoColors.systemBlue,
        'url': 'https://iosclub.org'
      },
    ];

    return ClubCard(
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;

          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: Icon(
                  item['icon'] as IconData,
                  color: item['color'] as Color,
                  size: 22,
                ),
                title: Text(
                  item['title'] as String,
                  style: const TextStyle(fontSize: 17),
                ),
                trailing: const Icon(
                  CupertinoIcons.chevron_forward,
                  size: 14,
                  color: CupertinoColors.systemGrey3,
                ),
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
                  color: isDark
                      ? CupertinoColors.systemGrey.withValues(alpha: 0.2)
                      : CupertinoColors.systemGrey4.withValues(alpha: 0.5),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Column(
      children: [
        Text(
          '© 2026 iOS Club',
          style: TextStyle(
            fontSize: 13,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Made with ❤️ in Xi\'an',
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? CupertinoColors.systemGrey.withValues(alpha: 0.5)
                : CupertinoColors.systemGrey2,
          ),
        ),
      ],
    );
  }
}
