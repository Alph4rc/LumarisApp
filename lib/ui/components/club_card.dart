import 'package:flutter/material.dart';
import 'package:ios_club_app/ui/components/club_radii.dart';

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
    final isDark = theme.brightness == Brightness.dark;

    return RepaintBoundary(
      child: Container(
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          color: isDark ? theme.hoverColor : theme.colorScheme.surface,
          borderRadius: borderRadius,
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: child,
      ),
    );
  }
}
