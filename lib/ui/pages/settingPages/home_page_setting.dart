import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/components/club_modal_bottom_sheet.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

class HomePageSetting extends ConsumerWidget {
  const HomePageSetting({super.key});

  static const List<String> _pageNames = [
    '首页',
    '课程页',
    '成绩页',
    '个人页',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStoreProvider);
    final settingsStore = ref.read(settingsStoreProvider.notifier);
    final colors = context.clubColors;

    return ClubListTile(
      leading: Icon(
        Icons.pageview,
        size: 20,
        color: colors.primary,
      ),
      title: const Text('打开应用的第一个页面'),
      trailing: Text(_pageNames[settings.pageIndex]),
      onTap: () => showClubModalBottomSheet(
        context,
        SizedBox(
          height: 200, // 给 CupertinoPicker 固定高度
          child: CupertinoPicker(
            magnification: 1.22,
            squeeze: 1.2,
            useMagnifier: true,
            itemExtent: 32.0,
            scrollController:
                FixedExtentScrollController(initialItem: settings.pageIndex),
            onSelectedItemChanged: (int selectedItem) {
              settingsStore.setPageIndex(selectedItem);
            },
            children: List.generate(_pageNames.length, (int index) {
              return Center(child: Text(_pageNames[index]));
            }),
          ),
        ),
      ),
    );
  }
}
