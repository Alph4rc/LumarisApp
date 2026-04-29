import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/ui/components/club_radii.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import '../../../state/payment_store.dart';
import '../club_card.dart';

class PaymentTile extends StatelessWidget {
  const PaymentTile({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PaymentStore>();

    return ClubCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: ClubRadii.tile,
          onTap: () => Get.toNamed('/Payment'),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(() {
              // Loading state
              if (controller.isLoading.value) {
                return const Center(
                  child: LoadingStateView(
                    title: '正在读取饭卡',
                    subtitle: '',
                    compact: true,
                    padding: EdgeInsets.zero,
                  ),
                );
              }

              // Has Data state
              if (!controller.isLoading.value &&
                  controller.totalRecharge.value != 0) {
                final amount = controller.totalRecharge.value;
                final isLow = amount <= 10;
                final primaryColor = isLow
                    ? CupertinoColors.destructiveRed
                    : CupertinoColors.systemOrange;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Hero(
                            tag: '饭卡',
                            child: Icon(
                              Icons.monetization_on_rounded,
                              color: primaryColor,
                              size: 24,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (isLow)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: CupertinoColors.destructiveRed
                                  .withValues(alpha: 0.12),
                              borderRadius: ClubRadii.navigation,
                            ),
                            child: const Text(
                              '余额不足',
                              style: TextStyle(
                                fontSize: 10,
                                color: CupertinoColors.destructiveRed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '当前余额',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodySmall?.color ??
                            Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '¥${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: isLow
                            ? CupertinoColors.destructiveRed
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              }

              // Unsubscribed / Unbound state
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.monetization_on_rounded,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '饭卡余额',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodySmall?.color ??
                          Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    controller.errorMessage.value.isNotEmpty
                        ? controller.errorMessage.value
                        : '点击查看',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: controller.errorMessage.value.isNotEmpty
                          ? CupertinoColors.destructiveRed
                          : Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
