import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/components/club_modal_bottom_sheet.dart';

class HomePageSetting extends StatefulWidget {
  const HomePageSetting({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageSettingState();
}

class _HomePageSettingState extends State<HomePageSetting> {
  final SettingsStore settingsStore = SettingsStore.to;
  final List<String> _pageNames = [
    '首页',
    '课程页',
    '成绩页',
    '个人页',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClubListTile(
      leading: Icon(
        Icons.pageview,
        size: 20,
        color: Colors.blue,
      ),
      title: const Text('打开应用的第一个页面'),
      trailing: Obx(() => Text(_pageNames[settingsStore.pageIndex])),
      onTap: () => showClubModalBottomSheet(
        context,
        SizedBox(
          height: 200, // 给 CupertinoPicker 固定高度
          child: Obx(() => CupertinoPicker(
                magnification: 1.22,
                squeeze: 1.2,
                useMagnifier: true,
                itemExtent: 32.0,
                scrollController: FixedExtentScrollController(
                    initialItem: settingsStore.pageIndex),
                onSelectedItemChanged: (int selectedItem) {
                  settingsStore.setPageIndex(selectedItem);
                },
                children: List.generate(_pageNames.length, (int index) {
                  return Center(child: Text(_pageNames[index]));
                }),
              )),
        ),
      ),
    );
  }
}
