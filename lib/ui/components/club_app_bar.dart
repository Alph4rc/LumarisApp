import 'dart:ui';
import 'package:flutter/material.dart';

class ClubAppBar extends StatefulWidget implements PreferredSizeWidget {
  const ClubAppBar({
    super.key,
    this.title,
    this.actions,
    this.backgroundColor,
    this.elevation = 0,
    this.centerTitle = true,
    this.titleWidget,
    this.bottom,
    this.hero,
    this.blur = true,
    this.scrollController,
  });

  final String? title;
  final Widget? hero;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double elevation;
  final bool centerTitle;
  final Widget? titleWidget;
  final PreferredSizeWidget? bottom;
  final bool blur;
  final ScrollController? scrollController;

  @override
  State<ClubAppBar> createState() => _ClubAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(
      kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}

class _ClubAppBarState extends State<ClubAppBar> {
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_scrollListener);
    // Initial check
    if (widget.scrollController != null &&
        widget.scrollController!.hasClients &&
        widget.scrollController!.offset > 0) {
      _isScrolled = true;
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (widget.scrollController == null) return;
    final isScrolled = widget.scrollController!.offset > 0;
    if (isScrolled != _isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use a semi-transparent background if blur is enabled and scrolled
    final bool shouldShowBlur = widget.blur && _isScrolled;

    final effectiveBackgroundColor = widget.backgroundColor ??
        (shouldShowBlur
            ? (isDark
                ? Colors.black.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.7))
            : Colors.transparent);

    Widget appBar = AppBar(
      title: widget.titleWidget ??
          (widget.hero != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    widget.hero!,
                    const SizedBox(width: 8),
                    Text(
                      widget.title ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                )
              : Text(
                  widget.title ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                )),
      actions: widget.actions,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Back',
      ),
      backgroundColor: effectiveBackgroundColor,
      elevation: widget.elevation,
      centerTitle: widget.centerTitle,
      bottom: widget.bottom,
    );

    if (shouldShowBlur) {
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: appBar,
        ),
      );
    }

    return appBar;
  }
}
