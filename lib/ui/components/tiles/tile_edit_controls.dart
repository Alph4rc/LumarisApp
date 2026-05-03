import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/state/tile_edit_notifier.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/components/empty_widget.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

/// Controls for entering and exiting tile edit mode
class TileEditControls extends ConsumerWidget {
  const TileEditControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditMode = ref.watch(
      tileEditControllerProvider.select((value) => value.isEditMode),
    );
    final controller = ref.read(tileEditControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          const Text(
            '快捷功能',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),

          // Edit/Done button
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isEditMode
                ? _buildDoneButton(context, controller)
                : _buildEditButton(context, controller),
          ),
        ],
      ),
    );
  }

  /// Build edit button
  Widget _buildEditButton(BuildContext context, TileEditNotifier controller) {
    final colors = context.clubColors;

    return TextButton.icon(
      key: const ValueKey('edit_button'),
      onPressed: () => controller.toggleEditMode(),
      icon: const Icon(Icons.edit_outlined, size: 18),
      label: const Text('编辑'),
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  /// Build done button
  Widget _buildDoneButton(BuildContext context, TileEditNotifier controller) {
    final colors = context.clubColors;

    return ElevatedButton.icon(
      key: const ValueKey('done_button'),
      onPressed: () => controller.toggleEditMode(),
      icon: const Icon(Icons.check, size: 18),
      label: const Text('完成'),
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onAccent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: 2,
      ),
    );
  }
}

/// Visual indicator for edit mode (optional overlay)
class EditModeIndicator extends ConsumerWidget {
  final Widget child;

  const EditModeIndicator({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditMode = ref.watch(
      tileEditControllerProvider.select((value) => value.isEditMode),
    );
    final colors = context.clubColors;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        border: isEditMode
            ? Border.all(
                color: colors.primary.withValues(alpha: 0.3),
                width: 2,
              )
            : null,
        borderRadius: ClubRadii.control,
      ),
      child: child,
    );
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
          title: '暂无快捷功能', icon: Icons.widgets_outlined, subtitle: '请在编辑模式中添加'),
    );
  }
}

/// Available tiles list for edit mode (shows hidden tiles)
class AvailableTilesList extends ConsumerWidget {
  const AvailableTilesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tileEditState = ref.watch(tileEditControllerProvider);
    final controller = ref.read(tileEditControllerProvider.notifier);
    final allTiles = tileEditState.config.configurations;
    final hiddenTiles = allTiles.where((t) => !t.isVisible).toList();
    final colors = context.clubColors;

    if (hiddenTiles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0, top: 16.0),
            child: Text(
              '更多功能',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
          ),
          ClubCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: hiddenTiles.asMap().entries.map((entry) {
                final index = entry.key;
                final tileId = entry.value.id;
                final isLast = index == hiddenTiles.length - 1;

                return Column(
                  children: [
                    ClubListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: colors.success,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          color: colors.onAccent,
                          size: 16,
                        ),
                      ),
                      title: Text(
                        tileId,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () => controller.toggleVisibility(tileId),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4.0),
                    ),
                    if (!isLast)
                      const Divider(
                          height: 1, indent: 48, endIndent: 16, thickness: 0.5),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
