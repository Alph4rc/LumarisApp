import 'package:flutter/material.dart';
import 'package:ios_club_app/ui/components/club_radii.dart';

void showClubSnackBar(BuildContext context, Widget child) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: child,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: ClubRadii.control,
      ),
    ),
  );
}
