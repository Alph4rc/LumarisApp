import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/ui/components/club_radii.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import '../club_card.dart';
import '../../../state/electricity_store.dart';

class ElectricityTile extends ConsumerWidget {
  const ElectricityTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final electricity = ref.watch(electricityStoreProvider);

    return ClubCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => AppRouter.push(AppRoutes.electricity),
          borderRadius: ClubRadii.tile,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Builder(builder: (context) {
              // Loading state
              if (electricity.isLoading) {
                return const Center(
                  child: LoadingStateView(
                    title: '正在读取电费',
                    subtitle: '',
                    compact: true,
                    padding: EdgeInsets.zero,
                  ),
                );
              }

              // Has Data state
              if (electricity.hasData) {
                final amount = electricity.electricity;
                final isLow = amount <= 10;
                final primaryColor = isLow
                    ? CupertinoColors.destructiveRed
                    : CupertinoColors.activeBlue;

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
                          child: Icon(
                            CupertinoIcons.bolt_fill,
                            color: primaryColor,
                            size: 24,
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
                      '当前电费',
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

              // Unsubscribed state
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
                      CupertinoIcons.bolt_fill,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '电费查询',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodySmall?.color ??
                          Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '点击订阅',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: Colors.grey,
                    ),
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
