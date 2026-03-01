import 'package:get/get.dart';
import 'package:ios_club_app/features/system/tile_service.dart';
import 'package:ios_club_app/features/system/tile_edit_controller.dart';
import 'package:ios_club_app/core/models/electric_data.dart';

class ElectricityStore extends GetxController {
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

      final value = await TileService.getTextAfterKeyword();
      final isVisible = await TileService.isTileVisible('电费');
      final weekly = await TileService.getElectricityWeeklyData();

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

      final value = await TileService.getTextAfterKeyword();
      final weekly = await TileService.getElectricityWeeklyData();

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
      await TileService.addTile(tileName);
    } else {
      tiles.remove(tileName);
      await TileService.removeTile(tileName);
    }

    if (Get.isRegistered<TileEditController>()) {
      await Get.find<TileEditController>().reload();
    }
  }
}
