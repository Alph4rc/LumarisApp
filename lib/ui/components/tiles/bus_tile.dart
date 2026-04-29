import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/bus_tile_store.dart';
import 'package:ios_club_app/ui/components/club_radii.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import '../club_card.dart';

class BusTile extends ConsumerWidget {
  const BusTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busStore = ref.watch(busTileStoreProvider);

    return ClubCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => AppRouter.push(AppRoutes.schoolBus),
          borderRadius: ClubRadii.tile,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Builder(builder: (context) {
              if (busStore.isLoading) {
                return const Center(
                  child: LoadingStateView(
                    title: '正在获取校车',
                    subtitle: '',
                    compact: true,
                    padding: EdgeInsets.zero,
                  ),
                );
              }

              final busData = busStore.busCount;
              final primaryColor = CupertinoColors.activeGreen;

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
                          Icons.directions_bus_rounded,
                          color: primaryColor,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      if (busData > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.12),
                            borderRadius: ClubRadii.navigation,
                          ),
                          child: Text(
                            '$busData班次',
                            style: TextStyle(
                              fontSize: 10,
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '今日校车',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodySmall?.color ??
                          Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    busData > 0 ? '$busData' : '无班次',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: busData > 0
                          ? Theme.of(context).colorScheme.onSurface
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
