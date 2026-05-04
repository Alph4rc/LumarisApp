import 'package:flutter/material.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

void showClubSnackBar(BuildContext context, Widget child) {
  final colors = context.clubColors;
  final messenger = ScaffoldMessenger.maybeOf(context);

  if (messenger != null) {
    messenger.showSnackBar(
      SnackBar(
        content: child,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: ClubRadii.card,
          side: BorderSide(
            color: colors.separator.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
    );
    return;
  }

  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) {
    return;
  }

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (overlayContext) {
      final overlayColors = overlayContext.clubColors;

      return IgnorePointer(
        child: SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 520),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: overlayColors.cardBackground,
                    borderRadius: ClubRadii.card,
                    border: Border.all(
                      color: overlayColors.separator.withValues(alpha: 0.1),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      color: Theme.of(overlayContext).colorScheme.onSurface,
                    ),
                    child: child,
                  ),
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
