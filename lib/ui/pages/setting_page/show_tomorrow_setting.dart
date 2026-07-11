import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

class ShowTomorrowSetting extends ConsumerWidget {
  const ShowTomorrowSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStoreProvider);
    final settingsStore = ref.read(settingsStoreProvider.notifier);
    final colors = context.clubColors;

    return ClubListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(
        CupertinoIcons.calendar,
        size: 20,
        color: colors.purple,
      ),
      title: Text(context.l10n.showTomorrowCourses),
      subtitle: Text(context.l10n.showTomorrowCoursesSubtitle),
      trailing: CupertinoSwitch(
        value: settings.isShowTomorrow,
        onChanged: (bool value) async {
          await settingsStore.setIsShowTomorrow(value);
        },
      ),
    );
  }
}
