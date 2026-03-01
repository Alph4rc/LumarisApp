import 'package:flutter/foundation.dart';
import 'package:ios_club_app/features/club/services/api_client.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

class MemberQueryService {
  /// 获取所有成员数据
  static Future<String?> getAllMemberData() async {
    try {
      final response = await ApiClient.get('/MemberQuery/all-data');
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching all member data: $e');
      }
    }
    return null;
  }

  /// 分页获取成员数据
  static Future<String?> getMemberDataByPage({
    int pageNum = 1,
    int pageSize = 10,
    String? searchTerm,
    String? searchCondition,
  }) async {
    try {
      var url =
          '/MemberQuery/all-data/page?pageNum=$pageNum&pageSize=$pageSize';
      if (searchTerm != null) {
        url += '&searchTerm=$searchTerm';
      }
      if (searchCondition != null) {
        url += '&searchCondition=$searchCondition';
      }

      final response = await ApiClient.get(url);
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching member data by page: $e');
      }
    }
    return null;
  }

  /// 搜索成员数据
  static Future<bool> searchMemberData(
      String searchTerm, String searchCondition) async {
    try {
      final response = await ApiClient.get(
          '/MemberQuery/all-data/search?searchTerm=$searchTerm&searchCondition=$searchCondition');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error searching member data: $e');
      }
    }
    return false;
  }
}
