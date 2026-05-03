import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ios_club_app/features/education/models/bus_model.dart';
import 'package:ios_club_app/features/education/services/bus_service.dart';
import 'package:ios_club_app/features/system/tile_service.dart';
import 'package:ios_club_app/state/app_states.dart';

typedef BusPageFetcher = Future<BusModel> Function({
  String? dayDate,
  bool forceRefresh,
});

final busPageAutoLoadProvider = Provider<bool>((ref) => true);
final busPageFetcherProvider = Provider<BusPageFetcher>((ref) {
  return ({String? dayDate, bool forceRefresh = false}) {
    return BusService.getBus(
      dayDate: dayDate,
      forceRefresh: forceRefresh,
    );
  };
});

final busControllerProvider =
    NotifierProvider<BusPageNotifier, BusPageState>(BusPageNotifier.new);

class BusPageNotifier extends Notifier<BusPageState> {
  final Map<String, String> availableDates = {};

  @override
  BusPageState build() {
    _generateWeeklyDates();
    final selectedDate =
        availableDates.isNotEmpty ? availableDates.keys.first : '';
    if (ref.read(busPageAutoLoadProvider)) {
      Future<void>.microtask(() async {
        state = state.copyWith(selectedDate: selectedDate);
        if (selectedDate.isNotEmpty) {
          await _fetchBusData(isInit: true);
        }
        await _loadTiles();
      });
    }
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
    final config = await TileService.getTileConfigurations();
    final tiles = config.getVisibleTiles().map((tile) => tile.id).toList();
    state = state.copyWith(
      tiles: tiles,
      isShowBus: tiles.contains('校车'),
    );
  }

  Future<void> _fetchBusData({
    bool isInit = false,
    bool forceRefresh = false,
  }) async {
    final currentSelectedDate = state.selectedDate;
    final previousTodayBusData = state.todayBusData;
    final previousBusData = state.busData;
    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      final BusModel data = await ref.read(busPageFetcherProvider)(
        dayDate: state.selectedDate,
        forceRefresh: forceRefresh,
      );

      // 检查在异步请求期间用户是否切换了日期
      if (state.selectedDate != currentSelectedDate) {
        return;
      }

      final todayBusData = data.records;
      final busData = state.isCaoTang
          ? todayBusData.where((bus) => bus.lineName.startsWith('草堂')).toList()
          : todayBusData.where((bus) => bus.lineName.startsWith('雁塔')).toList();

      state = state.copyWith(todayBusData: todayBusData, busData: busData);
    } catch (e) {
      if (state.selectedDate != currentSelectedDate) {
        return;
      }
      state = state.copyWith(
        errorMessage: '刷新失败，已保留上次校车数据',
        todayBusData: previousTodayBusData,
        busData: previousBusData,
      );
    } finally {
      if (state.selectedDate == currentSelectedDate) {
        state = state.copyWith(isLoading: false);
      }
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
    await _fetchBusData(forceRefresh: true);
  }

  Future<void> toggleShowBus(bool value) async {
    if (value) {
      await TileService.addTile('校车');
    } else {
      await TileService.removeTile('校车');
    }
    await _loadTiles();
  }
}
