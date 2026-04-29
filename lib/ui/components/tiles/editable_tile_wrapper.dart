import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/features/system/tile_edit_controller.dart';
import 'package:ios_club_app/ui/components/club_radii.dart';

/// Wrapper for tiles that adds edit mode functionality
class EditableTileWrapper extends ConsumerStatefulWidget {
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
  ConsumerState<EditableTileWrapper> createState() =>
      _EditableTileWrapperState();
}

class _EditableTileWrapperState extends ConsumerState<EditableTileWrapper>
    with TickerProviderStateMixin {
  late AnimationController _jiggleController;
  late Animation<double> _jiggleAnimation;
  Timer? _jiggleDelayTimer;

  @override
  void initState() {
    super.initState();

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
    _jiggleDelayTimer?.cancel();
    _jiggleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tileEditState = ref.watch(tileEditControllerProvider);
    final controller = ref.read(tileEditControllerProvider.notifier);
    final isEditMode = tileEditState.isEditMode;

    if (isEditMode) {
      if (!_jiggleController.isAnimating &&
          !(_jiggleDelayTimer?.isActive ?? false)) {
        // Create a slightly random offset so they don't all jiggle exactly identical
        final delay = Duration(milliseconds: widget.index * 50);
        void startJiggle() {
          if (mounted && ref.read(tileEditControllerProvider).isEditMode) {
            _jiggleController.repeat();
          }
        }

        if (delay == Duration.zero) {
          startJiggle();
        } else {
          _jiggleDelayTimer = Timer(delay, startJiggle);
        }
      }
    } else {
      _jiggleDelayTimer?.cancel();
      _jiggleDelayTimer = null;
      _jiggleController.stop();
      _jiggleController.reset();
    }

    Widget content = AnimatedBuilder(
      animation: _jiggleAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: isEditMode ? _jiggleAnimation.value : 0.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: ClubRadii.tile,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Original tile content
                ClipRRect(
                  borderRadius: ClubRadii.tile,
                  child: widget.child,
                ),

                // Make the whole card act as a drag handle in edit mode
                if (isEditMode)
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
        );
      },
    );

    return content;
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
}
