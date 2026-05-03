import 'package:flutter/material.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

Widget themedTestApp({
  required Widget child,
  ThemeMode themeMode = ThemeMode.light,
}) {
  final lightTheme = ClubTheme.lightTheme();
  final darkTheme = ClubTheme.darkTheme();

  return MaterialApp(
    theme: themeMode == ThemeMode.dark ? darkTheme : lightTheme,
    darkTheme: darkTheme,
    themeMode: themeMode,
    home: Scaffold(
      body: child,
    ),
  );
}
