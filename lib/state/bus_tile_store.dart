import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/services/new_bus_api.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/models/bus_model.dart';
import 'package:ios_club_app/features/education/services/bus_service.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/tile_store_providers.dart';

typedef BusPreferenceReader = Future<bool> Function();
typedef BusPreferenceWriter = Future<void> Function(bool value);
typedef BusFetcher = Future<BusModel> Function();

final busPreferenceReaderProvider = Provider<BusPreferenceReader>((ref) {
  return () async {
    return PrefsService.instance.getBool(PrefsKeys.USE_NEW_BUS_API) ?? false;
  };
});

final busPreferenceWriterProvider = Provider<BusPreferenceWriter>((ref) {
  return (bool value) async {
    await PrefsService.instance.setBool(PrefsKeys.USE_NEW_BUS_API, value);
  };
});

final newBusFetcherProvider = Provider<BusFetcher>((ref) {
  return () => getBusFromNewData(loc: 'ALL');
});

final oldBusFetcherProvider = Provider<BusFetcher>((ref) {
  return BusService.getBus;
});

final busTileStoreProvider =
    NotifierProvider<BusTileStore, BusTileState>(BusTileStore.new);

class BusTileStore extends Notifier<BusTileState> {
  @override
  BusTileState build() {
    if (ref.read(tileStoreAutoLoadProvider)) {
      Future<void>.microtask(loadBusData);
    }
    return const BusTileState();
  }

  bool get isLoading => state.isLoading;
  int get busCount => state.busCount;
  bool get useNewApi => state.useNewApi;

  Future<void> loadPreferences() async {
    state = state.copyWith(
      useNewApi: await ref.read(busPreferenceReaderProvider)(),
    );
  }

  Future<void> loadBusData() async {
    try {
      state = state.copyWith(isLoading: true);
      await loadPreferences();

      final data = state.useNewApi
          ? await ref.read(newBusFetcherProvider)()
          : await ref.read(oldBusFetcherProvider)();

      state = state.copyWith(busCount: data.records.length);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshBusData() async {
    await loadBusData();
  }

  Future<void> toggleUseNewApi(bool value) async {
    state = state.copyWith(useNewApi: value);
    await ref.read(busPreferenceWriterProvider)(value);
    await loadBusData();
  }
}
