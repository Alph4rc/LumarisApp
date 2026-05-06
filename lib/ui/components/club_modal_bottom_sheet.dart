import 'package:flutter/material.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

Future<void> showClubModalBottomSheet(BuildContext context, Widget child,
    {bool isScrollControlled = true, double maxHeight = 0}) {
  final colors = context.clubColors;
  final a = MediaQuery.of(context).size.width;

  if (maxHeight == 0) {
    maxHeight = MediaQuery.of(context).size.height * 0.6;
  }

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: isScrollControlled,
    constraints: BoxConstraints(maxWidth: a, minWidth: a, maxHeight: maxHeight),
    builder: (BuildContext context) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: ClubRadii.sheetTop,
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: colors.borderStrong.withValues(alpha: 0.8),
                borderRadius: ClubRadii.pill,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: isScrollControlled
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: child,
                    )
                  : Padding(padding: const EdgeInsets.all(24), child: child),
            ),
          ],
        ),
      );
    },
  );
}
