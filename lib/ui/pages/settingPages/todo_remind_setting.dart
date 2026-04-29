import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/features/system/notifications/notification_service.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';

class TodoRemindSetting extends StatefulWidget {
  const TodoRemindSetting({super.key});

  @override
  State<StatefulWidget> createState() => _TodoRemindSettingState();
}

class _TodoRemindSettingState extends State<TodoRemindSetting> {
  final SettingsStore settingsStore = SettingsStore.to;

  @override
  Widget build(BuildContext context) {
    return ClubListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(
        Icons.notifications_active,
        size: 20,
        color: Colors.grey,
      ),
      title: const Text('待办事务提醒'),
      subtitle: const Text('在待办事务截止前进行提醒'),
      trailing: Obx(() => CupertinoSwitch(
            value: settingsStore.todoRemindEnabled,
            onChanged: (bool value) async {
              await settingsStore.setTodoRemindEnabled(value);
              if (value && context.mounted) {
                await NotificationService.set(context);
              }
            },
          )),
    );
  }
}
