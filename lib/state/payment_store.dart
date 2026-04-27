import 'package:get/get.dart';
import 'package:ios_club_app/features/education/models/payment_model.dart';
import 'package:ios_club_app/features/system/tile_service.dart';
import 'package:ios_club_app/features/system/tile_edit_controller.dart';
import 'package:ios_club_app/core/services/payment_analyzer.dart';

typedef PaymentNumberReader = Future<String> Function();
typedef PaymentDataFetcher = Future<PaymentData> Function(String cardNumber);
typedef PaymentNumberWriter = Future<void> Function(String cardNumber);
typedef TileVisibilityReader = Future<bool> Function(String tileId);
typedef TileMutator = Future<void> Function(String tileId);

class PaymentStore extends GetxController {
  static PaymentNumberReader _paymentReader = PaymentAnalyzer.getPayment;
  static PaymentDataFetcher _paymentDataFetcher = PaymentAnalyzer.fetchData;
  static PaymentNumberWriter _paymentWriter = PaymentAnalyzer.setPayment;
  static TileVisibilityReader _tileVisibilityReader = TileService.isTileVisible;
  static TileMutator _tileAdder = TileService.addTile;
  static TileMutator _tileRemover = TileService.removeTile;

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

      num.value = await _paymentReader();

      if (num.value.isEmpty) {
        errorMessage.value = '请先绑定饭卡';
        return;
      }

      final recordsResult = await _paymentDataFetcher(num.value);
      final isVisible = await _tileVisibilityReader('饭卡');

      records.assignAll(recordsResult.payments);
      totalRecharge.value = recordsResult.total;
      isShowTile.value = isVisible;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setPayment(String cardNumber) async {
    await _paymentWriter(cardNumber);
    await loadData();
  }

  Future<void> toggleTileShow(bool value) async {
    isShowTile.value = value;
    if (value) {
      await _tileAdder("饭卡");
    } else {
      await _tileRemover("饭卡");
    }

    if (Get.isRegistered<TileEditController>()) {
      await Get.find<TileEditController>().reload();
    }
  }

  static void setTestOverrides({
    PaymentNumberReader? paymentReader,
    PaymentDataFetcher? paymentDataFetcher,
    PaymentNumberWriter? paymentWriter,
    TileVisibilityReader? tileVisibilityReader,
    TileMutator? tileAdder,
    TileMutator? tileRemover,
  }) {
    if (paymentReader != null) _paymentReader = paymentReader;
    if (paymentDataFetcher != null) _paymentDataFetcher = paymentDataFetcher;
    if (paymentWriter != null) _paymentWriter = paymentWriter;
    if (tileVisibilityReader != null) {
      _tileVisibilityReader = tileVisibilityReader;
    }
    if (tileAdder != null) _tileAdder = tileAdder;
    if (tileRemover != null) _tileRemover = tileRemover;
  }

  static void resetTestOverrides() {
    _paymentReader = PaymentAnalyzer.getPayment;
    _paymentDataFetcher = PaymentAnalyzer.fetchData;
    _paymentWriter = PaymentAnalyzer.setPayment;
    _tileVisibilityReader = TileService.isTileVisible;
    _tileAdder = TileService.addTile;
    _tileRemover = TileService.removeTile;
  }
}
