import 'package:flutter/material.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

class ClubCard extends StatelessWidget {
  const ClubCard({
    super.key,
    this.child,
    this.margin,
    this.padding,
    this.borderRadius = ClubRadii.card,
  });

  final Widget? child;
  final EdgeInsets? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.clubColors;

    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: borderRadius,
        border: Border.all(color: colors.separator.withValues(alpha: 0.5)),
        boxShadow: theme.brightness == Brightness.dark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );
  }
}
