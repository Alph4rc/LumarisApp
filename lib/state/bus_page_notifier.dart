import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ios_club_app/core/services/new_bus_api.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/models/bus_model.dart';
import 'package:ios_club_app/features/education/services/bus_service.dart';
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

final busControllerProvider =
    NotifierProvider<BusPageNotifier, BusPageState>(BusPageNotifier.new);

class BusPageNotifier extends Notifier<BusPageState> {
  final Map<String, String> availableDates = {};

  @override
  BusPageState build() {
    _generateWeeklyDates();
    final selectedDate =
        availableDates.isNotEmpty ? availableDates.keys.first : '';
    Future<void>.microtask(() async {
      state = state.copyWith(selectedDate: selectedDate);
      if (selectedDate.isNotEmpty) {
        await _fetchBusData(isInit: true);
      }
      await _loadTiles();
    });
    return BusPageState(selectedDate: selectedDate);
  }

  void _generateWeeklyDates() {
    availableDates.clear();
    final now = DateTime.now();
    for (var i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      availableDates[DateFormat('yyyy-MM-dd').format(date)] =
          DateFormat('M月d日').format(date);
    }
  }

  Future<void> selectDateByIndex(int index) async {
    if (index < 0 || index >= availableDates.length) {
      return;
    }
    state = state.copyWith(selectedDate: availableDates.keys.elementAt(index));
    await _fetchBusData();
  }

  Future<void> _loadTiles() async {
    final tiles = PrefsService.instance.getStringList(PrefsKeys.TILES) ?? [];
    state = state.copyWith(
      tiles: tiles,
      isShowBus: tiles.contains('校车'),
    );
  }

  Future<void> _fetchBusData({bool isInit = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      var useNewApi = state.useNewApi;
      if (isInit) {
        useNewApi =
            PrefsService.instance.getBool(PrefsKeys.USE_NEW_BUS_API) ?? false;
        state = state.copyWith(useNewApi: useNewApi);
      }

      final BusModel data;
      if (useNewApi) {
        data = await getBusFromNewData(time: state.selectedDate, loc: 'ALL');
      } else {
        data = await BusService.getBus(dayDate: state.selectedDate);
      }

      final todayBusData = data.records;
      final busData = state.isCaoTang
          ? todayBusData.where((bus) => bus.lineName.startsWith('草堂')).toList()
          : todayBusData.where((bus) => bus.lineName.startsWith('雁塔')).toList();

      state = state.copyWith(todayBusData: todayBusData, busData: busData);
    } catch (e) {
      state = state.copyWith(errorMessage: '获取校车数据时出错: $e', busData: const []);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void toggleCampus() {
    final isCaoTang = !state.isCaoTang;
    final busData = isCaoTang
        ? state.todayBusData
            .where((bus) => bus.lineName.startsWith('草堂'))
            .toList()
        : state.todayBusData
            .where((bus) => bus.lineName.startsWith('雁塔'))
            .toList();
    state = state.copyWith(isCaoTang: isCaoTang, busData: busData);
  }

  Future<void> refreshData() async {
    await _fetchBusData();
  }

  Future<void> toggleShowBus(bool value) async {
    final tiles = [...state.tiles];
    if (value) {
      if (!tiles.contains('校车')) {
        tiles.add('校车');
      }
    } else {
      tiles.remove('校车');
    }

    state = state.copyWith(isShowBus: value, tiles: tiles);
    await PrefsService.instance.setStringList(PrefsKeys.TILES, tiles);
  }

  Future<void> toggleUseNewApi(bool value) async {
    state = state.copyWith(useNewApi: value);
    await PrefsService.instance.setBool(PrefsKeys.USE_NEW_BUS_API, value);
    await _fetchBusData();
  }
}
