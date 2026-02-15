import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/core/utils/animations/animated_card.dart';
import 'package:ios_club_app/features/system/tile_edit_controller.dart';
import 'package:ios_club_app/ui/components/tiles/tile_edit_controls.dart';

import 'package:ios_club_app/ui/components/tiles/bus_tile.dart';
import 'package:ios_club_app/ui/components/tiles/electricity_tile.dart';
import 'package:ios_club_app/ui/components/tiles/payment_tile.dart';

class TilesWidget extends StatefulWidget {
  const TilesWidget({super.key});

  @override
  State<TilesWidget> createState() => _TilesWidgetState();
}

class _TilesWidgetState extends State<TilesWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    // Auto-exit edit mode when navigating away
    final controller = Get.find<TileEditController>();
    controller.forceExitEditMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final controller = Get.find<TileEditController>();

    return Obx(() {
      final visibleTiles = controller.visibleTiles;
      final isEditMode = controller.isEditMode.value;

      return Column(
        children: [
          // Edit controls (replaces old title)
          const TileEditControls(),

          // Show available tiles list in edit mode
          if (isEditMode) const AvailableTilesList(),

          // Tiles grid or empty state
          if (visibleTiles.isEmpty)
            const EmptyTilesMessage()
          else
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: GridView.custom(
                gridDelegate: SliverQuiltedGridDelegate(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  pattern: [
                    for (int i = 0; i < visibleTiles.length; i++)
                      i == visibleTiles.length - 1 &&
                              visibleTiles.length % 2 == 1
                          ? const QuiltedGridTile(1, 2)
                          : const QuiltedGridTile(1, 1),
                  ],
                ),
                childrenDelegate: SliverChildBuilderDelegate(
                  (context, index) => AnimatedCard(
                    delay: Duration(milliseconds: 100 * index),
                    child: buildTile(visibleTiles[index].id, context),
                  ),
                  childCount: visibleTiles.length,
                ),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
              ),
            ),
        ],
      );
    });
  }
}

Widget buildTile(String tile, BuildContext context) {
  Widget? content;

  if (tile == '电费') {
    content = const ElectricityTile();
  }

  if (tile == '校车') {
    content = const BusTile();
  }

  if (tile == '饭卡') {
    content = const PaymentTile();
  }

  content ??= Container();

  return content;
}