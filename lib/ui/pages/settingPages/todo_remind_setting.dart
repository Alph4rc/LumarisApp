import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/features/system/notifications/notification_service.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

class TodoRemindSetting extends ConsumerWidget {
  const TodoRemindSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStoreProvider);
    final settingsStore = ref.read(settingsStoreProvider.notifier);
    final colors = context.clubColors;

    return ClubListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(
        Icons.notifications_active,
        size: 20,
        color: colors.secondaryLabel,
      ),
      title: Text(context.l10n.todoReminder),
      subtitle: Text(context.l10n.todoReminderSubtitle),
      trailing: CupertinoSwitch(
        value: settings.todoRemindEnabled,
        onChanged: (bool value) async {
          await settingsStore.setTodoRemindEnabled(value);
          if (value && context.mounted) {
            await NotificationService.set(context);
          }
        },
      ),
    );
  }
}
