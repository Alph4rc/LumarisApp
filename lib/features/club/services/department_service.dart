import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ios_club_app/features/club/services/api_client.dart';
import 'package:ios_club_app/features/club/models/department_model.dart';

class DepartmentService {
  /// 根据名称获取部门
  static Future<DepartmentModel?> getDepartmentByName(String name) async {
    try {
      final response = await ApiClient.get('/Department/$name');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return DepartmentModel.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching department by name: $e');
      }
    }
    return null;
  }

  /// 获取所有部门
  static Future<List<DepartmentModel>?> getAllDepartments() async {
    try {
      final response = await ApiClient.get('/Department/all');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => DepartmentModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching all departments: $e');
      }
    }
    return null;
  }

  /// 更新部门
  static Future<bool> updateDepartment(DepartmentModel departmentData) async {
    try {
      final response = await ApiClient.post('/Department/Update', body: departmentData.toJson());
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating department: $e');
      }
    }
    return false;
  }

  /// 创建部门
  static Future<bool> createDepartment(DepartmentModel departmentData) async {
    try {
      final response = await ApiClient.post('/Department/Create', body: departmentData.toJson());
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating department: $e');
      }
    }
    return false;
  }

  /// 删除部门
  static Future<bool> deleteDepartment(String name) async {
    try {
      final response = await ApiClient.get('/Department/Delete/$name');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting department: $e');
      }
    }
    return false;
  }

  /// 导出部门JSON数据
  static Future<bool> exportDepartmentsToJson() async {
    try {
      final response = await ApiClient.get('/Department/export-json');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error exporting departments to JSON: $e');
      }
    }
    return false;
  }
}