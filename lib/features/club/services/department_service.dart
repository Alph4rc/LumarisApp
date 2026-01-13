import 'package:flutter/foundation.dart';
import 'package:ios_club_app/features/club/services/api_client.dart';
import 'package:ios_club_app/features/club/models/department_model.dart';
import 'package:ios_club_app/features/club/utils/api_response_helper.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

class DepartmentService {
  /// 根据名称获取部门
  static Future<DepartmentModel?> getDepartmentByName(String name) async {
    try {
      final response = await ApiClient.get('/Department/$name');
      return await ApiResponseHelper.parseSingleObject(
        response,
        DepartmentModel.fromJson,
        errorMessage: 'Error fetching department by name',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching department by name: $e');
      }
      return null;
    }
  }

  /// 获取所有部门
  static Future<List<DepartmentModel>?> getAllDepartments() async {
    try {
      final response = await ApiClient.get('/Department/all');
      return await ApiResponseHelper.parseList(
        response,
        DepartmentModel.fromJson,
        errorMessage: 'Error fetching all departments',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching all departments: $e');
      }
      return null;
    }
  }

  /// 更新部门
  static Future<bool> updateDepartment(DepartmentModel departmentData) async {
    try {
      final response = await ApiClient.post('/Department/Update', body: departmentData.toJson());
      return await ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error updating department',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error updating department: $e');
      }
      return false;
    }
  }

  /// 创建部门
  static Future<bool> createDepartment(DepartmentModel departmentData) async {
    try {
      final response = await ApiClient.post('/Department/Create', body: departmentData.toJson());
      return await ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error creating department',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error creating department: $e');
      }
      return false;
    }
  }

  /// 删除部门
  static Future<bool> deleteDepartment(String name) async {
    try {
      final response = await ApiClient.get('/Department/Delete/$name');
      return await ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error deleting department',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error deleting department: $e');
      }
      return false;
    }
  }

  /// 导出部门JSON数据
  static Future<bool> exportDepartmentsToJson() async {
    try {
      final response = await ApiClient.get('/Department/export-json');
      return await ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error exporting departments to JSON',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error exporting departments to JSON: $e');
      }
      return false;
    }
  }
}