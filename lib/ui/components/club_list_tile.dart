import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/theme/club_smooth_corners.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

class ClubListTile extends StatelessWidget {
  const ClubListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.contentPadding,
    this.borderRadius = ClubRadii.card,
    this.enabled = true,
    this.selected = false,
    this.showChevron = false,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.selectedBackgroundColor,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? contentPadding;
  final BorderRadiusGeometry borderRadius;
  final bool enabled;
  final bool selected;
  final bool showChevron;
  final TextStyle? titleTextStyle;
  final TextStyle? subtitleTextStyle;
  final Color? selectedBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.clubColors;
    final effectivePadding = contentPadding ??
        EdgeInsets.symmetric(
          horizontal: 16,
          vertical: subtitle == null ? 14 : 10,
        );
    final effectiveBorderRadius = ClubSmoothCorners.resolve(
      context,
      borderRadius,
    );
    final effectiveShape = ClubSmoothCorners.shape(borderRadius);
    final effectiveTitleStyle = TextStyle(
      fontSize: 16,
      color: enabled ? null : theme.disabledColor,
    ).merge(titleTextStyle);
    final effectiveSubtitleStyle = TextStyle(
      fontSize: 13,
      color: enabled ? colors.secondaryLabel : theme.disabledColor,
    ).merge(subtitleTextStyle);
    final effectiveTrailing = trailing ??
        (showChevron
            ? Icon(
                CupertinoIcons.chevron_right,
                size: 18,
                color: colors.tertiaryLabel,
              )
            : null);

    return Material(
      color: Colors.transparent,
      shape: effectiveShape,
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: ShapeDecoration(
          color: selected
              ? selectedBackgroundColor ?? colors.selectionFill
              : Colors.transparent,
          shape: effectiveShape,
        ),
        child: InkWell(
          borderRadius: effectiveBorderRadius,
          customBorder: effectiveShape,
          onTap: enabled ? onTap : null,
          onLongPress: enabled ? onLongPress : null,
          child: Padding(
            padding: effectivePadding,
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DefaultTextStyle.merge(
                        style: effectiveTitleStyle,
                        child: title,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        DefaultTextStyle.merge(
                          style: effectiveSubtitleStyle,
                          child: subtitle!,
                        ),
                      ],
                    ],
                  ),
                ),
                if (effectiveTrailing != null) ...[
                  const SizedBox(width: 12),
                  effectiveTrailing,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
