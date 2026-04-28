import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/state/electricity_store.dart';
import 'package:ios_club_app/state/payment_store.dart';
import 'package:ios_club_app/ui/components/tiles/electricity_tile.dart';
import 'package:ios_club_app/ui/components/tiles/payment_tile.dart';

class _TestElectricityStore extends ElectricityStore {
  @override
  void onInit() {}
}

class _TestPaymentStore extends PaymentStore {
  @override
  void onInit() {}
}

Widget _wrap(Widget child) {
  return GetMaterialApp(
    home: Scaffold(
      body: SizedBox(width: 300, height: 200, child: child),
    ),
    getPages: <GetPage<dynamic>>[
      GetPage<dynamic>(name: '/Electricity', page: () => const SizedBox()),
      GetPage<dynamic>(name: '/Payment', page: () => const SizedBox()),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  group('ElectricityTile', () {
    testWidgets('shows loading indicator when store is loading',
        (tester) async {
      final store = Get.put<ElectricityStore>(_TestElectricityStore());
      store.isLoading.value = true;
      store.hasData.value = false;

      await tester.pumpWidget(_wrap(const ElectricityTile()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows low balance style when amount is small', (tester) async {
      final store = Get.put<ElectricityStore>(_TestElectricityStore());
      store.isLoading.value = false;
      store.hasData.value = true;
      store.electricity.value = 8.0;

      await tester.pumpWidget(_wrap(const ElectricityTile()));
      expect(find.text('当前电费'), findsOneWidget);
      expect(find.text('¥8.00'), findsOneWidget);
      expect(find.text('余额不足'), findsOneWidget);
    });

    testWidgets('shows normal state when amount is sufficient', (tester) async {
      final store = Get.put<ElectricityStore>(_TestElectricityStore());
      store.isLoading.value = false;
      store.hasData.value = true;
      store.electricity.value = 18.5;

      await tester.pumpWidget(_wrap(const ElectricityTile()));
      expect(find.text('¥18.50'), findsOneWidget);
      expect(find.text('余额不足'), findsNothing);
    });

    testWidgets('shows subscribe hint when no data exists', (tester) async {
      final store = Get.put<ElectricityStore>(_TestElectricityStore());
      store.isLoading.value = false;
      store.hasData.value = false;

      await tester.pumpWidget(_wrap(const ElectricityTile()));
      expect(find.text('电费查询'), findsOneWidget);
      expect(find.text('点击订阅'), findsOneWidget);
    });
  });

  group('PaymentTile', () {
    testWidgets('shows loading indicator when store is loading',
        (tester) async {
      final store = Get.put<PaymentStore>(_TestPaymentStore());
      store.isLoading.value = true;

      await tester.pumpWidget(_wrap(const PaymentTile()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows low balance state when recharge value is low',
        (tester) async {
      final store = Get.put<PaymentStore>(_TestPaymentStore());
      store.isLoading.value = false;
      store.totalRecharge.value = 9.2;

      await tester.pumpWidget(_wrap(const PaymentTile()));
      expect(find.text('当前余额'), findsOneWidget);
      expect(find.text('¥9.20'), findsOneWidget);
      expect(find.text('余额不足'), findsOneWidget);
    });

    testWidgets('shows normal balance state when value is sufficient',
        (tester) async {
      final store = Get.put<PaymentStore>(_TestPaymentStore());
      store.isLoading.value = false;
      store.totalRecharge.value = 30.0;

      await tester.pumpWidget(_wrap(const PaymentTile()));
      expect(find.text('¥30.00'), findsOneWidget);
      expect(find.text('余额不足'), findsNothing);
    });

    testWidgets('shows bind hint when no value and no error', (tester) async {
      final store = Get.put<PaymentStore>(_TestPaymentStore());
      store.isLoading.value = false;
      store.totalRecharge.value = 0;
      store.errorMessage.value = '';

      await tester.pumpWidget(_wrap(const PaymentTile()));
      expect(find.text('饭卡余额'), findsOneWidget);
      expect(find.text('点击查看'), findsOneWidget);
    });

    testWidgets('shows error message when no value but has error',
        (tester) async {
      final store = Get.put<PaymentStore>(_TestPaymentStore());
      store.isLoading.value = false;
      store.totalRecharge.value = 0;
      store.errorMessage.value = '请先登录教务处账号';

      await tester.pumpWidget(_wrap(const PaymentTile()));
      expect(find.text('请先登录教务处账号'), findsOneWidget);
      expect(find.text('点击绑定'), findsNothing);
    });
  });
}
