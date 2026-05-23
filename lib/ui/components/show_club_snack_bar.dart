import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/theme/club_smooth_corners.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

void showClubSnackBar(BuildContext context, Widget child) {
  final colors = context.clubColors;
  final messenger = ScaffoldMessenger.maybeOf(context);

  if (messenger != null) {
    messenger.showSnackBar(
      SnackBar(
        content: _frostedContent(colors, child),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
      ),
    );
    return;
  }

  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (overlayContext) {
      final overlayColors = overlayContext.clubColors;

      return IgnorePointer(
        child: SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 20),
              child: _frostedContent(
                overlayColors,
                DefaultTextStyle.merge(
                  style: TextStyle(
                    color: Theme.of(overlayContext).colorScheme.onSurface,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  overlay.insert(entry);
  Future<void>.delayed(const Duration(seconds: 2), () {
    entry.remove();
  });
}

Widget _frostedContent(ClubColors colors, Widget child) {
  return ClubSmoothCorners.clip(
    borderRadius: const BorderRadius.all(ClubRadii.mdRadius),
    side: BorderSide(
      color: colors.separator.withValues(alpha: 0.1),
      width: 0.5,
    ),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.cardBackground.withValues(alpha: 0.8),
        ),
        child: child,
      ),
    ),
  );
}
