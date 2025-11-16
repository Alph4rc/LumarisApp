import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ios_club_app/clubServices/api_client.dart';
import 'package:ios_club_app/clubModels/todo_model.dart';

class TodoService {
  /// 获取所有待办事项
  static Future<List<TodoModel>?> getAllTodos() async {
    try {
      final response = await ApiClient.get('/Todo');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => TodoModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching all todos: $e');
      }
    }
    return null;
  }

  /// 创建待办事项
  static Future<String?> createTodo(TodoModel todoData) async {
    try {
      final response = await ApiClient.post('/Todo', body: todoData.toJson());
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating todo: $e');
      }
    }
    return null;
  }

  /// 更新待办事项
  static Future<bool> updateTodo(TodoModel todoData) async {
    try {
      final response = await ApiClient.put('/Todo', body: todoData.toJson());
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating todo: $e');
      }
    }
    return false;
  }

  /// 获取待办事项统计信息
  static Future<bool> getTodoStatistics() async {
    try {
      final response = await ApiClient.get('/Todo/statistics');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching todo statistics: $e');
      }
    }
    return false;
  }

  /// 根据ID获取待办事项
  static Future<TodoModel?> getTodoById(String id) async {
    try {
      final response = await ApiClient.get('/Todo/$id');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return TodoModel.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching todo by ID: $e');
      }
    }
    return null;
  }

  /// 删除待办事项
  static Future<bool> deleteTodo(String id) async {
    try {
      final response = await ApiClient.delete('/Todo/$id');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting todo: $e');
      }
    }
    return false;
  }

  /// 分页获取待办事项
  static Future<List<TodoModel>?> getTodosByPage(int page, int pageSize) async {
    try {
      final response = await ApiClient.get('/Todo/Page/$page/$pageSize');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => TodoModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching todos by page: $e');
      }
    }
    return null;
  }
}