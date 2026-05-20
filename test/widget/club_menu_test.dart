import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/ui/components/club_menu.dart';

import 'theme_test_helpers.dart';

void main() {
  group('ClubMenu', () {
    testWidgets('should show menu items and call onSelected',
        (WidgetTester tester) async {
      String? selectedValue;

      await tester.pumpWidget(
        themedTestApp(
          child: ClubMenu<String>(
            items: const <ClubMenuItem<String>>[
              ClubMenuItem<String>(
                value: 'edit',
                label: '编辑',
                icon: CupertinoIcons.pencil,
              ),
              ClubMenuItem<String>(
                value: 'delete',
                label: '删除',
                icon: CupertinoIcons.delete,
                isDestructive: true,
              ),
            ],
            onSelected: (String value) {
              selectedValue = value;
            },
          ),
        ),
      );

      await tester.tap(find.byIcon(CupertinoIcons.ellipsis_circle));
      await tester.pumpAndSettle();

      expect(find.text('编辑'), findsOneWidget);
      expect(find.text('删除'), findsOneWidget);

      await tester.tap(find.text('删除'));
      await tester.pumpAndSettle();

      expect(selectedValue, 'delete');
    });

    testWidgets('should render destructive item with danger color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        themedTestApp(
          child: ClubMenu<String>(
            items: const <ClubMenuItem<String>>[
              ClubMenuItem<String>(
                value: 'delete',
                label: '删除',
                icon: CupertinoIcons.delete,
                isDestructive: true,
              ),
            ],
            onSelected: (_) {},
          ),
        ),
      );

      await tester.tap(find.byIcon(CupertinoIcons.ellipsis_circle));
      await tester.pumpAndSettle();

      final Icon icon = tester.widget<Icon>(find.byIcon(CupertinoIcons.delete));
      final Text label = tester.widget<Text>(find.text('删除'));

      expect(icon.color, isNotNull);
      expect(label.style?.color, icon.color);
    });
  });
}
