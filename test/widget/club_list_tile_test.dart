import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:smooth_corner/smooth_corner.dart';

import 'theme_test_helpers.dart';

void main() {
  group('ClubListTile', () {
    testWidgets('should display title subtitle leading trailing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        themedTestApp(
          child: const ClubListTile(
            leading: Icon(Icons.home),
            title: Text('标题'),
            subtitle: Text('说明'),
            trailing: Icon(Icons.chevron_right),
          ),
        ),
      );

      expect(find.text('标题'), findsOneWidget);
      expect(find.text('说明'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('should trigger on tap when enabled',
        (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        themedTestApp(
          child: ClubListTile(
            title: const Text('点击'),
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );

      await tester.tap(find.text('点击'));

      expect(tapped, true);
    });

    testWidgets('should not trigger on tap when disabled',
        (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        themedTestApp(
          child: ClubListTile(
            enabled: false,
            title: const Text('禁用'),
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );

      await tester.tap(find.text('禁用'));

      expect(tapped, false);
    });

    testWidgets('should apply default round radius',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        themedTestApp(
          child: const ClubListTile(
            title: Text('圆角'),
          ),
        ),
      );

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      final material = tester.widget<Material>(
        find
            .ancestor(
              of: find.byType(InkWell),
              matching: find.byType(Material),
            )
            .first,
      );

      expect(inkWell.borderRadius, ClubRadii.card);
      expect(material.shape, isA<SmoothRectangleBorder>());
    });

    testWidgets('should apply custom round radius',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        themedTestApp(
          child: const ClubListTile(
            borderRadius: ClubRadii.navigation,
            title: Text('自定义圆角'),
          ),
        ),
      );

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      final material = tester.widget<Material>(
        find
            .ancestor(
              of: find.byType(InkWell),
              matching: find.byType(Material),
            )
            .first,
      );

      expect(inkWell.borderRadius, ClubRadii.navigation);
      expect(
        (material.shape as SmoothRectangleBorder).borderRadius,
        ClubRadii.navigation,
      );
    });

    testWidgets('should show chevron when requested',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        themedTestApp(
          child: const ClubListTile(
            title: Text('箭头'),
            showChevron: true,
          ),
        ),
      );

      expect(find.byIcon(CupertinoIcons.chevron_right), findsOneWidget);
    });

    testWidgets('should apply selected background',
        (WidgetTester tester) async {
      const selectedColor = Colors.red;

      await tester.pumpWidget(
        themedTestApp(
          child: const ClubListTile(
            selected: true,
            selectedBackgroundColor: selectedColor,
            title: Text('选中'),
          ),
        ),
      );

      final containerFinder = find.byWidgetPredicate((Widget widget) {
        return widget is Ink &&
            widget.decoration is ShapeDecoration &&
            (widget.decoration as ShapeDecoration).color == selectedColor;
      });

      expect(containerFinder, findsOneWidget);
    });

    testWidgets('should respect custom content padding',
        (WidgetTester tester) async {
      const padding = EdgeInsets.symmetric(horizontal: 4, vertical: 6);

      await tester.pumpWidget(
        themedTestApp(
          child: const ClubListTile(
            contentPadding: padding,
            title: Text('间距'),
          ),
        ),
      );

      final containerFinder = find.byWidgetPredicate((Widget widget) {
        return widget is Padding && widget.padding == padding;
      });

      expect(containerFinder, findsOneWidget);
    });

    testWidgets('should use themed chevron color in dark mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        themedTestApp(
          themeMode: ThemeMode.dark,
          child: const ClubListTile(
            title: Text('深色箭头'),
            showChevron: true,
          ),
        ),
      );

      final chevron =
          tester.widget<Icon>(find.byIcon(CupertinoIcons.chevron_right));
      expect(chevron.color, ClubColors.dark.tertiaryLabel);
    });
  });
}
