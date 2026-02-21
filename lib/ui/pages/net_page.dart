import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ios_club_app/core/services/net_service.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';

class NetPage extends StatelessWidget {
  const NetPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 Material 3 风格的 Scaffold，背景色跟随主题
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: NetService.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingView();
          }

          if (snapshot.hasError) {
            return _ErrorView(error: snapshot.error.toString());
          }

          if (snapshot.hasData) {
            return _DataContent(data: snapshot.data!);
          }

          return const _EmptyView();
        },
      ),
    );
  }
}

class _DataContent extends StatelessWidget {
  final Map<String, dynamic> data;

  const _DataContent({required this.data});

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
    final isDark = theme.brightness == Brightness.dark;

    // Apple 风格配色
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverAppBar.large(
          title: const Text('校园网数据'),
          centerTitle: false,
          backgroundColor: theme.scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // 简单的刷新逻辑，重建页面
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => const NetPage(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                            borderRadius: BorderRadius.circular(20), // Apple 风格圆角
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
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
                                  color: theme.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
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
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _DetailRow(
                                icon: Icons.person_rounded,
                                iconColor: Colors.blue,
                                title: '用户名',
                                value: data['user_name'] ?? '未知',
                                isFirst: true,
                              ),
                              const _Divider(),
                              _DetailRow(
                                icon: Icons.wifi_rounded,
                                iconColor: Colors.green,
                                title: 'IP 地址',
                                value: data['online_ip'] ?? '未知',
                                onTap: () => _copyToClipboard(context, data['online_ip']),
                                showArrow: true,
                              ),
                              const _Divider(),
                              _DetailRow(
                                icon: Icons.shopping_bag_rounded,
                                iconColor: Colors.orange,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              if (showArrow) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      indent: 50, // Icon width + padding
      color: isDark ? Colors.grey[800] : Colors.grey[200],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: Colors.red[300]),
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
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => const NetPage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '暂无数据',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
