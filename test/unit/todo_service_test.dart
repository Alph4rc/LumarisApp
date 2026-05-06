import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ios_club_app/core/models/todo_item.dart';
import 'package:ios_club_app/core/services/hive_manager.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/services/todo_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final secureStore = <String, String>{};

  late Directory tempDir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();
  });

  setUp(() async {
    await PrefsService.instance.clear();
    secureStore.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'write':
          final key = call.arguments['key'] as String;
          final value = call.arguments['value'] as String?;
          if (value != null) {
            secureStore[key] = value;
          } else {
            secureStore.remove(key);
          }
          return null;
        case 'read':
          return secureStore[call.arguments['key'] as String];
        case 'delete':
          secureStore.remove(call.arguments['key'] as String);
          return null;
        case 'deleteAll':
          secureStore.clear();
          return null;
        default:
          return null;
      }
    });

    tempDir = await Directory.systemTemp.createTemp('todo_service_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(TodoItemAdapter());
    }
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('TodoService local list', () {
    test('should_set_and_get_local_todo_list_for_current_user', () async {
      secureStore[PrefsKeys.USERNAME] = 'u1';

      final todo = TodoItem(
        id: '1',
        title: 'task',
        deadline: '2026-03-01',
        isCompleted: false,
      );

      await TodoService.setTodoList([todo]);

      final list = await TodoService.getLocalTodoList();
      expect(list, hasLength(1));
      expect(list.first.title, 'task');
    });

    test('should_throw_when_setting_todo_without_username', () async {
      await expectLater(
        () => TodoService.setTodoList([]),
        throwsA(isA<Exception>()),
      );
    });

    test('should_migrate_todo_data_from_prefs_when_hive_empty', () async {
      secureStore[PrefsKeys.USERNAME] = 'u2';
      await PrefsService.instance.setString(
        PrefsKeys.TODO_DATA,
        jsonEncode({
          'u2': [
            {
              'id': '10',
              'title': 'legacy',
              'deadline': '2026-03-01',
              'isCompleted': true,
            },
            {
              'id': '11',
              'title': 'bad-item',
              'deadline': 'x',
              'isCompleted': false,
            }
          ]
        }),
      );

      final list = await TodoService.getLocalTodoList();

      expect(list, hasLength(2));
      expect(list.first.title, 'legacy');

      final box = await Hive.openBox<dynamic>(HiveManager.todoBoxName);
      expect(box.get('u2'), isNotNull);
    });

    test('should_return_empty_list_when_legacy_todo_json_is_corrupt', () async {
      secureStore[PrefsKeys.USERNAME] = 'u-corrupt';
      await PrefsService.instance.setString(
        PrefsKeys.TODO_DATA,
        '{not-valid-json',
      );

      final list = await TodoService.getLocalTodoList();

      expect(list, isEmpty);
    });

    test('should_return_empty_list_when_legacy_user_key_is_absent', () async {
      secureStore[PrefsKeys.USERNAME] = 'missing-user';
      await PrefsService.instance.setString(
        PrefsKeys.TODO_DATA,
        jsonEncode({
          'other-user': [
            {
              'title': 'legacy',
              'deadline': '2026-03-01',
              'isCompleted': false,
            }
          ]
        }),
      );

      final list = await TodoService.getLocalTodoList();

      expect(list, isEmpty);
    });

    test('should_return_empty_list_when_no_username', () async {
      final list = await TodoService.getLocalTodoList();
      expect(list, isEmpty);
    });

    test('clearLocalData should complete when username is missing', () async {
      await expectLater(TodoService.clearLocalData(), completes);
    });

    test('clearLocalData should delete user key and swallow errors', () async {
      secureStore[PrefsKeys.USERNAME] = 'u3';

      final box = await Hive.openBox<dynamic>(HiveManager.todoBoxName);
      await box.put('u3', [TodoItem(title: 'x', deadline: 'd')]);

      await TodoService.clearLocalData();
      expect(box.containsKey('u3'), isFalse);
    });
  });
}
