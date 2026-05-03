import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:ios_club_app/ui/components/club_app_bar.dart';

/// 统一的页面脚手架，在需要下拉时使用类似 CustomScrollView 和 CupertinoSliverNavigationBar。
/// API 保持与 Scaffold 一致。
class ClubScaffold extends StatelessWidget {
  final bool useSliverAppBar;
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final ScrollPhysics? physics;
  
  // Scaffold additional properties
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final List<Widget>? persistentFooterButtons;
  final AlignmentDirectional persistentFooterAlignment;
  final Widget? drawer;
  final DrawerCallback? onDrawerChanged;
  final Widget? endDrawer;
  final DrawerCallback? onEndDrawerChanged;
  final Widget? bottomSheet;
  final bool? resizeToAvoidBottomInset;
  final bool primary;

  const ClubScaffold({
    super.key,
    this.useSliverAppBar = true,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.physics,
    this.floatingActionButtonAnimator,
    this.persistentFooterButtons,
    this.persistentFooterAlignment = AlignmentDirectional.centerEnd,
    this.drawer,
    this.onDrawerChanged,
    this.endDrawer,
    this.onEndDrawerChanged,
    this.bottomSheet,
    this.resizeToAvoidBottomInset,
    this.primary = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget? title;
    Widget? leading;
    Widget? trailing;
    Color? navBackgroundColor;

    if (appBar != null) {
      if (appBar is AppBar) {
        final materialAppBar = appBar as AppBar;
        title = materialAppBar.title;
        leading = materialAppBar.leading;
        if (materialAppBar.actions != null && materialAppBar.actions!.isNotEmpty) {
          trailing = Row(
            mainAxisSize: MainAxisSize.min,
            children: materialAppBar.actions!,
          );
        }
      } else if (appBar is CupertinoNavigationBar) {
        final cupertinoAppBar = appBar as CupertinoNavigationBar;
        title = cupertinoAppBar.middle;
        leading = cupertinoAppBar.leading;
        trailing = cupertinoAppBar.trailing;
        navBackgroundColor = cupertinoAppBar.backgroundColor;
      } else if (appBar is ClubAppBar) {
        final clubAppBar = appBar as ClubAppBar;
        title = clubAppBar.titleWidget ?? (clubAppBar.title != null ? Text(clubAppBar.title!) : null);
        
        // ClubAppBar 默认带有返回按钮
        final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
        final bool canPop = parentRoute?.canPop ?? false;
        
        if (canPop) {
          leading = IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
          );
        }

        if (clubAppBar.actions != null && clubAppBar.actions!.isNotEmpty) {
          trailing = Row(
            mainAxisSize: MainAxisSize.min,
            children: clubAppBar.actions!,
          );
        }
      }
    }

    final colors = Theme.of(context).colorScheme;
    final effectiveNavBgColor = navBackgroundColor ?? colors.surface.withValues(alpha: 0.8);

    if (!useSliverAppBar) {
      return Scaffold(
        appBar: appBar,
        backgroundColor: backgroundColor ?? colors.surface,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        floatingActionButtonAnimator: floatingActionButtonAnimator,
        persistentFooterButtons: persistentFooterButtons,
        persistentFooterAlignment: persistentFooterAlignment,
        drawer: drawer,
        onDrawerChanged: onDrawerChanged,
        endDrawer: endDrawer,
        onEndDrawerChanged: onEndDrawerChanged,
        bottomNavigationBar: bottomNavigationBar,
        bottomSheet: bottomSheet,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        primary: primary,
        extendBody: extendBody,
        extendBodyBehindAppBar: true, // Force to true for frosted glass effect on ClubAppBar
        body: body,
      );
    }

    final scrollPhysics = physics ?? const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );

    List<Widget> sliverChildren = [];

    if (appBar != null) {
      sliverChildren.add(
        CupertinoSliverNavigationBar(
          largeTitle: title,
          leading: leading,
          trailing: trailing,
          backgroundColor: effectiveNavBgColor,
          border: null,
          stretch: true,
        ),
      );
    }

    if (body != null) {
      if (body is CustomScrollView) {
        // 如果传入的是 CustomScrollView，则展开其 slivers
        final customScroll = body as CustomScrollView;
        sliverChildren.addAll(customScroll.slivers);
      } else {
        // 如果是普通 Widget，包裹在 SliverToBoxAdapter 中
        // 注意：如果你原本使用 SingleChildScrollView，建议改为普通的 Column，
        // 由 ClubScaffold 统一接管滑动，以实现 CupertinoSliverNavigationBar 的大标题效果。
        sliverChildren.add(
          SliverToBoxAdapter(
            child: body,
          ),
        );
      }
    }

    Widget scrollBody = CustomScrollView(
      physics: scrollPhysics,
      slivers: sliverChildren,
    );

    return Scaffold(
      backgroundColor: backgroundColor ?? colors.surface,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      floatingActionButtonAnimator: floatingActionButtonAnimator,
      persistentFooterButtons: persistentFooterButtons,
      persistentFooterAlignment: persistentFooterAlignment,
      drawer: drawer,
      onDrawerChanged: onDrawerChanged,
      endDrawer: endDrawer,
      onEndDrawerChanged: onEndDrawerChanged,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      primary: primary,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      body: scrollBody,
    );
  }
}
