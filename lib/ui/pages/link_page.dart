import 'package:flutter/material.dart';
import 'package:ios_club_app/core/services/link_service.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ios_club_app/core/models/link_model.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/components/icon_font.dart';
import 'package:ios_club_app/ui/components/club_scaffold.dart';
import 'package:ios_club_app/ui/components/empty_widget.dart';

class LinkPage extends StatelessWidget {
  const LinkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ClubScaffold(
      useSliverAppBar: false,
      appBar: const ClubAppBar(
        title: '校园导航',
      ),
      body: FutureBuilder<List<CategoryModel>>(
        future: LinkService.getLinks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: EmptyWidget(
                  title: '加载失败',
                  subtitle: snapshot.error.toString(),
                  icon: Icons.error_outline,
                ),
              );
            } else {
              final data = snapshot.data ?? [];
              if (data.isEmpty) {
                return const Center(
                  child: EmptyWidget(
                    title: '暂无导航链接',
                    subtitle: '稍后再来看看吧',
                    icon: Icons.link_off,
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 32),
                physics: const BouncingScrollPhysics(),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return CategorySection(category: data[index]);
                },
              );
            }
          } else {
            return const Center(
              child: LoadingStateView(
                title: '正在加载导航链接',
                subtitle: '正在整理常用站点与分类入口',
              ),
            );
          }
        },
      ),
    );
  }
}

class CategorySection extends StatelessWidget {
  final CategoryModel category;

  const CategorySection({super.key, required this.category});

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 32, right: 32, bottom: 8, top: 24),
          child: Text(
            category.name.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ClubCard(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 6 : 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 20,
                childAspectRatio: 0.8,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: category.links.length,
              itemBuilder: (context, index) {
                final link = category.links[index];
                return _LinkItem(
                  link: link,
                  onTap: () => _launchURL(link.url),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _LinkItem extends StatefulWidget {
  final LinkModel link;
  final VoidCallback onTap;

  const _LinkItem({
    required this.link,
    required this.onTap,
  });

  @override
  State<_LinkItem> createState() => _LinkItemState();
}

class _LinkItemState extends State<_LinkItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: _isPressed ? 0.6 : 1.0,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: _isPressed ? 0.95 : 1.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 图标背景容器
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: FutureBuilder<Widget?>(
                    future: IconUtil.getIconFont(widget.link),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return IconTheme(
                          data: IconThemeData(
                            size: 26,
                            color: colorScheme.primary,
                          ),
                          child: snapshot.data!,
                        );
                      }
                      return Icon(
                        Icons.language,
                        size: 26,
                        color: colorScheme.primary,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // 名称
              Text(
                widget.link.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
