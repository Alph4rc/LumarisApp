import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ios_club_app/features/club/services/resource_service.dart';
import 'package:ios_club_app/features/club/models/resource_model.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/platform_dialog.dart';

class ResourcePage extends StatefulWidget {
  const ResourcePage({super.key});

  @override
  State<ResourcePage> createState() => _ResourcePageState();
}

class _ResourcePageState extends State<ResourcePage> {
  bool _isLoading = true;
  List<ResourceModel> _resources = [];

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    try {
      final resources = await ResourceService.getAllResources();
      if (resources != null) {
        setState(() {
          _resources = resources;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载资源信息失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ClubAppBar(title: '社团资源'),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CupertinoActivityIndicator(
                  radius: 14,
                ),
              ),
            )
          else if (_resources.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.folder,
                      size: 64,
                      color: CupertinoColors.systemGrey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '暂无资源',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '还没有添加任何资源',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final resource = _resources[index];
                    return _buildResourceCard(resource);
                  },
                  childCount: _resources.length,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResourceCard(ResourceModel resource) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClubCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 资源头部信息
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CupertinoColors.systemBlue.withValues(alpha: 0.05),
                    CupertinoColors.systemBlue.withValues(alpha: 0.02)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          CupertinoColors.systemBlue,
                          CupertinoColors.activeBlue,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Icon(
                        _getResourceIcon(resource.tag),
                        size: 24,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (resource.tag != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemBlue
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              resource.tag!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: CupertinoColors.systemBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 资源详细信息
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (resource.description != null &&
                      resource.description!.isNotEmpty) ...[
                    Text(
                      resource.description!,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (resource.tag != null && resource.tag!.isNotEmpty) ...[
                    _buildInfoRow(
                      icon: CupertinoIcons.link,
                      title: '链接',
                      value: resource.tag!,
                      isUrl: true,
                    ),
                    _buildDivider(),
                  ],
                  _buildInfoRow(
                    icon: CupertinoIcons.doc_text,
                    title: '资源ID',
                    value: resource.id,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    bool isUrl = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const Spacer(),
          if (isUrl)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                PlatformDialog.showConfirmDialog(
                  context,
                  title: '提示',
                  content: '即将打开链接: $value',
                  confirmText: '确定',
                );
              },
              child: const Text(
                '查看',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.activeBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
        height: 0.5, color: CupertinoColors.separator.withValues(alpha: 0.3));
  }

  IconData _getResourceIcon(String? type) {
    if (type == null) return CupertinoIcons.doc;

    switch (type.toLowerCase()) {
      case '文档':
      case 'document':
        return CupertinoIcons.doc;
      case '视频':
      case 'video':
        return CupertinoIcons.video_camera;
      case '图片':
      case 'image':
        return CupertinoIcons.photo;
      case '音频':
      case 'audio':
        return CupertinoIcons.music_note;
      case '链接':
      case 'link':
        return CupertinoIcons.link;
      default:
        return CupertinoIcons.doc;
    }
  }
}
