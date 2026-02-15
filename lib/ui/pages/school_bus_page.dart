import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/features/education/controllers/bus_controller.dart';
import 'package:ios_club_app/core/models/bus_model.dart' show BusItem;
import 'package:ios_club_app/ui/components/club_modal_bottom_sheet.dart';
import 'package:ios_club_app/ui/components/empty_widget.dart';
import 'package:ios_club_app/ui/components/modal_components.dart';

class SchoolBusPage extends StatelessWidget {
  const SchoolBusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BusController busController = Get.put(BusController());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, busController),
            _buildCampusSelector(context, busController),
            _buildDateSelector(context, busController),
            Expanded(child: _buildBuses(context, busController)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, BusController busController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '校车查询',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
              letterSpacing: -0.5,
            ),
          ),
          Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(
                  CupertinoIcons.refresh,
                  color: CupertinoDynamicColor.resolve(CupertinoColors.activeBlue, context),
                  size: 24,
                ),
                onPressed: busController.refreshData,
              ),
              const SizedBox(width: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(
                  CupertinoIcons.settings,
                  color: CupertinoDynamicColor.resolve(CupertinoColors.activeBlue, context),
                  size: 24,
                ),
                onPressed: () => _showSettingsModalBottomSheet(busController),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCampusSelector(BuildContext context, BusController busController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: Obx(() => CupertinoSlidingSegmentedControl<int>(
              groupValue: busController.isCaoTang.value ? 0 : 1,
              children: const {
                0: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('草堂校区'),
                ),
                1: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('雁塔校区'),
                ),
              },
              onValueChanged: (value) {
                if (value == 0 && !busController.isCaoTang.value) {
                  HapticFeedback.selectionClick();
                  busController.toggleCampus();
                } else if (value == 1 && busController.isCaoTang.value) {
                  HapticFeedback.selectionClick();
                  busController.toggleCampus();
                }
              },
            )),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, BusController busController) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Obx(() {
        final dates = busController.availableDates.values.toList();
        final keys = busController.availableDates.keys.toList();
        final currentIndex = keys.indexOf(busController.selectedDate.value);
        
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final isSelected = index == currentIndex;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  busController.tabController.animateTo(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 12.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? CupertinoDynamicColor.resolve(CupertinoColors.activeBlue, context)
                        : CupertinoDynamicColor.resolve(CupertinoColors.tertiarySystemFill, context),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    dates[index],
                    style: TextStyle(
                      color: isSelected
                          ? CupertinoColors.white
                          : CupertinoDynamicColor.resolve(CupertinoColors.label, context),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildBuses(BuildContext context, BusController busController) {
    return Obx(() {
      if (busController.isLoading.value) {
        return const Center(child: CupertinoActivityIndicator());
      } else if (busController.errorMessage.value.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              busController.errorMessage.value,
              style: const TextStyle(color: CupertinoColors.systemRed),
              textAlign: TextAlign.center,
            ),
          ),
        );
      } else if (busController.busData.isNotEmpty) {
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: busController.busData.length,
          itemBuilder: (context, index) {
            final bus = busController.busData[index];
            final isLast = index == busController.busData.length - 1;
            return _buildBusListItem(context, bus, () => _showModalBottomSheet(context, bus), isLast);
          },
        );
      } else if (busController.selectedDate.value.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: EmptyWidget(
            title: '今天没有车了',
            subtitle: '明天再来吧',
            icon: CupertinoIcons.bus,
          ),
        );
      }
      return Container();
    });
  }

  Widget _buildBusListItem(BuildContext context, BusItem bus, VoidCallback onTap, bool isLast) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                // Left: Departure Time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bus.runTime,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bus.departureStation,
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoDynamicColor.resolve(CupertinoColors.secondaryLabel, context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Middle: Arrow & Info
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        bus.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoDynamicColor.resolve(CupertinoColors.tertiaryLabel, context),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: Icon(CupertinoIcons.arrow_right, size: 16, color: CupertinoColors.systemGrey),
                      ),
                      Text(
                        bus.arrivalStationTime,
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoDynamicColor.resolve(CupertinoColors.tertiaryLabel, context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right: Arrival
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      bus.totalTime,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bus.arrivalStation,
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoDynamicColor.resolve(CupertinoColors.secondaryLabel, context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isLast)
            const Divider(
              height: 1, 
              thickness: 0.5, 
              indent: 16, 
              endIndent: 0,
            ),
        ],
      ),
    );
  }

  // Settings Modal
  Future<void> _showSettingsModalBottomSheet(BusController busController) async {
    await showClubModalBottomSheet(
      Get.context!,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '校车设置',
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
                ),
              ),
              const SizedBox(height: 20),
              Obx(() => _buildSettingsTile(
                context,
                '显示校车磁贴',
                busController.isShowBus.value,
                (val) => busController.toggleShowBus(val),
              )),
              if (!kIsWeb) ...[
                const SizedBox(height: 16),
                Obx(() => _buildSettingsTile(
                  context,
                  '使用新API (仅校园网)',
                  busController.useNewApi.value,
                  (val) => busController.toggleUseNewApi(val),
                )),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, String title, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
          ),
        ),
        CupertinoSwitch(
          value: value,
          onChanged: onChanged,
        ),
      ],
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
          icon: CupertinoIcons.time,
          label: '出发时间',
          content: bus.runTime,
          color: CupertinoColors.activeBlue,
        ),
        const ModalSpacing(),
        ModalInfoRow(
          icon: CupertinoIcons.location_solid,
          label: '终点站',
          content: bus.arrivalStation,
          color: CupertinoColors.systemRed,
        ),
        const ModalSpacing(),
        ModalInfoRow(
          icon: CupertinoIcons.clock,
          label: '预计到达',
          content: bus.arrivalStationTime,
          color: CupertinoColors.activeGreen,
        ),
        const ModalSpacing(),
        ModalInfoRow(
          icon: CupertinoIcons.info,
          label: '校车信息',
          content: bus.description,
          color: CupertinoColors.systemOrange,
          maxLines: 3,
        ),
      ],
    );

    if (isTablet) {
      return showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              backgroundColor: CupertinoDynamicColor.resolve(CupertinoColors.secondarySystemGroupedBackground, context),
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
