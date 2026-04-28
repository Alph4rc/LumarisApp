import 'package:get/get.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/services/secure_storage_service.dart';
import 'package:ios_club_app/features/education/models/payment_model.dart';
import 'package:ios_club_app/features/system/tile_service.dart';
import 'package:ios_club_app/features/system/tile_edit_controller.dart';
import 'package:ios_club_app/core/services/payment_analyzer.dart';
import 'package:ios_club_app/state/prefs_keys.dart' show PrefsKeys;
import 'package:ios_club_app/state/user_store.dart';

typedef PaymentDataFetcher = Future<PaymentData> Function(String cardNumber);
typedef StudentIsLoginReader = bool Function();
typedef TileVisibilityReader = Future<bool> Function(String tileId);
typedef TileMutator = Future<void> Function(String tileId);

class PaymentStore extends GetxController {
  static PaymentDataFetcher _paymentDataFetcher = PaymentAnalyzer.fetchData;
  static StudentIsLoginReader _studentIsLoginReader =
      () => UserStore.to.isLogin;
  static TileVisibilityReader _tileVisibilityReader = TileService.isTileVisible;
  static TileMutator _tileAdder = TileService.addTile;
  static TileMutator _tileRemover = TileService.removeTile;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxList<PaymentModel> records = <PaymentModel>[].obs;
  final RxDouble totalRecharge = 0.0.obs;
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

      final isLogin = _studentIsLoginReader();

      String? studentId = "";

      if (isLogin) {
        final secureStorage = SecureStorageService.instance;
        final prefs = PrefsService.instance;
        studentId = await secureStorage.read(key: PrefsKeys.USERNAME) ??
            prefs.getString(PrefsKeys.USERNAME);
      }

      if (studentId == null || studentId.isEmpty) {
        errorMessage.value = '请先登录教务处账号';
        return;
      }

      final recordsResult = await _paymentDataFetcher(studentId);
      final isVisible = await _tileVisibilityReader('饭卡');

      records.assignAll(recordsResult.payments);
      totalRecharge.value = recordsResult.total;
      isShowTile.value = isVisible;
    } finally {
      isLoading.value = false;
    }
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
    PaymentDataFetcher? paymentDataFetcher,
    StudentIsLoginReader? studentIdReader,
    TileVisibilityReader? tileVisibilityReader,
    TileMutator? tileAdder,
    TileMutator? tileRemover,
  }) {
    if (paymentDataFetcher != null) _paymentDataFetcher = paymentDataFetcher;
    if (studentIdReader != null) _studentIsLoginReader = studentIdReader;
    if (tileVisibilityReader != null) {
      _tileVisibilityReader = tileVisibilityReader;
    }
    if (tileAdder != null) _tileAdder = tileAdder;
    if (tileRemover != null) _tileRemover = tileRemover;
  }

  static void resetTestOverrides() {
    _paymentDataFetcher = PaymentAnalyzer.fetchData;
    _studentIsLoginReader = () => UserStore.to.isLogin;
    _tileVisibilityReader = TileService.isTileVisible;
    _tileAdder = TileService.addTile;
    _tileRemover = TileService.removeTile;
  }
}
