import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

import 'theme_test_helpers.dart';

const _contentKey = ValueKey('club_snack_bar_content');

void main() {
  group('showClubSnackBar', () {
    testWidgets('should show SnackBar with provided child widget',
        (WidgetTester tester) async {
      const testText = '测试消息';
      var snackBarShown = false;

      await tester.pumpWidget(
        themedTestApp(
          child: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  showClubSnackBar(
                    context,
                    const Text(testText),
                  );
                  snackBarShown = true;
                },
                child: const Text('显示 SnackBar'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('显示 SnackBar'));
      await tester.pump();

      expect(snackBarShown, true);
      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('should show SnackBar with correct styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        themedTestApp(
          child: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  showClubSnackBar(
                    context,
                    const Text('测试'),
                  );
                },
                child: const Text('显示 SnackBar'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('显示 SnackBar'));
      await tester.pumpAndSettle();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      final content = tester.widget<Container>(find.byKey(_contentKey));
      final decoration = content.decoration! as BoxDecoration;

      expect(snackBar.behavior, SnackBarBehavior.floating);
      expect(snackBar.duration, const Duration(seconds: 2));
      // 毛玻璃效果：SnackBar 本体透明，背景由内部磨砂容器提供。
      expect(snackBar.backgroundColor, Colors.transparent);
      expect(snackBar.elevation, 0);
      expect(
        decoration.color,
        ClubColors.light.cardBackground.withValues(alpha: 0.8),
      );
    });

    testWidgets('should use dark theme colors when theme mode is dark',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        themedTestApp(
          themeMode: ThemeMode.dark,
          child: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  showClubSnackBar(
                    context,
                    const Text('深色测试'),
                  );
                },
                child: const Text('显示 SnackBar'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('显示 SnackBar'));
      await tester.pumpAndSettle();

      final content = tester.widget<Container>(find.byKey(_contentKey));
      final decoration = content.decoration! as BoxDecoration;
      expect(
        decoration.color,
        ClubColors.dark.cardBackground.withValues(alpha: 0.8),
      );
    });
  });
}
