import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

import 'theme_test_helpers.dart';

void main() {
  group('ClubCard', () {
    testWidgets('should display child widget', (WidgetTester tester) async {
      const childText = '测试内容';

      await tester.pumpWidget(
        themedTestApp(
          child: const ClubCard(
            child: Text(childText),
          ),
        ),
      );

      expect(find.text(childText), findsOneWidget);
    });

    testWidgets('should apply custom margin', (WidgetTester tester) async {
      const margin = EdgeInsets.all(16.0);

      await tester.pumpWidget(
        themedTestApp(
          child: const ClubCard(
            margin: margin,
            child: Text('测试'),
          ),
        ),
      );

      final containerFinder = find.byWidgetPredicate((Widget widget) {
        return widget is Container && widget.margin == margin;
      });

      expect(containerFinder, findsOneWidget);
    });

    testWidgets('should apply custom padding', (WidgetTester tester) async {
      const padding = EdgeInsets.symmetric(horizontal: 20, vertical: 10);

      await tester.pumpWidget(
        themedTestApp(
          child: const ClubCard(
            padding: padding,
            child: Text('测试'),
          ),
        ),
      );

      final containerFinder = find.byWidgetPredicate((Widget widget) {
        return widget is Container && widget.padding == padding;
      });

      expect(containerFinder, findsOneWidget);
    });

    testWidgets('should use default card radius', (WidgetTester tester) async {
      await tester.pumpWidget(
        themedTestApp(
          child: const ClubCard(
            child: Text('测试'),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.borderRadius, ClubRadii.card);
    });

    testWidgets('should apply custom border radius',
        (WidgetTester tester) async {
      const borderRadius = ClubRadii.navigation;

      await tester.pumpWidget(
        themedTestApp(
          child: const ClubCard(
            borderRadius: borderRadius,
            child: Text('测试'),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.borderRadius, borderRadius);
    });

    testWidgets('should use light and dark card colors',
        (WidgetTester tester) async {
      Finder decoratedContainer() {
        return find.descendant(
          of: find.byType(ClubCard),
          matching: find.byWidgetPredicate((Widget widget) {
            return widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).borderRadius ==
                    ClubRadii.card;
          }),
        );
      }

      await tester.pumpWidget(
        themedTestApp(
          themeMode: ThemeMode.light,
          child: const ClubCard(child: Text('浅色')),
        ),
      );

      var container = tester.widget<Container>(decoratedContainer());
      var decoration = container.decoration as BoxDecoration;
      expect(decoration.color, ClubColors.light.cardBackground);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Theme(
              data: ClubTheme.darkTheme(),
              child: const Material(
                child: ClubCard(child: Text('深色')),
              ),
            ),
          ),
        ),
      );

      container = tester.widget<Container>(decoratedContainer());
      decoration = container.decoration as BoxDecoration;
      expect(decoration.color, ClubColors.dark.cardBackground);
    });
  });
}
