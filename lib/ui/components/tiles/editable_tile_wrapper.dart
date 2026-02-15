import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/features/system/tile_edit_controller.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

/// Wrapper for tiles that adds edit mode functionality
class EditableTileWrapper extends StatefulWidget {
  final Widget child;
  final String tileId;
  final int index;

  const EditableTileWrapper({
    super.key,
    required this.child,
    required this.tileId,
    required this.index,
  });

  @override
  State<EditableTileWrapper> createState() => _EditableTileWrapperState();
}

class _EditableTileWrapperState extends State<EditableTileWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onDragStarted() {
    setState(() => _isDragging = true);
    _scaleController.forward();

    // Haptic feedback on drag start
    if (PlatformUtils.isIOS || PlatformUtils.isAndroid) {
      HapticFeedback.mediumImpact();
    }
  }

  void _onDragEnd() {
    setState(() => _isDragging = false);
    _scaleController.reverse();

    // Haptic feedback on drag end
    if (PlatformUtils.isIOS || PlatformUtils.isAndroid) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TileEditController>();

    return Obx(() {
      final isEditMode = controller.isEditMode.value;

      return AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isDragging ? _scaleAnimation.value : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: _isDragging
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : isEditMode
                        ? [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
              ),
              child: Stack(
                children: [
                  // Original tile content
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.child,
                  ),

                  // Edit mode overlay
                  if (isEditMode)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                  // Hide button in edit mode
                  if (isEditMode)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildHideButton(controller),
                    ),

                  // Drag handle indicator in edit mode (also acts as drag listener)
                  if (isEditMode && !PlatformUtils.isMPFlutter)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _buildDragHandle(),
                    ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildDragHandle() {
    return ReorderableDragStartListener(
      index: widget.index,
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.drag_indicator,
            color: Colors.grey[700],
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildHideButton(TileEditController controller) {
    return GestureDetector(
      onTap: () async {
        try {
          await controller.toggleVisibility(widget.tileId);
        } catch (e) {
          // Show error if trying to hide all tiles
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('至少需要保留一个磁贴'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.remove_circle_outline,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  /// Callback for drag started (used by parent)
  void onDragStarted() => _onDragStarted();

  /// Callback for drag end (used by parent)
  void onDragEnd() => _onDragEnd();
}

/// Draggable tile for reordering
class DraggableTileItem extends StatelessWidget {
  final Widget child;
  final String tileId;
  final int index;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;

  const DraggableTileItem({
    super.key,
    required this.child,
    required this.tileId,
    required this.index,
    this.onDragStarted,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<int>(
      data: index,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: 0.8,
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 2 - 24,
            child: child,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: child,
      ),
      onDragStarted: onDragStarted,
      onDragEnd: (_) => onDragEnd?.call(),
      child: child,
    );
  }
}

/// Tap-based reordering for WeChat Mini Program
class TapReorderTileItem extends StatelessWidget {
  final Widget child;
  final String tileId;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const TapReorderTileItem({
    super.key,
    required this.child,
    required this.tileId,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          child,
          if (isSelected)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue,
                    width: 3,
                  ),
                  color: Colors.blue.withValues(alpha: 0.1),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.blue,
                    size: 48,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
