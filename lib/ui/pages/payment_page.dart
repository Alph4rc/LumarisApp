import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/features/education/models/payment_model.dart';
import 'package:ios_club_app/core/utils/animations/animated_card.dart';
import 'package:ios_club_app/core/utils/animations/animated_list_item.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/components/club_radii.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';

import 'package:ios_club_app/state/payment_store.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';

class PaymentPage extends StatelessWidget {
  final PaymentStore controller = Get.put(PaymentStore());

  PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Obx(() => _buildContent()),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return ClubAppBar(
      title: '饭卡余额',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: controller.loadData,
        ),
      ],
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatisticsSection(),
          Obx(() {
            if (controller.isLoading.value) {
              return const LoadingStateView(
                title: '正在读取饭卡余额',
                subtitle: '正在同步余额和近期流水，校园网络较慢时可能需要几秒',
                showCard: true,
              );
            }
            if (controller.errorMessage.value.isNotEmpty) {
              return _buildLoginPrompt();
            }
            return _buildRecentTransactionsSection();
          }),
          Obx(
            () => controller.errorMessage.value.isEmpty
                ? _buildSettingsSection()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: _buildStatCard(
        '余额',
        controller.totalRecharge.value,
        Icons.monetization_on_outlined,
        Colors.green,
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return AnimatedCard(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: ClubRadii.card,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: ClubRadii.control,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => controller.totalRecharge.value == 0
                      ? const Text(
                          '暂无数据',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Text(
                          '¥${amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsSection() {
    final recentRecords = controller.records
        .where((r) =>
            r.turnoverType.contains('支付') || r.turnoverType.contains('消费'))
        .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '最近消费',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (recentRecords.isEmpty)
            const Center(
              child: Text(
                '暂无消费记录',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          else
            AnimatedCard(
              delay: const Duration(milliseconds: 150),
              child: ClubCard(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentRecords.length.clamp(0, 5),
                    itemBuilder: (context, index) => AnimatedListItem(
                      index: index,
                      child: _buildTransactionItem(recentRecords[index]),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(PaymentModel record) {
    final isRecharge = record.turnoverType == '充值';
    final amount = record.amount;
    final date = record.datetimeStr;
    final description = record.resume;

    return ClubListTile(
      title: Text(
        description.trim(),
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        date,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: Text(
        '${isRecharge ? '+' : '-'}${amount.toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ClubCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.person_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                '暂无饭卡数据',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '请先登录教务处账号以查看饭卡余额和消费记录',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '设置',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ClubCard(
            child: Column(
              children: [
                ClubListTile(
                  leading: Icon(Icons.home),
                  title: Text('添加到首页'),
                  subtitle: Text('在首页显示饭卡磁贴'),
                  trailing: CupertinoSwitch(
                    value: controller.isShowTile.value,
                    onChanged: (value) => controller.toggleTileShow(value),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
