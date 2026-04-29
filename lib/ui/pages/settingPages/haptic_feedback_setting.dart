import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';

// 添加触觉反馈设置组件
class HapticFeedbackSetting extends StatefulWidget {
  const HapticFeedbackSetting({super.key});

  @override
  State<HapticFeedbackSetting> createState() => _HapticFeedbackSettingState();
}

class _HapticFeedbackSettingState extends State<HapticFeedbackSetting> {
  final SettingsStore settingsStore = SettingsStore.to;

  @override
  Widget build(BuildContext context) {
    return ClubListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(
        Icons.vibration,
        size: 20,
        color: Colors.deepPurple,
      ),
      title: const Text('触觉反馈'),
      subtitle: const Text('底部导航栏点击时震动'),
      trailing: Obx(() => CupertinoSwitch(
            value: settingsStore.enableHapticFeedback,
            onChanged: (bool value) async {
              await settingsStore.setEnableHapticFeedback(value);
            },
          )),
    );
  }
}
