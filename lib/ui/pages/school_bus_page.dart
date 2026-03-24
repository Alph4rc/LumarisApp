import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/ui/controllers/bus_controller.dart';
import 'package:ios_club_app/features/education/models/bus_model.dart' show BusItem;
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/club_modal_bottom_sheet.dart';
import 'package:ios_club_app/ui/components/empty_widget.dart';
import 'package:ios_club_app/ui/components/modal_components.dart';

class SchoolBusPage extends StatelessWidget {
  const SchoolBusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BusController busController = Get.put(BusController());

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => CupertinoButton(
              onPressed: busController.toggleCampus,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(busController.isCaoTang.value ? '草堂校区' : '雁塔校区'),
                  Icon(Icons.arrow_forward),
                  Text(busController.isCaoTang.value ? '雁塔校区' : '草堂校区')
                ],
              ),
            )),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: TabBar(
            controller: busController.tabController,
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
            icon: Icon(Icons.refresh),
            onPressed: busController.refreshData,
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => _showSettingsModalBottomSheet(busController),
          ),
        ],
      ),
      body: _buildBuses(busController),
    );
  }

  Widget _buildBuses(BusController busController) {
    return Obx(() {
      if (busController.isLoading.value) {
        return Center(
          child: ClubCard(
            margin: EdgeInsets.only(top: 40),
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        );
      } else if (busController.errorMessage.value.isNotEmpty) {
        return Center(
          child: ClubCard(
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.only(top: 40),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(busController.errorMessage.value,
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ),
        );
      } else if (busController.busData.isNotEmpty) {
        return ListView.builder(
            itemCount: busController.busData.length,
            itemBuilder: (context, index) {
              final bus = busController.busData[index];

              var bottom =
                  index == busController.busData.length - 1 ? 12.0 : 0.0;

              return Padding(
                padding: EdgeInsets.only(
                    top: 12, left: 12, right: 12, bottom: bottom),
                child: Material(
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    child: ClubCard(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bus.departureStation,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    bus.runTime,
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                  Text(bus.description,
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold)),
                                  Divider(
                                    thickness: 1,
                                  ),
                                  Text(bus.arrivalStationTime,
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold))
                                ])),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                  Text(
                                    bus.arrivalStation,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    bus.totalTime,
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold),
                                  ),
                                ]))
                          ],
                        ),
                      ),
                    ),
                    onTap: () async {
                      await _showModalBottomSheet(context, bus);
                    },
                  ),
                ),
              );
            });
      } else if (busController.selectedDate.value.isNotEmpty) {
        return ClubCard(
            margin: EdgeInsets.all(20),
            child: EmptyWidget(
              title: '今天没有车了',
              subtitle: '明天再来吧',
              icon: Icons.directions_bus,
            ));
      }

      return Container();
    });
  }

  // 新增：显示设置的底部弹窗
  Future<void> _showSettingsModalBottomSheet(
      BusController busController) async {
    await showClubModalBottomSheet(
      Get.context!,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '校车页面设置',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              Obx(() => ListTile(
                    title: const Text('是否显示校车磁贴'),
                    trailing: CupertinoSwitch(
                      value: busController.isShowBus.value,
                      onChanged: (bool value) async {
                        busController.toggleShowBus(value);
                      },
                    ),
                  )),
              if (!kIsWeb) const SizedBox(height: 10),
              if (!kIsWeb)
                Obx(() => ListTile(
                      title: const Text('是否使用新API'),
                      subtitle: const Text('新的API接口只能在校园网内使用'),
                      trailing: CupertinoSwitch(
                        value: busController.useNewApi.value,
                        onChanged: (bool value) async {
                          busController.toggleUseNewApi(value);
                        },
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showModalBottomSheet(BuildContext context, BusItem bus) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    var content = Column(
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
                )
              ],
            );
          });
    }

    return showClubModalBottomSheet(context, content);
  }
}
