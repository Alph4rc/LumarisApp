import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';

Widget themedTestApp({
  required Widget child,
  ThemeMode themeMode = ThemeMode.light,
}) {
  final lightTheme = McThemeData.materialTheme(McColors.light);
  final darkTheme = McThemeData.materialTheme(McColors.dark);

  return MaterialApp(
    theme: themeMode == ThemeMode.dark ? darkTheme : lightTheme,
    darkTheme: darkTheme,
    themeMode: themeMode,
    home: Scaffold(body: child),
  );
}
