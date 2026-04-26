import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:ios_club_app/core/utils/animations/animated_card.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/features/system/tile_edit_controller.dart';
import 'package:ios_club_app/ui/components/tiles/tile_edit_controls.dart';
import 'package:ios_club_app/ui/components/tiles/editable_tile_wrapper.dart';

import 'package:ios_club_app/ui/components/tiles/bus_tile.dart';
import 'package:ios_club_app/ui/components/tiles/electricity_tile.dart';
import 'package:ios_club_app/ui/components/tiles/payment_tile.dart';

class TilesWidget extends StatefulWidget {
  const TilesWidget({super.key});

  @override
  State<TilesWidget> createState() => _TilesWidgetState();
}

class _TilesWidgetState extends State<TilesWidget>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Listen to app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // Auto-exit edit mode when navigating away
    if (Get.isRegistered<TileEditController>()) {
      final controller = Get.find<TileEditController>();
      controller.forceExitEditMode();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Handle app going to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      final controller = Get.find<TileEditController>();
      if (controller.isEditMode.value) {
        // Save changes when app goes to background
        controller.forceExitEditMode();
      }
    }
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
          else if (isEditMode)
            _buildReorderableGrid(visibleTiles, controller)
          else
            _buildNormalGrid(visibleTiles),
        ],
      );
    });
  }

  /// Build reorderable grid for full Flutter platforms
  Widget _buildReorderableGrid(
      List visibleTiles, TileEditController controller) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: ReorderableGridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
          childAspectRatio: 1.0,
        ),
        itemCount: visibleTiles.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        onReorder: (oldIndex, newIndex) async {
          try {
            await controller.reorderTile(
              visibleTiles[oldIndex].id,
              oldIndex,
              newIndex,
            );
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('重新排序失败: $e'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        },
        itemBuilder: (context, index) {
          final tile = visibleTiles[index];
          return EditableTileWrapper(
            key: ValueKey(tile.id),
            tileId: tile.id,
            index: index,
            child: buildTile(tile.id, context),
          );
        },
      ),
    );
  }

  /// Build normal grid (non-edit mode)
  Widget _buildNormalGrid(List visibleTiles) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
          childAspectRatio: 1.0,
        ),
        itemCount: visibleTiles.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final tile = visibleTiles[index];
          return AnimatedCard(
            key: ValueKey(tile.id),
            delay: Duration(milliseconds: 100 * index),
            child: buildTile(tile.id, context),
          );
        },
      ),
    );
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
