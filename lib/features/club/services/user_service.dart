import 'package:flutter/foundation.dart';
import 'package:ios_club_app/features/club/services/api_client.dart';
import 'package:ios_club_app/features/club/models/member_model.dart';
import 'package:ios_club_app/features/club/models/todo_model.dart';
import 'package:ios_club_app/features/club/models/student_model.dart';
import 'package:ios_club_app/features/club/utils/api_response_helper.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

class UserService {
  /// 获取用户数据
  static Future<MemberModel?> getUserData() async {
    try {
      final response = await ApiClient.get('/User/data');
      return await ApiResponseHelper.parseSingleObject(
        response,
        MemberModel.fromJson,
        errorMessage: 'Error fetching user data',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching user data: $e');
      }
      return null;
    }
  }

  /// 获取用户待办事项
  static Future<List<TodoModel>?> getUserTodos() async {
    try {
      final response = await ApiClient.get('/User/todos');
      return await ApiResponseHelper.parseList(
        response,
        TodoModel.fromJson,
        errorMessage: 'Error fetching user todos',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching user todos: $e');
      }
      return null;
    }
  }

  /// 创建用户待办事项
  static Future<TodoModel?> createUserTodo(TodoModel todoData) async {
    try {
      final response = await ApiClient.post('/User/todos', body: todoData.toJson());
      return await ApiResponseHelper.parseSingleObject(
        response,
        TodoModel.fromJson,
        errorMessage: 'Error creating user todo',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error creating user todo: $e');
      }
      return null;
    }
  }

  /// 更新用户待办事项
  static Future<bool> updateUserTodo(TodoModel todoData) async {
    try {
      final response = await ApiClient.put('/User/todos', body: todoData.toJson());
      return await ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error updating user todo',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error updating user todo: $e');
      }
      return false;
    }
  }

  /// 删除用户待办事项
  static Future<bool> deleteUserTodo(String id) async {
    try {
      final response = await ApiClient.delete('/User/todos/$id');
      return await ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error deleting user todo',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error deleting user todo: $e');
      }
      return false;
    }
  }

  /// 获取特定待办事项
  static Future<TodoModel?> getTodoById(String id) async {
    try {
      final response = await ApiClient.get('/User/todos/$id');
      return await ApiResponseHelper.parseSingleObject(
        response,
        TodoModel.fromJson,
        errorMessage: 'Error fetching todo by id',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching todo by id: $e');
      }
      return null;
    }
  }

  /// 更新用户资料
  static Future<bool> updateUserProfile(StudentModel profileData) async {
    try {
      final response = await ApiClient.put('/User/profile', body: profileData.toJson());
      return await ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error updating user profile',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error updating user profile: $e');
      }
      return false;
    }
  }
}