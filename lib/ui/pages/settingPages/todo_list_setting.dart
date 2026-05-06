import 'package:flutter/cupertino.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

class TodoListSetting extends StatefulWidget {
  const TodoListSetting({super.key});

  @override
  State<StatefulWidget> createState() => _TodoListSettingState();
}

class _TodoListSettingState extends State<TodoListSetting> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.clubColors;
    return ClubListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(
        CupertinoIcons.cloud_upload_fill,
        size: 20,
        color: colors.secondaryLabel,
      ),
      title: const Text('是否将待办保存至云端'),
      subtitle: const Text('该服务已暂停'),
      trailing: const CupertinoSwitch(
        value: false,
        onChanged: null,
      ),
    );
  }
}
