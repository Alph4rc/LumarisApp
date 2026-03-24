import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/features/system/tile_edit_controller.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';

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
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  late AnimationController _jiggleController;
  late Animation<double> _jiggleAnimation;

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

    _jiggleController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    // Slight rotation back and forth
    _jiggleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.015), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.015, end: -0.015), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -0.015, end: 0.0), weight: 25),
    ]).animate(_jiggleController);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _jiggleController.dispose();
    super.dispose();
  }

  void _onDragStarted() {
    setState(() => _isDragging = true);
    _scaleController.forward();
    _jiggleController.stop();

    // Haptic feedback on drag start
    if (PlatformUtils.isIOS || PlatformUtils.isAndroid) {
      HapticFeedback.mediumImpact();
    }
  }

  void _onDragEnd() {
    setState(() => _isDragging = false);
    _scaleController.reverse();

    final controller = Get.find<TileEditController>();
    if (controller.isEditMode.value) {
      _jiggleController.repeat(reverse: true);
    }

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

      if (isEditMode && !_isDragging) {
        if (!_jiggleController.isAnimating) {
          // Create a slightly random offset so they don't all jiggle exactly identical
          Future.delayed(Duration(milliseconds: widget.index * 50), () {
            if (mounted && controller.isEditMode.value) {
              _jiggleController.repeat();
            }
          });
        }
      } else {
        _jiggleController.stop();
        _jiggleController.reset();
      }

      Widget content = AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _jiggleAnimation]),
        builder: (context, child) {
          return Transform.rotate(
            angle: isEditMode && !_isDragging ? _jiggleAnimation.value : 0.0,
            child: Transform.scale(
              scale: _isDragging ? _scaleAnimation.value : 1.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: _isDragging
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Original tile content
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: widget.child,
                    ),

                    // Make the whole card act as a drag handle in edit mode
                    if (isEditMode && !PlatformUtils.isMPFlutter)
                      Positioned.fill(
                        child: ReorderableDragStartListener(
                          index: widget.index,
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                      ),

                    // iOS style minus button on top left
                    if (isEditMode)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: _buildHideButton(controller),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );

      return content;
    });
  }

  Widget _buildHideButton(TileEditController controller) {
    return GestureDetector(
      onTap: () async {
        try {
          await controller.toggleVisibility(widget.tileId);
        } catch (e) {
          // Ignore error, or log it if needed
        }
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade400.withValues(alpha: 0.9), // iOS style grey
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.remove, // Simple minus
          color: Colors.white,
          size: 16,
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
        borderRadius: BorderRadius.circular(24),
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
                  borderRadius: BorderRadius.circular(24),
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
