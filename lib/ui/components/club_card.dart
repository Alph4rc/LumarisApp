import 'package:flutter/material.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/theme/club_smooth_corners.dart';
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
      decoration: ShapeDecoration(
        color: colors.cardBackground,
        shape: ClubSmoothCorners.shape(
          borderRadius,
          side: BorderSide(
            color:
                colors.separator.withValues(alpha: 0.1), // Very subtle border
            width: 0.5,
          ),
        ),
        shadows: theme.brightness == Brightness.dark
            ? []
            : [
                BoxShadow(
                  color: colors.shadowColor,
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
              ],
      ),
      child: child,
    );
  }
}
