import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';

void main() {
  group('ClubListTile', () {
    testWidgets('should display title subtitle leading trailing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClubListTile(
              leading: Icon(Icons.home),
              title: Text('标题'),
              subtitle: Text('说明'),
              trailing: Icon(Icons.chevron_right),
            ),
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
        MaterialApp(
          home: Scaffold(
            body: ClubListTile(
              title: const Text('点击'),
              onTap: () {
                tapped = true;
              },
            ),
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
        MaterialApp(
          home: Scaffold(
            body: ClubListTile(
              enabled: false,
              title: const Text('禁用'),
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('禁用'));

      expect(tapped, false);
    });

    testWidgets('should apply default round radius',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClubListTile(
              title: Text('圆角'),
            ),
          ),
        ),
      );

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));

      expect(
        inkWell.borderRadius,
        const BorderRadius.all(Radius.circular(20)),
      );
    });

    testWidgets('should show chevron when requested',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClubListTile(
              title: Text('箭头'),
              showChevron: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(CupertinoIcons.chevron_right), findsOneWidget);
    });

    testWidgets('should apply selected background',
        (WidgetTester tester) async {
      const selectedColor = Colors.red;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClubListTile(
              selected: true,
              selectedBackgroundColor: selectedColor,
              title: Text('选中'),
            ),
          ),
        ),
      );

      final containerFinder = find.byWidgetPredicate((Widget widget) {
        return widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == selectedColor;
      });

      expect(containerFinder, findsOneWidget);
    });

    testWidgets('should respect custom content padding',
        (WidgetTester tester) async {
      const padding = EdgeInsets.symmetric(horizontal: 4, vertical: 6);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClubListTile(
              contentPadding: padding,
              title: Text('间距'),
            ),
          ),
        ),
      );

      final containerFinder = find.byWidgetPredicate((Widget widget) {
        return widget is Container && widget.padding == padding;
      });

      expect(containerFinder, findsOneWidget);
    });
  });
}
