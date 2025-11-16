import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ios_club_app/clubServices/api_client.dart';
import 'package:ios_club_app/clubModels/member_model.dart';
import 'package:ios_club_app/clubModels/todo_model.dart';
import 'package:ios_club_app/clubModels/student_model.dart';

class UserService {
  /// 获取用户数据
  static Future<MemberModel?> getUserData() async {
    try {
      final response = await ApiClient.get('/User/data');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MemberModel.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data: $e');
      }
    }
    return null;
  }

  /// 获取用户待办事项
  static Future<List<TodoModel>?> getUserTodos() async {
    try {
      final response = await ApiClient.get('/User/todos');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => TodoModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user todos: $e');
      }
    }
    return null;
  }

  /// 创建用户待办事项
  static Future<TodoModel?> createUserTodo(TodoModel todoData) async {
    try {
      final response = await ApiClient.post('/User/todos', body: todoData.toJson());
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return TodoModel.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating user todo: $e');
      }
    }
    return null;
  }

  /// 更新用户待办事项
  static Future<bool> updateUserTodo(TodoModel todoData) async {
    try {
      final response = await ApiClient.put('/User/todos', body: todoData.toJson());
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user todo: $e');
      }
    }
    return false;
  }

  /// 删除用户待办事项
  static Future<bool> deleteUserTodo(String id) async {
    try {
      final response = await ApiClient.delete('/User/todos/$id');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting user todo: $e');
      }
    }
    return false;
  }

  /// 获取特定待办事项
  static Future<TodoModel?> getTodoById(String id) async {
    try {
      final response = await ApiClient.get('/User/todos/$id');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return TodoModel.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching todo by id: $e');
      }
    }
    return null;
  }

  /// 更新用户资料
  static Future<bool> updateUserProfile(StudentModel profileData) async {
    try {
      final response = await ApiClient.put('/User/profile', body: profileData.toJson());
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user profile: $e');
      }
    }
    return false;
  }
}