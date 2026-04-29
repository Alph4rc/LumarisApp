import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';

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
    return ClubListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(
        CupertinoIcons.cloud_upload_fill,
        size: 20,
        color: Colors.grey,
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
