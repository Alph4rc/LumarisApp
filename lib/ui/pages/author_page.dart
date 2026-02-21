import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthorPage extends StatelessWidget {
  const AuthorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('关于作者'),
            centerTitle: false,
            surfaceTintColor: Colors.transparent,
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(context),
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, '贡献者'),
                      _buildContributorsList(context),
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, '特别感谢'),
                      _buildThankYouCard(context),
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

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1C1C1E)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            CupertinoIcons.hammer_fill,
            size: 48,
            color: CupertinoColors.systemBlue,
          ),
          const SizedBox(height: 16),
          Text(
            'iOS Club App Team',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '致力于为 iOS Club 成员提供更好的服务',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
      ),
    );
  }

  Widget _buildContributorsList(BuildContext context) {
    final contributors = ['LuckyFish', 'zealous', '乔博睿'];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1C1C1E)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: contributors.asMap().entries.map((entry) {
          final index = entry.key;
          final name = entry.value;
          final isLast = index == contributors.length - 1;

          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.person_fill,
                    color: CupertinoColors.systemBlue,
                    size: 20,
                  ),
                ),
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(
                  CupertinoIcons.chevron_forward,
                  size: 16,
                  color: CupertinoColors.systemGrey3,
                ),
                onTap: () {
                  // Placeholder for future profile navigation
                },
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  indent: 56, // Align with text start
                  thickness: 0.5,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildThankYouCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1C1C1E)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(CupertinoIcons.heart_fill,
                  color: CupertinoColors.systemRed, size: 20),
              SizedBox(width: 8),
              Text(
                '致谢',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '感谢所有为本项目贡献代码、提出建议和报告问题的开发者和用户（排名不分先后）。你们的支持是我们前进的动力。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}
