import 'package:flutter/foundation.dart';
import 'package:ios_club_app/features/club/services/api_client.dart';
import 'package:ios_club_app/features/club/models/todo_model.dart';
import 'package:ios_club_app/features/club/utils/api_response_helper.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

class TodoService {
  /// 获取所有待办事项
  static Future<List<TodoModel>?> getAllTodos() async {
    try {
      final response = await ApiClient.get('/Todo');
      return await ApiResponseHelper.parseList(
        response,
        TodoModel.fromJson,
        errorMessage: 'Error fetching all todos',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching all todos: $e');
      }
      return null;
    }
  }

  /// 创建待办事项
  static Future<String?> createTodo(TodoModel todoData) async {
    try {
      final response = await ApiClient.post('/Todo', body: todoData.toJson());
      return await ApiResponseHelper.parseString(
        response,
        errorMessage: 'Error creating todo',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error creating todo: $e');
      }
      return null;
    }
  }

  /// 更新待办事项
  static Future<bool> updateTodo(TodoModel todoData) async {
    try {
      final response = await ApiClient.put('/Todo', body: todoData.toJson());
      return await ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error updating todo',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error updating todo: $e');
      }
      return false;
    }
  }

  /// 获取待办事项统计信息
  static Future<bool> getTodoStatistics() async {
    try {
      final response = await ApiClient.get('/Todo/statistics');
      return await ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error fetching todo statistics',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching todo statistics: $e');
      }
      return false;
    }
  }

  /// 根据ID获取待办事项
  static Future<TodoModel?> getTodoById(String id) async {
    try {
      final response = await ApiClient.get('/Todo/$id');
      return await ApiResponseHelper.parseSingleObject(
        response,
        TodoModel.fromJson,
        errorMessage: 'Error fetching todo by ID',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching todo by ID: $e');
      }
      return null;
    }
  }

  /// 删除待办事项
  static Future<bool> deleteTodo(String id) async {
    try {
      final response = await ApiClient.delete('/Todo/$id');
      return await ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error deleting todo',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error deleting todo: $e');
      }
      return false;
    }
  }

  /// 分页获取待办事项
  static Future<List<TodoModel>?> getTodosByPage(int page, int pageSize) async {
    try {
      final response = await ApiClient.get('/Todo/Page/$page/$pageSize');
      return await ApiResponseHelper.parseList(
        response,
        TodoModel.fromJson,
        errorMessage: 'Error fetching todos by page',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching todos by page: $e');
      }
      return null;
    }
  }
}
