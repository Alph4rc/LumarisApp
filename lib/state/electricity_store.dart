import 'package:get/get.dart';
import 'package:ios_club_app/features/system/tile_service.dart';
import 'package:ios_club_app/features/system/tile_edit_controller.dart';
import 'package:ios_club_app/core/models/electric_data.dart';

typedef ElectricityReader = Future<double?> Function();
typedef ElectricityWeeklyReader = Future<List<ElectricData>> Function();
typedef ElectricityTileVisibilityReader = Future<bool> Function(String tileId);
typedef ElectricityTileMutator = Future<void> Function(String tileId);

class ElectricityStore extends GetxController {
  static ElectricityReader _electricityReader = TileService.getTextAfterKeyword;
  static ElectricityWeeklyReader _weeklyReader =
      TileService.getElectricityWeeklyData;
  static ElectricityTileVisibilityReader _tileVisibilityReader =
      TileService.isTileVisible;
  static ElectricityTileMutator _tileAdder = TileService.addTile;
  static ElectricityTileMutator _tileRemover = TileService.removeTile;

  // 响应式状态变量
  final RxBool isLoading = true.obs;
  final RxBool hasData = false.obs;
  final RxDouble electricity = 0.0.obs;
  final RxList<String> tiles = <String>[].obs;
  final RxList<ElectricData> weeklyData = <ElectricData>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadElectricityData();
  }

  Future<void> loadElectricityData() async {
    try {
      isLoading.value = true;

      final value = await _electricityReader();
      final isVisible = await _tileVisibilityReader('电费');
      final weekly = await _weeklyReader();

      if (value != null) {
        electricity.value = value;
        hasData.value = true;
      }

      if (isVisible) {
        if (!tiles.contains('电费')) tiles.add('电费');
      } else {
        tiles.remove('电费');
      }
      weeklyData.assignAll(weekly);
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshElectricityData() async {
    try {
      isLoading.value = true;

      final value = await _electricityReader();
      final weekly = await _weeklyReader();

      if (value != null) {
        electricity.value = value;
        hasData.value = true;
      }

      weeklyData.assignAll(weekly);
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleTile(String tileName, bool value) async {
    if (value) {
      if (!tiles.contains(tileName)) {
        tiles.add(tileName);
      }
      await _tileAdder(tileName);
    } else {
      tiles.remove(tileName);
      await _tileRemover(tileName);
    }

    if (Get.isRegistered<TileEditController>()) {
      await Get.find<TileEditController>().reload();
    }
  }

  static void setTestOverrides({
    ElectricityReader? electricityReader,
    ElectricityWeeklyReader? weeklyReader,
    ElectricityTileVisibilityReader? tileVisibilityReader,
    ElectricityTileMutator? tileAdder,
    ElectricityTileMutator? tileRemover,
  }) {
    if (electricityReader != null) _electricityReader = electricityReader;
    if (weeklyReader != null) _weeklyReader = weeklyReader;
    if (tileVisibilityReader != null) {
      _tileVisibilityReader = tileVisibilityReader;
    }
    if (tileAdder != null) _tileAdder = tileAdder;
    if (tileRemover != null) _tileRemover = tileRemover;
  }

  static void resetTestOverrides() {
    _electricityReader = TileService.getTextAfterKeyword;
    _weeklyReader = TileService.getElectricityWeeklyData;
    _tileVisibilityReader = TileService.isTileVisible;
    _tileAdder = TileService.addTile;
    _tileRemover = TileService.removeTile;
  }
}
