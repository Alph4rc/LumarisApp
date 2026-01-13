import 'package:flutter/foundation.dart';
import 'package:ios_club_app/features/club/services/api_client.dart';
import 'package:ios_club_app/features/club/models/project_model.dart';
import 'package:ios_club_app/features/club/utils/api_response_helper.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

class ProjectService {
  /// 获取所有项目
  static Future<List<ProjectModel>?> getAllProjects() async {
    try {
      final response = await ApiClient.get('/Project');
      return await ApiResponseHelper.parseList(
        response,
        ProjectModel.fromJson,
        errorMessage: 'Error fetching all projects',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching all projects: $e');
      }
      return null;
    }
  }

  /// 创建项目
  static Future<ProjectModel?> createProject(ProjectModel projectData) async {
    try {
      final response = await ApiClient.post('/Project', body: projectData.toJson());
      return await ApiResponseHelper.parseSingleObject(
        response,
        ProjectModel.fromJson,
        errorMessage: 'Error creating project',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error creating project: $e');
      }
      return null;
    }
  }

  /// 获取用户项目
  static Future<List<ProjectModel>?> getUserProjects() async {
    try {
      final response = await ApiClient.get('/Project/your-projects');
      return await ApiResponseHelper.parseList(
        response,
        ProjectModel.fromJson,
        errorMessage: 'Error fetching user projects',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching user projects: $e');
      }
      return null;
    }
  }

  /// 删除项目
  static Future<bool> deleteProject(String id) async {
    try {
      final response = await ApiClient.post('/Project/delete/$id');
      return await ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error deleting project',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error deleting project: $e');
      }
      return false;
    }
  }

  /// 更改项目成员
  static Future<bool> changeProjectMember(String id, String projId) async {
    try {
      final response = await ApiClient.post('/Project/change-member/$id/$projId');
      return await ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error changing project member',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error changing project member: $e');
      }
      return false;
    }
  }
}