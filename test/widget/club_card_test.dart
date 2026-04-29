import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/club_radii.dart';

void main() {
  group('ClubCard', () {
    testWidgets('should display child widget', (WidgetTester tester) async {
      const childText = '测试内容';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClubCard(
              child: Text(childText),
            ),
          ),
        ),
      );

      expect(find.text(childText), findsOneWidget);
    });

    testWidgets('should apply custom margin', (WidgetTester tester) async {
      const margin = EdgeInsets.all(16.0);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClubCard(
              margin: margin,
              child: Text('测试'),
            ),
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
        const MaterialApp(
          home: Scaffold(
            body: ClubCard(
              padding: padding,
              child: Text('测试'),
            ),
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
        const MaterialApp(
          home: Scaffold(
            body: ClubCard(
              child: Text('测试'),
            ),
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
        const MaterialApp(
          home: Scaffold(
            body: ClubCard(
              borderRadius: borderRadius,
              child: Text('测试'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.borderRadius, borderRadius);
    });
  });
}
