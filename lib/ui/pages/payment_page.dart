import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/features/education/models/payment_model.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/state/payment_store.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';

class PaymentPage extends ConsumerWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payment = ref.watch(paymentStoreProvider);
    final controller = ref.read(paymentStoreProvider.notifier);
    final colors = context.clubColors;

    return Scaffold(
      appBar: ClubAppBar(
        title: '饭卡',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.loadData,
            tooltip: '刷新',
          ),
        ],
      ),
      body: _buildContent(context, payment, controller, colors),
    );
  }

  Widget _buildContent(
    BuildContext context,
    PaymentState payment,
    PaymentStore controller,
    ClubColors colors,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        _buildBalanceCard(payment, colors),
        const SizedBox(height: 24),
        if (payment.isLoading)
          const LoadingStateView(
            title: '正在同步饭卡余额',
            subtitle: '正在获取最新流水，请稍候...',
            showCard: true,
          )
        else if (payment.errorMessage.isNotEmpty)
          _buildLoginPrompt(colors)
        else ...[
          _buildRecentTransactionsSection(payment, colors),
          const SizedBox(height: 24),
          _buildSettingsSection(payment, controller, colors),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildBalanceCard(PaymentState payment, ClubColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary,
            colors.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '校园一卡通',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.contactless_outlined,
                color: Colors.white.withValues(alpha: 0.6),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            '当前余额',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            payment.hasData
                ? '¥${payment.totalRecharge.toStringAsFixed(2)}'
                : '¥ ---',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsSection(PaymentState payment, ClubColors colors) {
    final recentRecords = payment.records
        .where((r) =>
            r.turnoverType.contains('支付') ||
            r.turnoverType.contains('消费') ||
            r.turnoverType.contains('充值'))
        .toList();

    if (recentRecords.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            '最近交易',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.secondaryLabel,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ClubCard(
          child: Column(
            children: List.generate(
              recentRecords.length.clamp(0, 10),
              (index) {
                final record = recentRecords[index];
                final isLast = index == recentRecords.length.clamp(0, 10) - 1;
                return Column(
                  children: [
                    _buildTransactionItem(record, colors),
                    if (!isLast)
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: colors.separator.withValues(alpha: 0.05),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(PaymentModel record, ClubColors colors) {
    final isRecharge = record.turnoverType.contains('充值');
    final amount = record.amount;
    final date = record.datetimeStr;
    final description = record.resume;

    return ClubListTile(
      title: Text(description.trim()),
      subtitle: Text(date),
      trailing: Text(
        '${isRecharge ? '+' : '-'}${amount.toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: isRecharge ? colors.success : colors.label,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(ClubColors colors) {
    return ClubCard(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.tertiaryLabel.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 40,
              color: colors.tertiaryLabel,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '无饭卡数据',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请登录教务处账号以查看余额和交易流水',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: colors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    PaymentState payment,
    PaymentStore controller,
    ClubColors colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            '设置',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.secondaryLabel,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ClubCard(
          child: ClubListTile(
            leading: Icon(Icons.apps_rounded, color: colors.primary),
            title: const Text('显示饭卡磁贴'),
            subtitle: const Text('在首页显示余额概览'),
            trailing: CupertinoSwitch(
              value: payment.isShowTile,
              onChanged: (value) => controller.toggleTileShow(value),
            ),
          ),
        ),
      ],
    );
  }
}

