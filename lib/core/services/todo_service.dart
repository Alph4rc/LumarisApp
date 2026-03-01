import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:ios_club_app/core/services/base_http_client.dart';
import 'package:ios_club_app/core/services/club_service.dart';
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
  static final BaseHttpClient _client = BaseHttpClient(
    baseUrl: 'https://www.xauat.site/api',
    enableCache: false,
  );

  // 保留 _dio 引用以便在需要自定义 Options（如 Authorization header）时使用
  static Dio get _dio => _client.dio;

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

  /// 从俱乐部服务器获取待办事项列表
  ///
  /// 通过 HTTP 请求从俱乐部服务器获取用户的待办事项列表
  /// 如果认证失败会尝试重新登录并再次请求
  static Future<List<TodoItem>> getClubTodoList() async {
    final prefs = PrefsService.instance;
    final secureStorage = SecureStorageService.instance;
    final memberDataString = prefs.getString(PrefsKeys.MEMBER_DATA);

    if (memberDataString == null || memberDataString.isEmpty) {
      return [];
    }

    final memberData = jsonDecode(memberDataString);

    var jwt = await secureStorage.read(key: PrefsKeys.MEMBER_JWT);

    try {
      final response = await _dio.get(
        '/Member/GetTodos',
        options: Options(headers: {'Authorization': 'Bearer $jwt'}),
      );

      if (response.statusCode == 200) {
        final List<TodoItem> list = [];
        for (var i in response.data) {
          list.add(fromJsonClub(i));
        }
        return list;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        if (await ClubService.loginMember(
            memberData['userName'], memberData['userId'])) {
          jwt = await secureStorage.read(key: PrefsKeys.MEMBER_JWT);

          try {
            final retryResponse = await _dio.get(
              '/Member/GetTodos',
              options: Options(headers: {'Authorization': 'Bearer $jwt'}),
            );

            if (retryResponse.statusCode == 200) {
              final List<TodoItem> list = [];
              for (var i in retryResponse.data) {
                list.add(fromJsonClub(i));
              }
              return list;
            }
          } catch (_) {
            // 重试失败，返回空列表
          }
        }
      }
    }

    return [];
  }

  /// 将俱乐部API返回的JSON数据转换为TodoItem对象
  ///
  /// [json] 从俱乐部API获取的待办事项JSON数据
  /// 返回转换后的TodoItem对象
  static TodoItem fromJsonClub(Map<String, dynamic> json) {
    // status 字段可能是 bool 或 int（0/1），统一处理
    final dynamic rawStatus = json['status'];
    final bool completed = rawStatus == true || rawStatus == 1;

    final item = TodoItem(
      id: json['id']?.toString(),
      title: (json['title'] ?? '').toString(),
      deadline: (json['endTime'] ?? '').toString(),
      isCompleted: completed,
    );

    item.description = json['description']?.toString();
    item.key = json['key']?.toString();

    return item;
  }

  /// 将本地待办事项同步到俱乐部服务器
  ///
  /// 将本地存储的待办事项逐一上传到俱乐部服务器
  /// 如果全部上传成功，则清除本地待办事项数据
  static Future<void> nowToUpdate() async {
    final prefs = PrefsService.instance;
    final secureStorage = SecureStorageService.instance;
    final memberDataString = prefs.getString(PrefsKeys.MEMBER_DATA);

    if (memberDataString == null || memberDataString.isEmpty) {
      return;
    }

    var jwt = await secureStorage.read(key: PrefsKeys.MEMBER_JWT);

    final list = await getLocalTodoList();
    var isOK = true;
    for (var i in list) {
      try {
        final response = await _dio.post(
          '/Member/AddTodo',
          options: Options(headers: {'Authorization': 'Bearer $jwt'}),
          data: {
            'title': i.title,
            'description': i.description,
            'endTime': i.deadline,
            'status': i.isCompleted
          },
        );

        if (response.statusCode != 200) {
          isOK = false;
        }
      } catch (_) {
        isOK = false;
      }
    }

    if (isOK) {
      // 清除 Hive 中的本地数据（数据已成功同步到服务器）
      await clearLocalData();
    }
  }
}
