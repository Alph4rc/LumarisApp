import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';

// 添加触觉反馈设置组件
class HapticFeedbackSetting extends ConsumerWidget {
  const HapticFeedbackSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStoreProvider);
    final settingsStore = ref.read(settingsStoreProvider.notifier);

    return ClubListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(
        Icons.vibration,
        size: 20,
        color: Colors.deepPurple,
      ),
      title: const Text('触觉反馈'),
      subtitle: const Text('底部导航栏点击时震动'),
      trailing: CupertinoSwitch(
        value: settings.enableHapticFeedback,
        onChanged: (bool value) async {
          await settingsStore.setEnableHapticFeedback(value);
        },
      ),
    );
  }
}
