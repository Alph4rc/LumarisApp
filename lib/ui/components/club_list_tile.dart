import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
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
    final isDark = theme.brightness == Brightness.dark;
    final effectivePadding = contentPadding ??
        EdgeInsets.symmetric(
          horizontal: 16,
          vertical: subtitle == null ? 20 : 12,
        );
    final effectiveBorderRadius =
        borderRadius.resolve(Directionality.of(context));
    final effectiveTitleStyle = TextStyle(
      fontSize: 16,
      color: enabled ? null : theme.disabledColor,
    ).merge(titleTextStyle);
    final effectiveSubtitleStyle = TextStyle(
      fontSize: 13,
      color: enabled
          ? (isDark
              ? Colors.white.withValues(alpha: 0.5)
              : CupertinoColors.secondaryLabel)
          : theme.disabledColor,
    ).merge(subtitleTextStyle);
    final effectiveTrailing = trailing ??
        (showChevron
            ? Icon(
                CupertinoIcons.chevron_right,
                size: 18,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : CupertinoColors.tertiaryLabel,
              )
            : null);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: effectiveBorderRadius,
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPress : null,
        child: Container(
          padding: effectivePadding,
          decoration: BoxDecoration(
            color: selected
                ? selectedBackgroundColor ??
                    theme.colorScheme.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: borderRadius,
          ),
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
    );
  }
}
