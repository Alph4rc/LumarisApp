import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/state/bus_tile_store.dart';
import '../club_card.dart';

class BusTile extends StatelessWidget {
  const BusTile({super.key});

  @override
  Widget build(BuildContext context) {
    final busStore = Get.find<BusTileStore>();

    return ClubCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed('/SchoolBus'),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(() {
              if (busStore.isLoading.value) {
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              }

              final busData = busStore.busCount.value;
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
                            borderRadius: BorderRadius.circular(12),
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
