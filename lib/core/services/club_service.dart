import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:ios_club_app/features/club/services/staff_service.dart';
import 'package:ios_club_app/features/club/models/member_model.dart';
import 'package:ios_club_app/core/models/member_info.dart';
import 'package:ios_club_app/core/services/gzip_service.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

import 'package:ios_club_app/core/models/link_model.dart';
import 'package:ios_club_app/core/services/base_http_client.dart';

import 'package:ios_club_app/features/club/services/auth_service.dart';
import 'package:ios_club_app/features/club/services/user_service.dart';
import 'package:ios_club_app/features/club/services/member_query_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

/// 俱乐部服务类 - 为向后兼容而保留的接口
/// 新代码应直接使用 clubServices 目录下的模块化服务
class ClubService {
  static final BaseHttpClient _client = BaseHttpClient(
    baseUrl: 'https://link.xauat.site',
    enableCache: true,
  );

  /// 获取链接分类
  static Future<List<CategoryModel>> getLinks() async {
    final List<CategoryModel> list = [];
    try {
      final response = await _client.get('/Category');

      if (response is List) {
        for (var item in response) {
          list.add(CategoryModel.fromJson(item));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching data: $e');
      }
    }

    list.sort((a, b) => a.index.compareTo(b.index));
    return list;
  }

  /// 成员登录
  /// 推荐使用 AuthService.login
  static Future<bool> loginMember(String username, String password) async {
    return await AuthService.login(username, password) != null;
  }

  /// 获取成员信息
  /// 推荐使用 UserService.getUserData
  static Future<MemberInfo> getMemberInfo() async {
    final prefs = PrefsService.instance;
    Map<String, dynamic> memberData = {};
    try {
      final memberDataString = prefs.getString(PrefsKeys.MEMBER_DATA);
      memberData = jsonDecode(memberDataString ?? '{}');
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching data: $e');
      }
      prefs.setString(PrefsKeys.MEMBER_DATA, '');
      return MemberInfo(memberData: {}, info: null);
    }

    final userData = await UserService.getUserData();

    return MemberInfo(
      memberData: memberData,
      info: userData,
    );
  }

  /// 分页获取成员
  /// 推荐使用 MemberQueryService.getMemberDataByPage
  static Future<MemberData> getMembersByPage(int pageNum, int pageSize) async {
    try {
      final result = await MemberQueryService.getMemberDataByPage(
        pageNum: pageNum,
        pageSize: pageSize,
      );

      if (result != null) {
        final decompressed = await GzipService.decompress(result);
        return MemberData.fromJson(jsonDecode(decompressed));
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching members by page: $e');
      }
    }

    return MemberData(
      data: [],
      totalCount: 0,
      totalPages: 0,
    );
  }

  /// 分页获取员工
  /// 推荐使用 StaffService.getStaffMembers
  static Future<MemberData> getStaffsByPage(int pageNum, int pageSize) async {
    try {
      final staffMembers = await StaffService.getStaffMembers();
      if (staffMembers != null) {
        return MemberData(
          data: staffMembers.toList(),
          totalCount: staffMembers.length,
          totalPages: 1,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching staffs by page: $e');
      }
    }

    return MemberData(
      data: [],
      totalCount: 0,
      totalPages: 0,
    );
  }

  /// 更改密码
  /// 推荐使用 AuthService.changePassword
  static Future<bool> changePassword(
      String userId, String oldPassword, String newPassword) async {
    return await AuthService.changePassword(userId, oldPassword, newPassword);
  }

  /// 获取所有成员数据
  /// 推荐使用 MemberQueryService.getAllMemberData
  static Future<List<MemberModel>> getAllMemberData() async {
    try {
      final result = await MemberQueryService.getAllMemberData();
      if (result != null) {
        final List<dynamic> jsonData = jsonDecode(result);
        return jsonData.map((e) => MemberModel.fromJson(e)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching all member data: $e');
      }
    }
    return [];
  }

  /// 验证用户
  /// 推荐使用 AuthService.validate
  static Future<bool> validateUser(String userId) async {
    return await AuthService.validate(userId);
  }
}
