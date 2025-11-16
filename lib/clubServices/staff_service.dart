import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ios_club_app/clubServices/api_client.dart';
import 'package:ios_club_app/clubModels/staff_model.dart';
import 'package:ios_club_app/clubModels/member_model.dart';

class StaffService {
  /// 获取所有员工
  static Future<List<StaffModel>?> getAllStaff() async {
    try {
      final response = await ApiClient.get('/Staff');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => StaffModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching all staff: $e');
      }
    }
    return null;
  }

  /// 获取员工成员
  static Future<List<MemberModel>?> getStaffMembers() async {
    try {
      final response = await ApiClient.get('/Staff/members');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => MemberModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching staff members: $e');
      }
    }
    return null;
  }

  /// 根据用户ID获取员工
  static Future<StaffModel?> getStaffByUserId(String userId) async {
    try {
      final response = await ApiClient.get('/Staff/$userId');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return StaffModel.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching staff by user ID: $e');
      }
    }
    return null;
  }

  /// 创建员工
  static Future<bool> createStaff(StaffModel staffData) async {
    try {
      final response = await ApiClient.post('/Staff/Create', body: staffData.toJson());
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating staff: $e');
      }
    }
    return false;
  }

  /// 更新员工
  static Future<bool> updateStaff(StaffModel staffData) async {
    try {
      final response = await ApiClient.post('/Staff/Update', body: staffData.toJson());
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating staff: $e');
      }
    }
    return false;
  }

  /// 删除员工
  static Future<bool> deleteStaff(String userId) async {
    try {
      final response = await ApiClient.get('/Staff/Delete/$userId');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting staff: $e');
      }
    }
    return false;
  }

  /// 根据身份获取员工
  static Future<List<StaffModel>?> getStaffByIdentity(String identity) async {
    try {
      final response = await ApiClient.get('/Staff/by-identity/$identity');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => StaffModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching staff by identity: $e');
      }
    }
    return null;
  }

  /// 更改员工部门
  static Future<bool> changeStaffDepartment(String userId, String departmentName) async {
    try {
      final response = await ApiClient.post('/Staff/change-department/$userId?departmentName=$departmentName');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error changing staff department: $e');
      }
    }
    return false;
  }
}