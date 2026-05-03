import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/features/education/models/bus_model.dart'
    show BusItem;
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/components/club_modal_bottom_sheet.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/components/empty_widget.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/ui/components/modal_components.dart';
import 'package:ios_club_app/state/bus_page_notifier.dart';

class SchoolBusPage extends ConsumerStatefulWidget {
  const SchoolBusPage({super.key});

  @override
  ConsumerState<SchoolBusPage> createState() => _SchoolBusPageState();
}

class _SchoolBusPageState extends ConsumerState<SchoolBusPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        ref.read(busControllerProvider.notifier).selectDateByIndex(
              _tabController.index,
            );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busState = ref.watch(busControllerProvider);
    final busController = ref.read(busControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: CupertinoButton(
          onPressed: busController.toggleCampus,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(busState.isCaoTang ? '草堂校区' : '雁塔校区'),
              const Icon(Icons.arrow_forward),
              Text(busState.isCaoTang ? '雁塔校区' : '草堂校区'),
            ],
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: TabBar(
            controller: _tabController,
            tabAlignment: TabAlignment.start,
            tabs: busController.availableDates.values
                .map((date) => Tab(text: date))
                .toList(),
            isScrollable: true,
            dividerColor: Colors.transparent,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: busController.refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsModalBottomSheet(
              context,
              busState,
              busController,
            ),
          ),
        ],
      ),
      body: _buildBuses(busState),
    );
  }

  Widget _buildBuses(BusPageState busState) {
    if (busState.isLoading) {
      return const Center(
        child: LoadingStateView(
          title: '正在获取校车班次',
          subtitle: '正在按日期整理两校区往返班车信息',
          showCard: true,
        ),
      );
    } else if (busState.errorMessage.isNotEmpty) {
      return Center(
        child: ClubCard(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.only(top: 40),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              busState.errorMessage,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
      );
    } else if (busState.busData.isNotEmpty) {
      return ListView.builder(
        itemCount: busState.busData.length,
        itemBuilder: (context, index) {
          final bus = busState.busData[index];

          final bottom = index == busState.busData.length - 1 ? 12.0 : 0.0;

          return Padding(
            padding:
                EdgeInsets.only(top: 12, left: 12, right: 12, bottom: bottom),
            child: Material(
              borderRadius: ClubRadii.card,
              child: InkWell(
                borderRadius: ClubRadii.card,
                onTap: () async {
                  await _showModalBottomSheet(context, bus);
                },
                child: ClubCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bus.departureStation,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                bus.runTime,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                bus.description,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(thickness: 1),
                              Text(
                                bus.arrivalStationTime,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                bus.arrivalStation,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                bus.totalTime,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else if (busState.selectedDate.isNotEmpty) {
      return const ClubCard(
        margin: EdgeInsets.all(20),
        child: EmptyWidget(
          title: '今天没有车了',
          subtitle: '明天再来吧',
          icon: Icons.directions_bus,
        ),
      );
    }

    return Container();
  }

  Future<void> _showSettingsModalBottomSheet(
    BuildContext context,
    BusPageState busState,
    BusPageNotifier busController,
  ) async {
    await showClubModalBottomSheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '校车页面设置',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          ClubListTile(
            title: const Text('是否显示校车磁贴'),
            trailing: CupertinoSwitch(
              value: busState.isShowBus,
              onChanged: busController.toggleShowBus,
            ),
          ),
          // if (!kIsWeb) const SizedBox(height: 10),
          // if (!kIsWeb)
          //   ClubListTile(
          //     title: const Text('是否使用新API'),
          //     subtitle: const Text('新的API接口只能在校园网内使用'),
          //     trailing: CupertinoSwitch(
          //       value: busState.useNewApi,
          //       onChanged: busController.toggleUseNewApi,
          //     ),
          //   ),
        ],
      ),
    );
  }

  Future<void> _showModalBottomSheet(BuildContext context, BusItem bus) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ModalHeader(title: bus.lineName),
        ModalInfoRow(
          icon: Icons.access_time,
          label: '出发时间',
          content: bus.runTime,
          color: const Color(0xFF007AFF),
        ),
        const ModalSpacing(),
        ModalInfoRow(
          icon: Icons.location_on,
          label: '终点站',
          content: bus.arrivalStation,
          color: const Color(0xFFFF3B30),
        ),
        const ModalSpacing(),
        ModalInfoRow(
          icon: Icons.schedule,
          label: '预计到达',
          content: bus.arrivalStationTime,
          color: const Color(0xFF34C759),
        ),
        const ModalSpacing(),
        ModalInfoRow(
          icon: Icons.info_outline,
          label: '校车信息',
          content: bus.description,
          color: const Color(0xFFFF9500),
          maxLines: 3,
        ),
      ],
    );

    if (isTablet) {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20),
                child: content,
              ),
            ],
          );
        },
      );
    }

    return showClubModalBottomSheet(context, content);
  }
}
