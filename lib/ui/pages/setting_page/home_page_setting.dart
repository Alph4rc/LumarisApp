import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/components/club_modal_bottom_sheet.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

class HomePageSetting extends ConsumerWidget {
  const HomePageSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStoreProvider);
    final settingsStore = ref.read(settingsStoreProvider.notifier);
    final colors = context.clubColors;
    final l10n = context.l10n;
    final pageNames = [
      l10n.home,
      l10n.schedulePage,
      l10n.scorePage,
      l10n.profilePage
    ];

    return ClubListTile(
      leading: Icon(
        Icons.pageview,
        size: 20,
        color: colors.primary,
      ),
      title: Text(l10n.firstPageOnLaunch),
      trailing: Text(pageNames[settings.pageIndex]),
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
            children: List.generate(pageNames.length, (int index) {
              return Center(child: Text(pageNames[index]));
            }),
          ),
        ),
      ),
    );
  }
}
