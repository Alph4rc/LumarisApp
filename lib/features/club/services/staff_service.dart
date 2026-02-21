import 'package:flutter/foundation.dart';
import 'package:ios_club_app/features/club/services/api_client.dart';
import 'package:ios_club_app/features/club/models/staff_model.dart';
import 'package:ios_club_app/features/club/models/member_model.dart';
import 'package:ios_club_app/features/club/utils/api_response_helper.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

class StaffService {
  /// 获取所有员工
  static Future<List<StaffModel>?> getAllStaff() async {
    try {
      final response = await ApiClient.get('/Staff');
      return ApiResponseHelper.parseList(
        response,
        StaffModel.fromJson,
        errorMessage: 'Error fetching all staff',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching all staff: $e');
      }
      return null;
    }
  }

  /// 获取员工成员
  static Future<List<MemberModel>?> getStaffMembers() async {
    try {
      final response = await ApiClient.get('/Staff/members');
      return ApiResponseHelper.parseList(
        response,
        MemberModel.fromJson,
        errorMessage: 'Error fetching staff members',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching staff members: $e');
      }
      return null;
    }
  }

  /// 根据用户ID获取员工
  static Future<StaffModel?> getStaffByUserId(String userId) async {
    try {
      final response = await ApiClient.get('/Staff/$userId');
      return ApiResponseHelper.parseSingleObject(
        response,
        StaffModel.fromJson,
        errorMessage: 'Error fetching staff by user ID',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching staff by user ID: $e');
      }
      return null;
    }
  }

  /// 创建员工
  static Future<bool> createStaff(StaffModel staffData) async {
    try {
      final response = await ApiClient.post('/Staff/Create', body: staffData.toJson());
      return ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error creating staff',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error creating staff: $e');
      }
      return false;
    }
  }

  /// 更新员工
  static Future<bool> updateStaff(StaffModel staffData) async {
    try {
      final response = await ApiClient.post('/Staff/Update', body: staffData.toJson());
      return ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error updating staff',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error updating staff: $e');
      }
      return false;
    }
  }

  /// 删除员工
  static Future<bool> deleteStaff(String userId) async {
    try {
      final response = await ApiClient.get('/Staff/Delete/$userId');
      return ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error deleting staff',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error deleting staff: $e');
      }
      return false;
    }
  }

  /// 根据身份获取员工
  static Future<List<StaffModel>?> getStaffByIdentity(String identity) async {
    try {
      final response = await ApiClient.get('/Staff/by-identity/$identity');
      return ApiResponseHelper.parseList(
        response,
        StaffModel.fromJson,
        errorMessage: 'Error fetching staff by identity',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching staff by identity: $e');
      }
      return null;
    }
  }

  /// 更改员工部门
  static Future<bool> changeStaffDepartment(String userId, String departmentName) async {
    try {
      final response = await ApiClient.post('/Staff/change-department/$userId?departmentName=$departmentName');
      return ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error changing staff department',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error changing staff department: $e');
      }
      return false;
    }
  }
}