import 'dart:ui';
import 'package:flutter/material.dart';

class ClubAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ClubAppBar({
    super.key,
    this.title,
    this.actions,
    this.backgroundColor,
    this.elevation = 0,
    this.centerTitle = true,
    this.titleWidget,
    this.bottom,
  });

  final String? title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double elevation;
  final bool centerTitle;
  final Widget? titleWidget;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final effectiveBgColor = backgroundColor ?? colors.surface.withValues(alpha: 0.8);

    return AppBar(
      title: titleWidget ??
          Text(
            title ?? '',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
      actions: actions,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Back',
      ),
      backgroundColor: Colors.transparent, // transparent so flexibleSpace handles color
      elevation: elevation,
      centerTitle: centerTitle,
      bottom: bottom,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(color: effectiveBgColor),
        ),
      ),
    );
  }
}
