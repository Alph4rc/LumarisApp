import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/features/system/notifications/notification_service.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:numberpicker/numberpicker.dart';

class RemindSetting extends ConsumerWidget {
  const RemindSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStoreProvider);
    final settingsStore = ref.read(settingsStoreProvider.notifier);
    final colors = context.clubColors;

    return Column(
      children: [
        ClubListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: Icon(
            Icons.schedule,
            size: 20,
            color: colors.success,
          ),
          title: const Text('课程通知'),
          subtitle: const Text('上课前进行提醒'),
          trailing: CupertinoSwitch(
            value: settings.isRemind,
            onChanged: (bool value) async {
              await settingsStore.setIsRemind(value);
              if (value && context.mounted) {
                await NotificationService.set(context);
              }
            },
          ),
        ),
        settings.isRemind
            ? ClubListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                leading: const SizedBox(width: 24),
                title: const Text('提前几分钟提醒'),
                trailing: Text('${settings.remindTime}分钟'),
                onTap: () {
                  _show(context, ref);
                },
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  Future<void> _show(BuildContext context, WidgetRef ref) async {
    final a = MediaQuery.of(context).size.width;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: a,
        minWidth: a,
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      builder: (BuildContext context) {
        return Consumer(
          builder: (context, ref, child) {
            final settings = ref.watch(settingsStoreProvider);
            final settingsStore = ref.read(settingsStoreProvider.notifier);
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NumberPicker(
                    value: settings.remindTime,
                    minValue: 10,
                    maxValue: 120,
                    step: 1,
                    onChanged: (value) async {
                      await settingsStore.setRemindTime(value);
                    },
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
