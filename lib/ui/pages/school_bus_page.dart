import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/features/education/models/bus_model.dart'
    show BusItem;
import 'package:ios_club_app/state/app_states.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/components/club_modal_bottom_sheet.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:ios_club_app/ui/components/empty_widget.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/ui/components/modal_components.dart';
import 'package:ios_club_app/state/bus_page_notifier.dart';

class SchoolBusPage extends ConsumerWidget {
  const SchoolBusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busState = ref.watch(busControllerProvider);
    final busController = ref.read(busControllerProvider.notifier);
    final colors = context.clubColors;

    return Scaffold(
      appBar: AppBar(
        title: _buildCampusSwitcher(busState, busController, colors),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: busController.refreshData,
            tooltip: '刷新',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettingsModalBottomSheet(
              context,
              busState,
              busController,
            ),
            tooltip: '设置',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(busState, busController, colors),
          Expanded(
            child: _buildContent(context, ref, busState, colors),
          ),
        ],
      ),
    );
  }

  Widget _buildCampusSwitcher(
    BusPageState busState,
    BusPageNotifier busController,
    ClubColors colors,
  ) {
    return CupertinoSlidingSegmentedControl<bool>(
      groupValue: busState.isCaoTang,
      children: {
        true: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '草堂',
            style: TextStyle(
              fontSize: 14,
              fontWeight: busState.isCaoTang ? FontWeight.w600 : null,
            ),
          ),
        ),
        false: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '雁塔',
            style: TextStyle(
              fontSize: 14,
              fontWeight: !busState.isCaoTang ? FontWeight.w600 : null,
            ),
          ),
        ),
      },
      onValueChanged: (val) {
        if (val != null && val != busState.isCaoTang) {
          busController.toggleCampus();
        }
      },
    );
  }

  Widget _buildDateSelector(
    BusPageState busState,
    BusPageNotifier busController,
    ClubColors colors,
  ) {
    final dates = busController.availableDates.entries.toList();
    final selectedIndex =
        dates.indexWhere((e) => e.key == busState.selectedDate);

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final entry = dates[index];
          final isSelected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => busController.selectDateByIndex(index),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primary
                      : colors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : colors.secondaryLabel,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    BusPageState busState,
    ClubColors colors,
  ) {
    if (busState.isLoading) {
      return const Center(
        child: LoadingStateView(
          title: '正在获取校车班次',
          subtitle: '正在按日期整理两校区往返班车信息',
          showCard: false,
        ),
      );
    }

    final hasBusData = busState.busData.isNotEmpty;
    if (busState.errorMessage.isNotEmpty && !hasBusData) {
      return Center(
        child: ClubCard(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: colors.danger),
              const SizedBox(height: 16),
              Text(
                busState.errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.label, fontSize: 16),
              ),
              const SizedBox(height: 20),
              CupertinoButton.filled(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                onPressed: () =>
                    ref.read(busControllerProvider.notifier).refreshData(),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    if (!hasBusData) {
      return const EmptyWidget(
        title: '今天没有车了',
        subtitle: '明天再来吧',
        icon: Icons.directions_bus_filled_rounded,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount:
          busState.busData.length + (busState.errorMessage.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (busState.errorMessage.isNotEmpty && index == 0) {
          return ClubCard(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: colors.warning,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    busState.errorMessage,
                    style: TextStyle(color: colors.secondaryLabel),
                  ),
                ),
              ],
            ),
          );
        }
        final busIndex = busState.errorMessage.isNotEmpty ? index - 1 : index;
        final bus = busState.busData[busIndex];
        return BusTimelineTile(
          bus: bus,
          onTap: () => _showModalBottomSheet(context, bus),
        );
      },
    );
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
            '页面设置',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          ClubListTile(
            title: const Text('显示校车磁贴'),
            subtitle: const Text('在首页显示最近的班车信息'),
            trailing: CupertinoSwitch(
              value: busState.isShowBus,
              onChanged: busController.toggleShowBus,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _showModalBottomSheet(BuildContext context, BusItem bus) {
    final colors = context.clubColors;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ModalHeader(title: bus.lineName),
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Icons.access_time_filled_rounded,
          label: '出发时间',
          content: bus.runTime,
          color: colors.primary,
        ),
        _buildInfoRow(
          icon: Icons.location_on_rounded,
          label: '终点站',
          content: bus.arrivalStation,
          color: colors.danger,
        ),
        _buildInfoRow(
          icon: Icons.schedule_rounded,
          label: '预计到达',
          content: bus.arrivalStationTime,
          color: colors.success,
        ),
        _buildInfoRow(
          icon: Icons.info_outline_rounded,
          label: '班次信息',
          content: bus.description,
          color: colors.warning,
          maxLines: 5,
        ),
        const SizedBox(height: 16),
      ],
    );

    return showClubModalBottomSheet(context, content);
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String content,
    required Color color,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BusTimelineTile extends StatelessWidget {
  const BusTimelineTile({
    super.key,
    required this.bus,
    required this.onTap,
  });

  final BusItem bus;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.clubColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: ClubCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTimeDisplay(bus.runTime, '出发', colors),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: colors.tertiaryLabel,
                    ),
                  ),
                  _buildTimeDisplay(bus.arrivalStationTime, '到达', colors),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      bus.totalTime,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${bus.departureStation} → ${bus.arrivalStation}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (bus.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            bus.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.secondaryLabel,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.quaternaryLabel,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeDisplay(String time, String label, ClubColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: colors.label,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: colors.tertiaryLabel,
          ),
        ),
      ],
    );
  }
}
