import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:ios_club_app/core/services/hive_manager.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/core/models/todo_item.dart';
import 'package:ios_club_app/core/services/secure_storage_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

/// 待办事项服务类
///
/// 提供本地和云端待办事项的管理功能，包括获取、设置和同步待办事项列表
class TodoService {
  /// 获取 Hive Box
  static Future<Box<dynamic>> _getBox() async {
    return await HiveManager.instance.openBox(HiveManager.todoBoxName);
  }

  /// 保存待办事项列表到本地存储
  ///
  /// 将待办事项列表保存到 Hive 中，以用户名作为键进行区分
  ///
  /// [list] 需要保存的待办事项列表
  static Future<void> setTodoList(List<TodoItem> list) async {
    final secureStorage = SecureStorageService.instance;
    final String? username = await secureStorage.read(key: PrefsKeys.USERNAME);

    if (username != null) {
      final box = await _getBox();
      await box.put(username, list);
    } else {
      throw Exception('No username found');
    }
  }

  /// 清除本地待办事项数据
  static Future<void> clearLocalData() async {
    try {
      final secureStorage = SecureStorageService.instance;
      final String? username =
          await secureStorage.read(key: PrefsKeys.USERNAME);

      if (username != null) {
        final box = await _getBox();
        await box.delete(username);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to clear local todo data',
          error: e, stackTrace: stackTrace);
    }
  }

  /// 从本地存储获取待办事项列表
  ///
  /// 从 Hive 中读取当前用户的待办事项列表
  static Future<List<TodoItem>> getLocalTodoList() async {
    final secureStorage = SecureStorageService.instance;
    final String? username = await secureStorage.read(key: PrefsKeys.USERNAME);

    if (username != null) {
      final box = await _getBox();
      final dynamic data = box.get(username);

      if (data != null) {
        if (data is List) {
          return data.cast<TodoItem>();
        }
      }

      // 尝试迁移
      return await _migrateFromPrefs(username);
    } else {
      return [];
    }
  }

  /// 从 SharedPreferences 迁移数据
  static Future<List<TodoItem>> _migrateFromPrefs(String username) async {
    final prefs = PrefsService.instance;
    // ignore: deprecated_member_use
    final jsonString = prefs.getString(PrefsKeys.TODO_DATA);

    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        if (jsonMap.containsKey(username)) {
          AppLogger.info(
              'Migrating todo data for $username from SharedPreferences to Hive...');
          final d = jsonMap[username] as List;
          final List<TodoItem> list = [];
          for (final i in d) {
            try {
              list.add(TodoItem.fromJson(i as Map<String, dynamic>));
            } catch (itemErr) {
              AppLogger.warning('Skipping corrupt todo entry during migration',
                  error: itemErr);
            }
          }

          // 保存到 Hive
          final box = await _getBox();
          await box.put(username, list);

          AppLogger.info(
              'Todo data migration completed. Count: ${list.length}');
          return list;
        }
      } catch (e) {
        AppLogger.warning('Failed to migrate todo data', error: e);
      }
    }
    return [];
  }
}
