import 'package:get/get.dart';
import 'package:ios_club_app/features/education/models/bus_model.dart';
import 'package:ios_club_app/features/education/services/bus_service.dart';
import 'package:ios_club_app/core/services/new_bus_api.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

typedef BusPreferenceReader = Future<bool> Function();
typedef BusPreferenceWriter = Future<void> Function(bool value);
typedef BusFetcher = Future<BusModel> Function();

class BusTileStore extends GetxController {
  static BusPreferenceReader _preferenceReader = () async {
    final prefs = PrefsService.instance;
    return prefs.getBool(PrefsKeys.USE_NEW_BUS_API) ?? false;
  };
  static BusPreferenceWriter _preferenceWriter = (bool value) async {
    final prefs = PrefsService.instance;
    await prefs.setBool(PrefsKeys.USE_NEW_BUS_API, value);
  };
  static BusFetcher _newBusFetcher = () => getBusFromNewData(loc: 'ALL');
  static BusFetcher _oldBusFetcher = BusService.getBus;

  final RxBool isLoading = true.obs;
  final RxInt busCount = 0.obs;
  //final Rx<BusModel> busData = BusModel(records: [], total: 0).obs;
  final RxBool useNewApi = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBusData();
  }

  Future<void> loadPreferences() async {
    useNewApi.value = await _preferenceReader();
  }

  Future<void> loadBusData() async {
    try {
      isLoading.value = true;

      // 加载API偏好设置
      await loadPreferences();

      BusModel data;
      if (useNewApi.value) {
        // 使用新API
        data = await _newBusFetcher();
      } else {
        // 使用旧API
        data = await _oldBusFetcher();
      }

      //busData.value = data;
      busCount.value = data.records.length;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshBusData() async {
    await loadBusData();
  }

  Future<void> toggleUseNewApi(bool value) async {
    useNewApi.value = value;
    await _preferenceWriter(useNewApi.value);
    await loadBusData(); // 切换后重新加载数据
  }

  static void setTestOverrides({
    BusPreferenceReader? preferenceReader,
    BusPreferenceWriter? preferenceWriter,
    BusFetcher? newBusFetcher,
    BusFetcher? oldBusFetcher,
  }) {
    if (preferenceReader != null) _preferenceReader = preferenceReader;
    if (preferenceWriter != null) _preferenceWriter = preferenceWriter;
    if (newBusFetcher != null) _newBusFetcher = newBusFetcher;
    if (oldBusFetcher != null) _oldBusFetcher = oldBusFetcher;
  }

  static void resetTestOverrides() {
    _preferenceReader = () async {
      final prefs = PrefsService.instance;
      return prefs.getBool(PrefsKeys.USE_NEW_BUS_API) ?? false;
    };
    _preferenceWriter = (bool value) async {
      final prefs = PrefsService.instance;
      await prefs.setBool(PrefsKeys.USE_NEW_BUS_API, value);
    };
    _newBusFetcher = () => getBusFromNewData(loc: 'ALL');
    _oldBusFetcher = BusService.getBus;
  }
}
