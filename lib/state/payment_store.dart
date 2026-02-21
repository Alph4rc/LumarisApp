import 'package:get/get.dart';
import 'package:ios_club_app/features/system/tile_service.dart';
import 'package:ios_club_app/features/system/tile_edit_controller.dart';
import 'package:ios_club_app/core/services/payment_analyzer.dart';

class PaymentStore extends GetxController {
  // 响应式状态变量
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxList<PaymentModel> records = <PaymentModel>[].obs;
  final RxDouble totalRecharge = 0.0.obs;
  final RxString num = ''.obs;
  final RxBool isShowTile = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      num.value = await PaymentAnalyzer.getPayment();

      if (num.value.isEmpty) {
        errorMessage.value = '请先绑定饭卡';
        return;
      }

      final recordsResult = await PaymentAnalyzer.fetchData(num.value);
      final isVisible = await TileService.isTileVisible('饭卡');

      records.assignAll(recordsResult.payments);
      totalRecharge.value = recordsResult.total;
      isShowTile.value = isVisible;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setPayment(String cardNumber) async {
    await PaymentAnalyzer.setPayment(cardNumber);
    await loadData();
  }

  Future<void> toggleTileShow(bool value) async {
    isShowTile.value = value;
    if (value) {
      await TileService.addTile("饭卡");
    } else {
      await TileService.removeTile("饭卡");
    }

    if (Get.isRegistered<TileEditController>()) {
      await Get.find<TileEditController>().reload();
    }
  }
}
