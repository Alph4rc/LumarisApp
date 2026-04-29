import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/components/club_modal_bottom_sheet.dart';

// 添加字体设置组件
class FontFamilySetting extends ConsumerWidget {
  const FontFamilySetting({super.key});

  static const List<String> _fontOptions = [
    '',
    'Arial',
    'Roboto',
    'San Francisco',
    'Segoe UI',
    '微软雅黑',
    'Microsoft YaHei',
    'PingFang SC',
    'Helvetica Neue',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStoreProvider);
    final settingsStore = ref.read(settingsStoreProvider.notifier);

    return ClubListTile(
      leading: Icon(
        Icons.font_download,
        size: 20,
        color: Colors.blue,
      ),
      title: const Text('字体设置'),
      subtitle: const Text('为桌面平台选择字体(下次打开时才会应用)'),
      trailing: Text(_fontOptions.contains(settings.fontFamily)
          ? settings.fontFamily.isEmpty
              ? '系统默认'
              : settings.fontFamily
          : '自定义'),
      onTap: () => showClubModalBottomSheet(
        context,
        SizedBox(
          height: 300,
          child: CupertinoPicker(
            magnification: 1.22,
            squeeze: 1.2,
            useMagnifier: true,
            itemExtent: 32.0,
            scrollController: FixedExtentScrollController(
                initialItem: _fontOptions
                    .indexWhere((element) => element == settings.fontFamily)),
            onSelectedItemChanged: (int selectedItem) {
              settingsStore.setFontFamily(_fontOptions[selectedItem]);
            },
            children: List.generate(_fontOptions.length, (int index) {
              return Center(
                  child: Text(_fontOptions[index].isEmpty
                      ? '系统默认'
                      : _fontOptions[index]));
            }),
          ),
        ),
      ),
    );
  }
}
