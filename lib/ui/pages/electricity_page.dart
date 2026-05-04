import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/utils/animations/animations.dart';
import 'package:ios_club_app/features/education/models/electric_data.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';

import 'package:ios_club_app/ui/components/empty_widget.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';
import 'package:ios_club_app/state/electricity_store.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

class ElectricityPage extends ConsumerStatefulWidget {
  const ElectricityPage({super.key});

  @override
  ConsumerState<ElectricityPage> createState() => _ElectricityPageState();
}

class _ElectricityPageState extends ConsumerState<ElectricityPage> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _subscriptionEmailController =
      TextEditingController();
  final TextEditingController _subscriptionThresholdController =
      TextEditingController(text: '10');
  bool _isSubscriptionLoading = false;
  bool _hasLoadedSubscriptions = false;
  String _subscriptionEmail = '';

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_restoreSubscriptionPreferences);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _subscriptionEmailController.dispose();
    _subscriptionThresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final electricityState = ref.watch(electricityStoreProvider);
    if (electricityState.hasData &&
        !_hasLoadedSubscriptions &&
        !_isSubscriptionLoading) {
      Future<void>.microtask(_loadSubscriptions);
    }
    if (kIsWeb) {
      return const Scaffold(
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
          actions: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              onPressed: _handleElectricityAction,
              child: Icon(
                electricityState.hasData
                    ? CupertinoIcons.arrow_2_circlepath
                    : CupertinoIcons.add_circled_solid,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _handlePullToRefresh,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 当前电费头部
                _buildCurrentElectricityHeader(),

                const SizedBox(height: 32),

                // 电费图表卡片
                if (electricityState.hasData) _buildChartCard(),

                if (electricityState.hasData) const SizedBox(height: 24),

                // 设置选项
                if (electricityState.hasData) _buildSettingsSection(),

                const SizedBox(height: 24),

                if (electricityState.hasData)
                  _buildSubscriptionSection(
                      hasElectricityData: electricityState.hasData),
              ],
            ),
          ),
        ));
  }

  Future<void> _handlePullToRefresh() async {
    final controller = ref.read(electricityStoreProvider.notifier);
    final electricityState = ref.read(electricityStoreProvider);
    if (electricityState.hasData) {
      await controller.refreshElectricityData();
      await _loadSubscriptions(force: true);
      return;
    }
    await controller.loadElectricityData();
    if (!mounted) {
      return;
    }
    if (ref.read(electricityStoreProvider).hasData) {
      await _loadSubscriptions(force: true);
    }
  }

  Widget _buildCurrentElectricityHeader() {
    final electricityState = ref.watch(electricityStoreProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = electricityState.electricity <= 10
        ? colorScheme.error
        : _successColor(context);

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            '当前余额',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          if (electricityState.hasData)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 4.0),
                  child: Text(
                    '¥',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  electricityState.electricity.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    color: colorScheme.onSurface,
                    letterSpacing: -1,
                  ),
                ),
              ],
            )
          else
            Text(
              '暂无数据',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                letterSpacing: -1,
              ),
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: electricityState.hasData
                  ? statusColor.withValues(alpha: 0.1)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              electricityState.hasData
                  ? (electricityState.electricity <= 10 ? '余额不足，请及时充值' : '余额充足')
                  : '点击右上角添加电费数据',
              style: TextStyle(
                fontSize: 13,
                color: electricityState.hasData
                    ? statusColor
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
          padding: const EdgeInsets.all(24),
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
                    icon: CupertinoIcons.chart_bar_alt_fill,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '用电花费',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '近${dailySummaries.length}天',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildCostOverview(
                  totalCost: totalCost,
                  todayCost: todayCost,
                  averageDailyCost: averageDailyCost,
                  peakData: peakData,
                ),
                const SizedBox(height: 32),
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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMinimalMetric(
                label: '总计花费',
                value: '¥${totalCost.toStringAsFixed(2)}',
              ),
            ),
            Container(
                width: 1,
                height: 40,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            Expanded(
              child: _buildMinimalMetric(
                label: '今日花费',
                value: '¥${todayCost.toStringAsFixed(2)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildMinimalMetric(
                label: '日均花费',
                value: '¥${averageDailyCost.toStringAsFixed(2)}',
              ),
            ),
            Container(
                width: 1,
                height: 40,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            Expanded(
              child: _buildMinimalMetric(
                label: '峰值时段',
                value: _formatHourCost(peakData),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMinimalMetric({
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
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
          '每小时明细',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: recentData.map((item) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
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

    return SizedBox(
      width: 44,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            data.value.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: fillRatio.clamp(0.05, 1.0).toDouble(),
                child: Container(
                  width: 12,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${data.timestamp.hour}:00',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
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
    return '${data.timestamp.hour}:00 / ¥${data.value.toStringAsFixed(1)}';
  }

  Color _successColor(BuildContext context) {
    return context.clubColors.success;
  }

  Widget _buildSettingsSection() {
    final electricityState = ref.watch(electricityStoreProvider);
    final controller = ref.read(electricityStoreProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedCard(
      delay: const Duration(milliseconds: 300),
      child: ClubCard(
        child: Column(
          children: [
            ClubListTile(
              leading: Icon(CupertinoIcons.square_grid_2x2,
                  color: colorScheme.primary),
              title: const Text('添加到首页',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text('在首页显示电费磁贴'),
              trailing: CupertinoSwitch(
                value: electricityState.tiles.contains('电费'),
                onChanged: (value) async {
                  await controller.toggleTile('电费', value);
                },
              ),
            ),
            ClubListTile(
              leading: Icon(CupertinoIcons.money_yen_circle,
                  color: colorScheme.primary),
              title: const Text('电费充值',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: const Text('跳转至微信进行电费充值'),
              trailing: Icon(CupertinoIcons.chevron_right,
                  size: 16, color: colorScheme.onSurfaceVariant),
              onTap: () async {
                await ref.read(electricityServiceProvider).openRechargePage();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionSection({required bool hasElectricityData}) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedCard(
      delay: const Duration(milliseconds: 360),
      child: ClubCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '低余额订阅',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hasElectricityData
                              ? '当余额低于阈值时，通过邮箱提醒你及时充值'
                              : '先添加电费页面后，再开启低余额邮件提醒',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasElectricityData)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      onPressed: _isSubscriptionLoading
                          ? null
                          : () => _loadSubscriptions(force: true),
                      child: Icon(
                        CupertinoIcons.arrow_clockwise,
                        size: 20,
                        color: _isSubscriptionLoading
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
            if (!hasElectricityData)
              _buildSubscriptionEmptyState(
                icon: CupertinoIcons.link,
                title: '还没有电费数据',
                subtitle: '先在本页绑定宿舍电费链接，订阅会自动使用当前房间信息。',
              )
            else ...[
              ClubListTile(
                leading: Icon(
                  CupertinoIcons.bell,
                  color: colorScheme.primary,
                ),
                title: const Text(
                  '添加低余额提醒',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  _subscriptionEmail.isEmpty
                      ? '设置阈值后，余额低于该金额时会收到邮件提醒'
                      : '当前邮箱 $_subscriptionEmail，余额低于该金额时会收到邮件提醒',
                ),
                trailing: Icon(
                  CupertinoIcons.add_circled,
                  size: 18,
                  color: colorScheme.primary,
                ),
                onTap: _showCreateSubscriptionDialog,
              ),
              _buildDivider(),
              if (_isSubscriptionLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                  ),
                )
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      child: Column(
        children: [
          Icon(
            icon,
            size: 28,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color:
          Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
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
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('电费管理'),
        message: const Text('选择要执行的操作'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(electricityStoreProvider.notifier)
                  .refreshElectricityData();
              await _loadSubscriptions(force: true);
            },
            child: const Text('刷新数据'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              _showInputDialog();
            },
            child: const Text('更换房间'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
      ),
    );
  }

  void _showInputDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('获取电费'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            children: [
              const Text(
                '请打开建大财务处电费详情页面，复制页面URL并粘贴到下方输入框',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context).cardColor,
                elevation: 0,
                child: CupertinoTextField(
                  controller: _urlController,
                  placeholder: '请输入URL',
                  padding: const EdgeInsets.all(12),
                  clearButtonMode: OverlayVisibilityMode.editing,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              _urlController.clear();
            },
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              Navigator.of(context).pop();
              final value = await ref
                  .read(electricityServiceProvider)
                  .fetchCurrentBalance(
                    url: _urlController.text,
                  );
              if (!mounted) {
                return;
              }
              if (value != null) {
                _urlController.clear();
                final controller = ref.read(electricityStoreProvider.notifier);
                await controller.setElectricityValue(value);
                await controller.loadElectricityData();
                await _loadSubscriptions(force: true);
              } else {
                _urlController.clear();
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreSubscriptionPreferences() async {
    final email =
        await ref.read(electricityServiceProvider).getSavedSubscriptionEmail();
    if (!mounted) {
      return;
    }

    setState(() {
      _subscriptionEmail = email;
    });
  }

  Future<void> _loadSubscriptions({bool force = false}) async {
    if (_isSubscriptionLoading) {
      return;
    }
    if (!force && _hasLoadedSubscriptions) {
      return;
    }

    setState(() {
      _isSubscriptionLoading = true;
    });

    try {
      final service = ref.read(electricityServiceProvider);
      final email = await service.getSavedSubscriptionEmail();

      if (!mounted) {
        return;
      }

      setState(() {
        _subscriptionEmail = email;
        _hasLoadedSubscriptions = true;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      showClubSnackBar(context, Text('加载电费订阅失败: $e'));
      setState(() {
        _hasLoadedSubscriptions = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubscriptionLoading = false;
        });
      }
    }
  }

  void _showCreateSubscriptionDialog() {
    _subscriptionEmailController.text = _subscriptionEmail;
    if (_subscriptionThresholdController.text.trim().isEmpty) {
      _subscriptionThresholdController.text = '10';
    }

    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('添加低余额提醒'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            children: [
              const Text(
                '系统会使用当前绑定的宿舍电费页面，在余额低于设定阈值时发送邮件提醒。',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              Card(
                color: Theme.of(dialogContext).cardColor,
                elevation: 0,
                child: CupertinoTextField(
                  controller: _subscriptionEmailController,
                  placeholder: '提醒邮箱',
                  keyboardType: TextInputType.emailAddress,
                  padding: const EdgeInsets.all(12),
                  clearButtonMode: OverlayVisibilityMode.editing,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: Theme.of(dialogContext).cardColor,
                elevation: 0,
                child: CupertinoTextField(
                  controller: _subscriptionThresholdController,
                  placeholder: '提醒阈值，例如 10',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  padding: const EdgeInsets.all(12),
                  clearButtonMode: OverlayVisibilityMode.editing,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _createSubscription();
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  Future<void> _createSubscription() async {
    final email = _subscriptionEmailController.text.trim();
    final thresholdText = _subscriptionThresholdController.text.trim();
    final threshold = double.tryParse(thresholdText);

    if (email.isEmpty) {
      showClubSnackBar(context, const Text('请输入提醒邮箱'));
      return;
    }
    if (!_isValidEmail(email)) {
      showClubSnackBar(context, const Text('请输入有效的邮箱地址'));
      return;
    }
    if (threshold == null || threshold <= 0) {
      showClubSnackBar(context, const Text('请输入大于 0 的提醒阈值'));
      return;
    }

    setState(() {
      _isSubscriptionLoading = true;
    });

    try {
      await ref.read(electricityServiceProvider).createSubscription(
            email: email,
            threshold: threshold,
          );

      if (!mounted) {
        return;
      }

      setState(() {
        _subscriptionEmail = email;
        _isSubscriptionLoading = false;
        _hasLoadedSubscriptions = false;
      });
      await _loadSubscriptions(force: true);
      if (!mounted) {
        return;
      }
      showClubSnackBar(context, const Text('低余额提醒已创建'));
    } catch (e) {
      if (!mounted) {
        return;
      }
      showClubSnackBar(context, Text('创建电费订阅失败: $e'));
      setState(() {
        _isSubscriptionLoading = false;
      });
    }
  }

  bool _isValidEmail(String value) {
    final emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegExp.hasMatch(value);
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
