import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ios_club_app/clubServices/api_client.dart';
import 'package:ios_club_app/clubModels/student_model.dart';
import 'package:ios_club_app/clubModels/reset_password_data.dart';

class MemberManagementService {
  /// 删除成员
  static Future<bool> deleteMember(String id) async {
    try {
      final response = await ApiClient.post('/MemberManagement/delete/$id');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting member: $e');
      }
    }
    return false;
  }

  /// 批量更新成员
  static Future<bool> updateManyMembers(List<StudentModel> membersData) async {
    try {
      final List<Map<String, dynamic>> jsonData = membersData.map((e) => e.toJson()).toList();
      final response = await ApiClient.post('/MemberManagement/update-many', body: jsonData);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating many members: $e');
      }
    }
    return false;
  }

  /// 更新成员
  static Future<bool> updateMember(StudentModel memberData) async {
    try {
      final response = await ApiClient.post('/MemberManagement/update', body: memberData.toJson());
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating member: $e');
      }
    }
    return false;
  }

  /// 重置密码
  static Future<bool> resetPassword(ResetPasswordData resetData) async {
    try {
      final response = await ApiClient.post('/MemberManagement/reset-password', body: resetData.toJson());
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting password: $e');
      }
    }
    return false;
  }
}