import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ios_club_app/core/services/net_service.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

class NetPage extends StatefulWidget {
  const NetPage({super.key});

  @override
  State<NetPage> createState() => _NetPageState();
}

class _NetPageState extends State<NetPage> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = _data == null;
      _error = null;
    });

    try {
      final data = await NetService.get(forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _data = data;
      });
    } catch (e) {
      if (!mounted) return;
      if (_data != null) {
        showClubSnackBar(
          context,
          const Text('刷新失败，已保留当前校园网数据'),
        );
      } else {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const _LoadingView();
    }
    if (_data != null) {
      return _DataContent(
        data: _data!,
        onRefresh: () {
          _loadData(forceRefresh: true);
        },
      );
    }
    if (_error != null) {
      return _ErrorView(
        error: _error!,
        onRetry: () {
          _loadData();
        },
      );
    }
    return const _EmptyView();
  }
}

class _DataContent extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onRefresh;

  const _DataContent({
    required this.data,
    required this.onRefresh,
  });

  String _formatBytes(dynamic bytes) {
    if (bytes == null) return '0 B';

    try {
      double value = double.parse(bytes.toString());
      const units = ['B', 'KB', 'MB', 'GB', 'TB'];
      int unitIndex = 0;

      while (value >= 1000 && unitIndex < units.length - 1) {
        value /= 1000;
        unitIndex++;
      }

      return '${value.toStringAsFixed(2)} ${units[unitIndex]}';
    } catch (e) {
      return bytes.toString();
    }
  }

  String timeFormat(int s) {
    int m = s ~/ 60;
    int sRemainder = s % 60;

    int h = m ~/ 60;
    int mRemainder = m % 60;

    int d = h ~/ 24;
    int hRemainder = h % 24;

    return "$d天$hRemainder小时$mRemainder分$sRemainder秒";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.clubColors;

    // Apple 风格配色
    final cardColor = colors.cardBackground;
    final primaryTextColor = colors.label;
    final secondaryTextColor = colors.secondaryLabel;

    return CustomScrollView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverAppBar.large(
          title: const Text('校园网数据'),
          centerTitle: false,
          backgroundColor: theme.scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: onRefresh,
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                // 顶部大卡片 - 流量使用
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.95 + (0.05 * value),
                      child: Opacity(
                        opacity: value,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: ClubRadii.card, // Apple 风格圆角
                            boxShadow: [
                              BoxShadow(
                                color:
                                    colors.shadowColor.withValues(alpha: 0.8),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.data_usage_rounded,
                                size: 48,
                                color: theme.primaryColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '已用流量',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: secondaryTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatBytes(data['sum_bytes']),
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: primaryTextColor,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      theme.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: ClubRadii.card,
                                ),
                                child: Text(
                                  "在线时长: ${timeFormat(data['sum_seconds'])}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // 详情列表 - iOS Inset Grouped List 风格
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: ClubRadii.panel,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    colors.shadowColor.withValues(alpha: 0.8),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _DetailRow(
                                icon: Icons.person_rounded,
                                iconColor: colors.primary,
                                title: '用户名',
                                value: data['user_name'] ?? '未知',
                                isFirst: true,
                              ),
                              const _Divider(),
                              _DetailRow(
                                icon: Icons.wifi_rounded,
                                iconColor: colors.success,
                                title: 'IP 地址',
                                value: data['online_ip'] ?? '未知',
                                onTap: () => _copyToClipboard(
                                    context, data['online_ip']),
                                showArrow: true,
                              ),
                              const _Divider(),
                              _DetailRow(
                                icon: Icons.shopping_bag_rounded,
                                iconColor: colors.warning,
                                title: '产品套餐',
                                value: data['products_name'] ?? '未知',
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(BuildContext context, String? text) {
    if (text == null) return;
    Clipboard.setData(ClipboardData(text: text));
    showClubSnackBar(context, const Text('已复制到剪贴板'));
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;
  final bool showArrow;

  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.onTap,
    this.isFirst = false,
    this.isLast = false,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.clubColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? ClubRadii.panelRadius : Radius.zero,
          bottom: isLast ? ClubRadii.panelRadius : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: ClubRadii.control,
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: colors.onAccent,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colors.label,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: colors.secondaryLabel,
                ),
              ),
              if (showArrow) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: colors.tertiaryLabel,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final colors = context.clubColors;
    return Divider(
      height: 1,
      indent: 50, // Icon width + padding
      color: colors.separator,
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: LoadingStateView(
        title: '正在读取校园网数据',
        subtitle: '正在同步流量、在线时长和账号信息',
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.clubColors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: colors.danger),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.secondaryLabel),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final colors = context.clubColors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: colors.secondaryLabel),
          const SizedBox(height: 16),
          Text(
            '暂无数据',
            style: TextStyle(color: colors.secondaryLabel, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
