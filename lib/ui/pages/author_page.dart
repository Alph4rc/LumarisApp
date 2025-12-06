import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthorPage extends StatelessWidget {
  const AuthorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('作者'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 联系方式
            const SectionTitle(title: '联系方式'),
            ClubCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      CupertinoIcons.mail,
                      color: CupertinoColors.systemBlue,
                    ),
                    title: const Text('电子邮件'),
                    subtitle: const Text('iosclubxauat@163.com'),
                    trailing: const Icon(CupertinoIcons.chevron_right),
                    onTap: () {
                      _launchUrl('mailto:iosclubxauat@163.com');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      CupertinoIcons.globe,
                      color: CupertinoColors.activeGreen,
                    ),
                    title: const Text('官方网站'),
                    subtitle: const Text('https://www.xauat.site'),
                    trailing: const Icon(CupertinoIcons.chevron_right),
                    onTap: () {
                      _launchUrl('https://www.xauat.site');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.gite,
                      color: CupertinoColors.systemOrange,
                    ),
                    title: const Text('Gitee'),
                    subtitle: const Text('https://gitee.com/XAUATiOSClub'),
                    trailing: const Icon(CupertinoIcons.chevron_right),
                    onTap: () {
                      _launchUrl('https://gitee.com/XAUATiOSClub');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 特别感谢
            const SectionTitle(title: '特别感谢'),
            ClubCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '感谢所有为本项目贡献代码、提出建议和报告问题的开发者和用户（排名不分先后）',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    _buildContributor('LuckyFish'),
                    const SizedBox(height: 8),
                    _buildContributor('zealous'),
                    const SizedBox(height: 8),
                    _buildContributor('乔博睿'),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildContributor(String name) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          child: Icon(CupertinoIcons.device_laptop, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
