import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/features/system/tile_edit_controller.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/empty_widget.dart';

/// Controls for entering and exiting tile edit mode
class TileEditControls extends StatelessWidget {
  const TileEditControls({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TileEditController>();

    return Obx(() {
      final isEditMode = controller.isEditMode.value;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title
            const Text(
              '快捷功能',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Edit/Done button
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isEditMode
                  ? _buildDoneButton(controller)
                  : _buildEditButton(controller),
            ),
          ],
        ),
      );
    });
  }

  /// Build edit button
  Widget _buildEditButton(TileEditController controller) {
    return TextButton.icon(
      key: const ValueKey('edit_button'),
      onPressed: () => controller.toggleEditMode(),
      icon: const Icon(Icons.edit_outlined, size: 18),
      label: const Text('编辑'),
      style: TextButton.styleFrom(
        foregroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  /// Build done button
  Widget _buildDoneButton(TileEditController controller) {
    return ElevatedButton.icon(
      key: const ValueKey('done_button'),
      onPressed: () => controller.toggleEditMode(),
      icon: const Icon(Icons.check, size: 18),
      label: const Text('完成'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: 2,
      ),
    );
  }
}

/// Visual indicator for edit mode (optional overlay)
class EditModeIndicator extends StatelessWidget {
  final Widget child;

  const EditModeIndicator({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TileEditController>();

    return Obx(() {
      final isEditMode = controller.isEditMode.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          border: isEditMode
              ? Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                  width: 2,
                )
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      );
    });
  }
}

/// Empty state message when all tiles are hidden
class EmptyTilesMessage extends StatelessWidget {
  const EmptyTilesMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return ClubCard(
      margin: const EdgeInsets.all(16),
      child: EmptyWidget(
          title: '暂无快捷功能',
          icon: Icons.widgets_outlined,
          subtitle: '请在编辑模式中添加'),
    );
  }
}

/// Available tiles list for edit mode (shows hidden tiles)
class AvailableTilesList extends StatelessWidget {
  const AvailableTilesList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TileEditController>();

    return Obx(() {
      final allTiles = controller.allTiles;
      final hiddenTiles = allTiles.where((t) => !t.isVisible).toList();

      if (hiddenTiles.isEmpty) {
        return const SizedBox.shrink();
      }

      return ClubCard(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.visibility_off, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '已隐藏的磁贴',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: hiddenTiles.map((tile) {
                return _buildHiddenTileChip(tile.id, controller);
              }).toList(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHiddenTileChip(String tileId, TileEditController controller) {
    return ActionChip(
      avatar: const Icon(Icons.add_circle_outline, size: 18),
      label: Text(tileId),
      onPressed: () => controller.toggleVisibility(tileId),
    );
  }
}
