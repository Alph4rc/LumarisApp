import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/club_radii.dart';
import '../theme/club_smooth_corners.dart';
import '../theme/club_theme.dart';

@immutable
class ClubMenuItem<T> {
  const ClubMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.isDestructive = false,
    this.enabled = true,
  });

  final T value;
  final String label;
  final IconData? icon;
  final bool isDestructive;
  final bool enabled;
}

class ClubMenu<T> extends StatelessWidget {
  const ClubMenu({
    super.key,
    required this.items,
    required this.onSelected,
    this.icon = CupertinoIcons.ellipsis_circle,
    this.tooltip,
  });

  final List<ClubMenuItem<T>> items;
  final ValueChanged<T> onSelected;
  final IconData icon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final ClubColors colors = context.clubColors;
    final BorderSide borderSide = BorderSide(
      color: colors.separator.withValues(alpha: 0.18),
      width: 0.75,
    );

    return PopupMenuButton<T>(
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      splashRadius: 18,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 10),
      color: colors.cardBackground.withValues(alpha: 0.96),
      surfaceTintColor: Colors.transparent,
      shadowColor: colors.shadowColor.withValues(alpha: 0.18),
      elevation: 10,
      constraints: const BoxConstraints(minWidth: 196, maxWidth: 240),
      shape: ClubSmoothCorners.shape(
        ClubRadii.card,
        side: borderSide,
      ),
      menuPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemBuilder: (BuildContext context) {
        return items.map((ClubMenuItem<T> item) {
          final Color foregroundColor = item.enabled
              ? (item.isDestructive ? colors.danger : colors.label)
              : colors.tertiaryLabel;

          return PopupMenuItem<T>(
            value: item.value,
            enabled: item.enabled,
            padding: EdgeInsets.zero,
            child: _ClubMenuEntry(
              label: item.label,
              icon: item.icon,
              foregroundColor: foregroundColor,
            ),
          );
        }).toList(growable: false);
      },
      onSelected: onSelected,
      child: Icon(
        icon,
        size: 19,
        color: colors.secondaryLabel,
      ),
    );
  }
}

class _ClubMenuEntry extends StatelessWidget {
  const _ClubMenuEntry({
    required this.label,
    required this.foregroundColor,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: ShapeDecoration(
        shape: ClubSmoothCorners.shape(ClubRadii.navigation),
      ),
      child: Row(
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 18, color: foregroundColor),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: foregroundColor,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
