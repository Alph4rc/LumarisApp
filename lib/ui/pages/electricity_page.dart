import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';

import 'package:ios_club_app/core/utils/animations/animations.dart';
import 'package:ios_club_app/features/system/tile_service.dart';
import 'package:ios_club_app/core/models/electric_data.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/components/empty_widget.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/state/electricity_store.dart';

class ElectricityPage extends ConsumerStatefulWidget {
  const ElectricityPage({super.key});

  @override
  ConsumerState<ElectricityPage> createState() => _ElectricityPageState();
}

class _ElectricityPageState extends ConsumerState<ElectricityPage> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final electricityState = ref.watch(electricityStoreProvider);
    if (kIsWeb) {
      return Scaffold(
        appBar: ClubAppBar(
          title: '电费管理',
        ),
        body: EmptyWidget(
          title: '暂不支持Web版',
          subtitle: '请使用其他版本',
          icon: Icons.error,
        ),
      );
    }
    return Scaffold(
        appBar: ClubAppBar(
          title: '电费管理',
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 当前电费卡片
              _buildCurrentElectricityCard(),

              SizedBox(height: 20),

              // 电费图表卡片
              electricityState.hasData ? _buildChartCard() : Container(),

              electricityState.hasData ? SizedBox(height: 20) : Container(),

              // 设置选项
              _buildSettingsSection(),
            ],
          ),
        ));
  }

  Widget _buildCurrentElectricityCard() {
    final electricityState = ref.watch(electricityStoreProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;
    final statusColor = electricityState.electricity <= 10
        ? colorScheme.error
        : _successColor(colorScheme);
    return AnimatedCard(
      child: ClubCard(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: ClubRadii.control,
                    ),
                    child: Icon(
                      CupertinoIcons.bolt_fill,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    '当前电费',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _handleElectricityAction,
                    child: Icon(
                      electricityState.hasData
                          ? CupertinoIcons.refresh
                          : CupertinoIcons.add,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              electricityState.hasData
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¥${electricityState.electricity.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          electricityState.electricity <= 10 ? '余额不足' : '余额充足',
                          style: TextStyle(
                            fontSize: 14,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '暂无数据',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '点击右上角添加电费数据',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    final electricityState = ref.watch(electricityStoreProvider);
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedCard(
      delay: const Duration(milliseconds: 150),
      child: ClubCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Builder(builder: (context) {
            if (electricityState.isLoading) {
              return const SizedBox(
                height: 240,
                child: Center(
                  child: LoadingStateView(
                    title: '正在刷新用电趋势',
                    subtitle: '正在读取最新电费记录',
                    compact: true,
                    showCard: false,
                    padding: EdgeInsets.zero,
                  ),
                ),
              );
            }

            final data = electricityState.weeklyData;
            if (data.isEmpty) {
              return const SizedBox(
                height: 220,
                child: Center(
                  child: EmptyWidget(
                    title: '没有用电明细',
                    subtitle: '刷新后会在这里展示每小时花费',
                    icon: Icons.hourglass_empty,
                  ),
                ),
              );
            }

            final dailySummaries = _buildDailySummaries(data);
            final totalCost = data.fold<double>(
              0,
              (previousValue, item) => previousValue + item.value,
            );
            final todayCost = data
                .where((item) => _isSameDay(item.timestamp, DateTime.now()))
                .fold<double>(
                  0,
                  (previousValue, item) => previousValue + item.value,
                );
            final averageDailyCost = dailySummaries.isEmpty
                ? 0.0
                : totalCost / dailySummaries.length;
            final peakData = data.reduce(
              (currentPeak, item) =>
                  item.value > currentPeak.value ? item : currentPeak,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '用电花费',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '近${dailySummaries.length}天',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildCostOverview(
                  totalCost: totalCost,
                  todayCost: todayCost,
                  averageDailyCost: averageDailyCost,
                  peakData: peakData,
                ),
                const SizedBox(height: 18),
                _buildHourlyCostScroller(data),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCostOverview({
    required double totalCost,
    required double todayCost,
    required double averageDailyCost,
    required ElectricData peakData,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: ClubRadii.card,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCostMetric(
                  label: '实际花费',
                  value: '¥${totalCost.toStringAsFixed(2)}',
                  icon: CupertinoIcons.bolt_fill,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCostMetric(
                  label: '今日花费',
                  value: '¥${todayCost.toStringAsFixed(2)}',
                  icon: CupertinoIcons.sun_max_fill,
                  color: _warningColor(colorScheme),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCostMetric(
                  label: '日均花费',
                  value: '¥${averageDailyCost.toStringAsFixed(2)}',
                  icon: Icons.bar_chart,
                  color: _successColor(colorScheme),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCostMetric(
                  label: '峰值时段',
                  value: _formatHourCost(peakData),
                  icon: Icons.local_fire_department,
                  color: colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCostMetric({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: ClubRadii.control,
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyCostScroller(List<ElectricData> data) {
    final recentData = data.length > 24 ? data.sublist(data.length - 24) : data;
    final maxValue = recentData.map((item) => item.value).reduce(max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '小时花费',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: recentData.map((item) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _buildHourlyCostTile(
                  data: item,
                  maxValue: maxValue,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyCostTile({
    required ElectricData data,
    required double maxValue,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final fillRatio = maxValue <= 0 ? 0.0 : data.value / maxValue;

    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: ClubRadii.card,
      ),
      child: Column(
        children: [
          Text(
            _formatShortDate(data.timestamp),
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${data.timestamp.hour}:00',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 10,
            height: 48,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: fillRatio.clamp(0.08, 1.0).toDouble(),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: ClubRadii.xsBorder,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '¥${data.value.toStringAsFixed(1)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  List<_ElectricityDailySummary> _buildDailySummaries(List<ElectricData> data) {
    final dailyCosts = <DateTime, double>{};
    for (final item in data) {
      final date = DateTime(
        item.timestamp.year,
        item.timestamp.month,
        item.timestamp.day,
      );
      dailyCosts.update(
        date,
        (value) => value + item.value,
        ifAbsent: () => item.value,
      );
    }

    return dailyCosts.entries
        .map((entry) => _ElectricityDailySummary(
              date: entry.key,
              cost: entry.value,
            ))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  String _formatHourCost(ElectricData data) {
    return '${data.timestamp.hour}:00 ¥${data.value.toStringAsFixed(1)}';
  }

  String _formatShortDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  Color _successColor(ColorScheme colorScheme) {
    return colorScheme.brightness == Brightness.dark
        ? const Color(0xFF30D158)
        : const Color(0xFF248A3D);
  }

  Color _warningColor(ColorScheme colorScheme) {
    return colorScheme.brightness == Brightness.dark
        ? const Color(0xFFFFB340)
        : const Color(0xFFB85D00);
  }

  Widget _buildSettingsSection() {
    final electricityState = ref.watch(electricityStoreProvider);
    final controller = ref.read(electricityStoreProvider.notifier);
    return AnimatedCard(
      delay: const Duration(milliseconds: 300),
      child: ClubCard(
        child: Column(
          children: [
            electricityState.hasData
                ? Column(
                    children: [
                      ClubListTile(
                        leading: Icon(Icons.home),
                        title: Text('添加到首页'),
                        subtitle: Text('在首页显示电费磁贴'),
                        trailing: CupertinoSwitch(
                          value: electricityState.tiles.contains('电费'),
                          onChanged: (value) async {
                            await controller.toggleTile('电费', value);
                          },
                        ),
                      ),
                      ClubListTile(
                        leading: Icon(Icons.monetization_on_outlined),
                        title: Text('电费充值'),
                        subtitle: Text('跳转至微信进行电费充值'),
                        onTap: () async {
                          final prefs = PrefsService.instance;
                          var url =
                              prefs.getString(PrefsKeys.ELECTRICITY_URL) ?? '';
                          url = url.replaceAll('wxAccount', 'wxCharge');
                          await TileService.openInWeChat(url);
                        },
                      )
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  void _handleElectricityAction() {
    if (ref.read(electricityStoreProvider).hasData) {
      _showRefreshDialog();
    } else {
      _showInputDialog();
    }
  }

  void _showRefreshDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('电费管理'),
        content: Text('选择要执行的操作'),
        actions: [
          TextButton(
            child: Text('取消'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('更换房间'),
            onPressed: () {
              Navigator.of(context).pop();
              _showInputDialog();
            },
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(electricityStoreProvider.notifier)
                  .refreshElectricityData();
            },
            child: Text('刷新数据'),
          ),
        ],
      ),
    );
  }

  void _showInputDialog() {
    // 对于这种自定义输入框的对话框，我们保留原来的 Material 风格
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('获取电费'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16),
            Text(
              '请按照以下步骤操作：\n\n1. 打开建大财务处电费详情页面\n2. 复制页面URL\n3. 粘贴到下方输入框',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: '请输入URL',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('取消'),
            onPressed: () {
              Navigator.of(context).pop();
              _urlController.clear();
            },
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final value = await TileService.getTextAfterKeyword(
                url: _urlController.text,
              );
              if (value != null) {
                _urlController.clear();
                final controller = ref.read(electricityStoreProvider.notifier);
                await controller.setElectricityValue(value);
                await controller.loadElectricityData(); // 重新加载所有数据
              }
            },
            child: Text('确定'),
          ),
        ],
      ),
    );
  }
}

class _ElectricityDailySummary {
  const _ElectricityDailySummary({
    required this.date,
    required this.cost,
  });

  final DateTime date;
  final double cost;
}
