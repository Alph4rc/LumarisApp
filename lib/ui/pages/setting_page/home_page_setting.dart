import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/state/settings_store.dart';

class HomePageSetting extends ConsumerWidget {
  const HomePageSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStoreProvider);
    final settingsStore = ref.read(settingsStoreProvider.notifier);
    final colors = context.mc.colors;
    final l10n = context.l10n;
    final pageNames = [
      l10n.home,
      l10n.schedulePage,
      l10n.scorePage,
      l10n.profilePage,
    ];

    return McListTile(
      leading: Icon(Icons.pageview, size: 20, color: colors.primary),
      title: Text(l10n.firstPageOnLaunch),
      trailing: Text(pageNames[settings.pageIndex]),
      onTap: () => showMcBottomSheet(
        context: context,
        builder: (_) => SizedBox(
          height: 200, // 给 CupertinoPicker 固定高度
          child: CupertinoPicker(
            magnification: 1.22,
            squeeze: 1.2,
            useMagnifier: true,
            itemExtent: 32.0,
            scrollController: FixedExtentScrollController(
              initialItem: settings.pageIndex,
            ),
            onSelectedItemChanged: (int selectedItem) {
              settingsStore.setPageIndex(selectedItem);
            },
            children: List.generate(pageNames.length, (int index) {
              return Center(child: Text(pageNames[index]));
            }),
          ),
        ),
        showHandle: true,
        contentPadding: const EdgeInsets.all(24),
        scrollable: true,
        maxHeight: MediaQuery.sizeOf(context).height * 0.6,
      ),
    );
  }
}
