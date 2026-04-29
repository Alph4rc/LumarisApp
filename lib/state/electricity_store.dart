import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/models/electric_data.dart';
import 'package:ios_club_app/state/tile_edit_notifier.dart';
import 'package:ios_club_app/features/system/tile_service.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/tile_store_providers.dart';

typedef ElectricityReader = Future<double?> Function();
typedef ElectricityWeeklyReader = Future<List<ElectricData>> Function();
typedef ElectricityTileVisibilityReader = Future<bool> Function(String tileId);
typedef ElectricityTileMutator = Future<void> Function(String tileId);

final electricityReaderProvider = Provider<ElectricityReader>((ref) {
  return TileService.getTextAfterKeyword;
});

final electricityWeeklyReaderProvider =
    Provider<ElectricityWeeklyReader>((ref) {
  return TileService.getElectricityWeeklyData;
});

final electricityTileVisibilityReaderProvider =
    Provider<ElectricityTileVisibilityReader>((ref) {
  return TileService.isTileVisible;
});

final electricityTileAdderProvider = Provider<ElectricityTileMutator>((ref) {
  return TileService.addTile;
});

final electricityTileRemoverProvider = Provider<ElectricityTileMutator>((ref) {
  return TileService.removeTile;
});

final electricityStoreProvider =
    NotifierProvider<ElectricityStore, ElectricityState>(ElectricityStore.new);

class ElectricityStore extends Notifier<ElectricityState> {
  @override
  ElectricityState build() {
    if (ref.read(tileStoreAutoLoadProvider)) {
      Future<void>.microtask(loadElectricityData);
    }
    return const ElectricityState();
  }

  bool get isLoading => state.isLoading;
  bool get hasData => state.hasData;
  double get electricity => state.electricity;
  List<String> get tiles => List.unmodifiable(state.tiles);
  List<ElectricData> get weeklyData => List.unmodifiable(state.weeklyData);

  Future<void> loadElectricityData() async {
    try {
      state = state.copyWith(isLoading: true);

      final value = await ref.read(electricityReaderProvider)();
      final isVisible =
          await ref.read(electricityTileVisibilityReaderProvider)('电费');
      final weekly = await ref.read(electricityWeeklyReaderProvider)();

      final nextTiles = [...state.tiles];
      if (isVisible) {
        if (!nextTiles.contains('电费')) {
          nextTiles.add('电费');
        }
      } else {
        nextTiles.remove('电费');
      }

      state = state.copyWith(
        electricity: value ?? state.electricity,
        hasData: value != null ? true : state.hasData,
        tiles: nextTiles,
        weeklyData: weekly,
      );
    } catch (_) {
      // Keep the last known values on transient failures.
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshElectricityData() async {
    try {
      state = state.copyWith(isLoading: true);

      final value = await ref.read(electricityReaderProvider)();
      final weekly = await ref.read(electricityWeeklyReaderProvider)();

      state = state.copyWith(
        electricity: value ?? state.electricity,
        hasData: value != null ? true : state.hasData,
        weeklyData: weekly,
      );
    } catch (_) {
      // Keep the last known values on transient failures.
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> toggleTile(String tileName, bool value) async {
    final nextTiles = [...state.tiles];
    if (value) {
      if (!nextTiles.contains(tileName)) {
        nextTiles.add(tileName);
      }
      await ref.read(electricityTileAdderProvider)(tileName);
    } else {
      nextTiles.remove(tileName);
      await ref.read(electricityTileRemoverProvider)(tileName);
    }

    state = state.copyWith(tiles: nextTiles);
    await ref.read(tileEditControllerProvider.notifier).reload();
  }

  Future<void> setElectricityValue(double value) async {
    state = state.copyWith(electricity: value, hasData: true);
  }
}
