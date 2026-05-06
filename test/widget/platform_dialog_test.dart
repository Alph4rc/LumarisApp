import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/ui/components/platform_dialog.dart';

Widget _testApp({
  required Widget child,
}) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

void main() {
  group('PlatformDialog', () {
    testWidgets('should keep dialog open when autoPop is false',
        (WidgetTester tester) async {
      var pressed = false;

      await tester.pumpWidget(
        _testApp(
          child: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  PlatformDialog.showCustomDialog<void>(
                    context,
                    title: '测试弹窗',
                    content: const Text('内容'),
                    actions: [
                      PlatformDialogAction<void>(
                        label: '保存',
                        autoPop: false,
                        onPressed: () {
                          pressed = true;
                        },
                      ),
                    ],
                  );
                },
                child: const Text('打开'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();

      expect(find.text('测试弹窗'), findsOneWidget);

      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
      expect(find.text('测试弹窗'), findsOneWidget);
    });

    testWidgets('should respect barrierDismissible setting',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _testApp(
          child: Builder(
            builder: (context) {
              return Column(
                children: [
                  TextButton(
                    onPressed: () {
                      PlatformDialog.showCustomDialog<void>(
                        context,
                        title: '可关闭弹窗',
                        barrierDismissible: true,
                      );
                    },
                    child: const Text('打开可关闭'),
                  ),
                  TextButton(
                    onPressed: () {
                      PlatformDialog.showCustomDialog<void>(
                        context,
                        title: '不可关闭弹窗',
                        barrierDismissible: false,
                      );
                    },
                    child: const Text('打开不可关闭'),
                  ),
                ],
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('打开可关闭'));
      await tester.pumpAndSettle();
      expect(find.text('可关闭弹窗'), findsOneWidget);

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('可关闭弹窗'), findsNothing);

      await tester.tap(find.text('打开不可关闭'));
      await tester.pumpAndSettle();
      expect(find.text('不可关闭弹窗'), findsOneWidget);

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('不可关闭弹窗'), findsOneWidget);
    });

    testWidgets('should return expected result from confirm dialog',
        (WidgetTester tester) async {
      bool? result;

      await tester.pumpWidget(
        _testApp(
          child: Builder(
            builder: (context) {
              return Column(
                children: [
                  TextButton(
                    onPressed: () async {
                      result = await PlatformDialog.showConfirmDialog(
                        context,
                        title: '确认弹窗',
                        content: '是否继续？',
                      );
                    },
                    child: const Text('打开确认框'),
                  ),
                ],
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('打开确认框'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('确认'));
      await tester.pumpAndSettle();
      expect(result, isTrue);

      await tester.tap(find.text('打开确认框'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });
  });
}
