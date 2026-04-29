import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ios_club_app/ui/components/club_radii.dart';

Future<void> showClubModalBottomSheet(BuildContext context, Widget child,
    {bool isScrollControlled = true, double maxHeight = 0}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
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
      return ClipRRect(
        borderRadius: ClubRadii.sheetTop,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.7),
              borderRadius: ClubRadii.sheetTop,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.1),
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
                      : Padding(
                          padding: const EdgeInsets.all(24),
                          child: child,
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
