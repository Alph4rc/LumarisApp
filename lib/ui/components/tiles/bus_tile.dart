import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/bus_tile_store.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import '../club_card.dart';

class BusTile extends ConsumerWidget {
  const BusTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final busStore = ref.watch(busTileStoreProvider);
    final colors = context.clubColors;

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
                return Center(
                  child: LoadingStateView(
                    title: l10n.busLoading,
                    subtitle: '',
                    compact: true,
                    padding: EdgeInsets.zero,
                  ),
                );
              }

              final busData = busStore.busCount;
              final primaryColor = colors.success;

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
                            '$busData${l10n.busInfo}',
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
                    l10n.schoolBus,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    busData > 0 ? '$busData' : l10n.noBusToday,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: busData > 0 ? colors.label : colors.secondaryLabel,
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
