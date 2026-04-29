import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';

class ShowTomorrowSetting extends StatefulWidget {
  const ShowTomorrowSetting({super.key});

  @override
  State<StatefulWidget> createState() => _ShowTomorrowSettingState();
}

class _ShowTomorrowSettingState extends State<ShowTomorrowSetting> {
  final SettingsStore settingsStore = SettingsStore.to;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClubListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(
        CupertinoIcons.calendar,
        size: 20,
        color: CupertinoColors.systemPurple,
      ),
      title: const Text('显示明日课程'),
      subtitle: const Text('当今日无课时显示明日课程'),
      trailing: Obx(() => CupertinoSwitch(
            value: settingsStore.isShowTomorrow,
            onChanged: (bool value) async {
              await settingsStore.setIsShowTomorrow(value);
            },
          )),
    );
  }
}
