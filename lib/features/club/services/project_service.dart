import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ios_club_app/features/club/services/api_client.dart';
import 'package:ios_club_app/features/club/models/project_model.dart';

class ProjectService {
  /// 获取所有项目
  static Future<List<ProjectModel>?> getAllProjects() async {
    try {
      final response = await ApiClient.get('/Project');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => ProjectModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching all projects: $e');
      }
    }
    return null;
  }

  /// 创建项目
  static Future<ProjectModel?> createProject(ProjectModel projectData) async {
    try {
      final response = await ApiClient.post('/Project', body: projectData.toJson());
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ProjectModel.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating project: $e');
      }
    }
    return null;
  }

  /// 获取用户项目
  static Future<List<ProjectModel>?> getUserProjects() async {
    try {
      final response = await ApiClient.get('/Project/your-projects');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => ProjectModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user projects: $e');
      }
    }
    return null;
  }

  /// 删除项目
  static Future<bool> deleteProject(String id) async {
    try {
      final response = await ApiClient.post('/Project/delete/$id');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting project: $e');
      }
    }
    return false;
  }

  /// 更改项目成员
  static Future<bool> changeProjectMember(String id, String projId) async {
    try {
      final response = await ApiClient.post('/Project/change-member/$id/$projId');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error changing project member: $e');
      }
    }
    return false;
  }
}