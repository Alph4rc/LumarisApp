import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/services/app_locale_service.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

class LanguageSetting extends ConsumerWidget {
  const LanguageSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.clubColors;
    final l10n = context.l10n;
    final settings = ref.watch(settingsStoreProvider);
    final settingsStore = ref.read(settingsStoreProvider.notifier);

    return ClubListTile(
      leading: Icon(
        CupertinoIcons.globe,
        size: 20,
        color: colors.primary,
      ),
      title: Text(l10n.language),
      subtitle: Text(
        AppLocaleService.labelOf(l10n, settings.localeCode),
      ),
      showChevron: true,
      onTap: () => _showLanguagePicker(
        context: context,
        currentCode: settings.localeCode,
        onChanged: settingsStore.setLocaleCode,
      ),
    );
  }

  Future<void> _showLanguagePicker({
    required BuildContext context,
    required AppLocaleCode currentCode,
    required Future<void> Function(AppLocaleCode code) onChanged,
  }) async {
    final l10n = context.l10n;
    final colors = context.clubColors;

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (popupContext) {
        return CupertinoActionSheet(
          title: Text(l10n.language),
          actions: AppLocaleService.options.map((option) {
            final selected = option.code == currentCode;

            return CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.of(popupContext).pop();
                await onChanged(option.code);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    option.labelBuilder(l10n),
                    style: TextStyle(
                      color: selected ? colors.primary : colors.label,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(width: 8),
                    Icon(
                      CupertinoIcons.check_mark,
                      size: 18,
                      color: colors.primary,
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(popupContext).pop(),
            child: Text(l10n.cancel),
          ),
        );
      },
    );
  }
}
