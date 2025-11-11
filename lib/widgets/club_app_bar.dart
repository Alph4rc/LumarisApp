import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

class ClubAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ClubAppBar(
      {super.key,
      this.title,
      this.actions,
      this.backgroundColor = Colors.transparent,
      this.elevation = 0,
      this.centerTitle = true,
      this.titleWidget,
      this.bottom,
      this.hero});

  final String? title;
  final Widget? hero;
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
    return AppBar(
      title: titleWidget ??
          (hero != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    hero!,
                    const SizedBox(width: 8),
                    Text(
                      title ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                )
              : Text(
                  title ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                )),
      actions: actions,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Back',
      ),
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      bottom: bottom,
      flexibleSpace: BlurWidget(child: SizedBox.expand()),
    );
  }
}

class BlurWidget extends StatelessWidget {
  const BlurWidget({
    super.key,
    this.child,
    this.sigmaX = 20,
    this.sigmaY = 20,
    this.radius = BorderRadius.zero,
  });

  final double sigmaX;

  final double sigmaY;

  final Widget? child;

  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter.grouped(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: DecoratedBox(
          decoration: BoxDecoration(color: theme.shadowColor),
          child: child,
        ),
      ),
    );
  }
}