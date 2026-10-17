import 'package:material_ui/material_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('McThemeData', () {
    test('should expose expected semantic colors in light theme', () {
      final theme = McThemeData.materialTheme(McColors.light);
      final colors = theme.extension<McColors>();

      expect(theme.colorScheme.primary, McColors.light.primary);
      expect(theme.scaffoldBackgroundColor, McColors.light.groupedBackground);
      expect(colors?.label, McColors.light.label);
    });

    test('should expose expected semantic colors in dark theme', () {
      final theme = McThemeData.materialTheme(McColors.dark);
      final colors = theme.extension<McColors>();

      expect(theme.colorScheme.primary, McColors.dark.primary);
      expect(theme.scaffoldBackgroundColor, McColors.dark.groupedBackground);
      expect(colors?.label, McColors.dark.label);
    });

    testWidgets('should resolve fallback McColors from brightness', (
      WidgetTester tester,
    ) async {
      late McColors resolved;

      await tester.pumpWidget(
        MaterialApp(
          themeMode: ThemeMode.dark,
          darkTheme: ThemeData(brightness: Brightness.dark),
          home: Builder(
            builder: (context) {
              resolved = context.mc.colors;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved, McColors.dark);
    });

    testWidgets('should bridge dark theme to Cupertino widgets', (
      WidgetTester tester,
    ) async {
      late ThemeData resolvedTheme;
      late McColors resolvedColors;
      late Brightness cupertinoBrightness;
      late Color cupertinoPrimaryColor;

      await tester.pumpWidget(
        MaterialApp(
          themeMode: ThemeMode.dark,
          darkTheme: McThemeData.materialTheme(McColors.dark),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                resolvedTheme = Theme.of(context);
                resolvedColors = context.mc.colors;
                final cupertinoTheme = CupertinoTheme.of(context);
                cupertinoBrightness = cupertinoTheme.brightness!;
                cupertinoPrimaryColor = cupertinoTheme.primaryColor;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(resolvedTheme.brightness, Brightness.dark);
      expect(
        resolvedTheme.scaffoldBackgroundColor,
        McColors.dark.groupedBackground,
      );
      expect(resolvedColors, McColors.dark);
      expect(cupertinoBrightness, Brightness.dark);
      expect(cupertinoPrimaryColor, McColors.dark.primary);
    });
  });
}
