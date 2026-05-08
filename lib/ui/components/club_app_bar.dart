import 'package:flutter/material.dart';

class ClubAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ClubAppBar({
    super.key,
    this.title,
    this.actions,
    this.backgroundColor = Colors.transparent,
    this.elevation = 0,
    this.centerTitle = true,
    this.titleWidget,
    this.bottom,
    this.showBackButton,
    this.onBackPressed,
  });

  final String? title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double elevation;
  final bool centerTitle;
  final Widget? titleWidget;
  final PreferredSizeWidget? bottom;
  final bool? showBackButton;
  final VoidCallback? onBackPressed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final canPop = Navigator.of(context).canPop() || (route?.canPop ?? false);
    final shouldShowBackButton = showBackButton ?? canPop;

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
      automaticallyImplyLeading: false,
      leading: shouldShowBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed:
                  onBackPressed ?? () => Navigator.of(context).maybePop(),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            )
          : null,
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      bottom: bottom,
    );
  }
}
