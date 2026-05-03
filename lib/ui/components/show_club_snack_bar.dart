import 'package:flutter/material.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

void showClubSnackBar(BuildContext context, Widget child) {
  final colors = context.clubColors;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: child,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      backgroundColor: colors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: ClubRadii.control,
        side: BorderSide(color: colors.separator),
      ),
    ),
  );
}
