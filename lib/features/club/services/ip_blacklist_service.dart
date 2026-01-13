import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ios_club_app/features/club/services/api_client.dart';

/// IP黑名单服务类
///
/// 负责处理IP黑名单的管理，包括添加、移除、检查和统计功能
class IpBlacklistService {
  /// 获取黑名单统计信息
  ///
  /// @return 黑名单统计数据
  static Future<Map<String, dynamic>?> getStats() async {
    try {
      final response = await ApiClient.get('/IpBlacklist/stats');
      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = jsonDecode(response.body);
        return apiResponse['data'];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching blacklist stats: $e');
      }
    }
    return null;
  }

  /// 添加IP到黑名单
  ///
  /// @param ip IP地址
  /// @param reason 添加原因（可选）
  /// @return 添加成功返回消息，失败返回null
  static Future<String?> addIp(String ip, {String? reason}) async {
    try {
      final body = <String, dynamic>{
        'ip': ip,
      };
      if (reason != null && reason.isNotEmpty) {
        body['reason'] = reason;
      }

      final response = await ApiClient.post('/IpBlacklist/add', body: body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = jsonDecode(response.body);
        return apiResponse['data'];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding IP to blacklist: $e');
      }
    }
    return null;
  }

  /// 从黑名单移除IP
  ///
  /// @param ip IP地址
  /// @param reason 移除原因（可选）
  /// @return 移除成功返回消息，失败返回null
  static Future<String?> removeIp(String ip, {String? reason}) async {
    try {
      final body = <String, dynamic>{
        'ip': ip,
      };
      if (reason != null && reason.isNotEmpty) {
        body['reason'] = reason;
      }

      final response = await ApiClient.post('/IpBlacklist/remove', body: body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = jsonDecode(response.body);
        return apiResponse['data'];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing IP from blacklist: $e');
      }
    }
    return null;
  }

  /// 刷新黑名单
  ///
  /// @return 刷新成功返回消息，失败返回null
  static Future<String?> refresh() async {
    try {
      final response = await ApiClient.post('/IpBlacklist/refresh');
      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = jsonDecode(response.body);
        return apiResponse['data'];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing blacklist: $e');
      }
    }
    return null;
  }

  /// 检查IP是否在黑名单中
  ///
  /// @param ip IP地址
  /// @return IP检查结果
  static Future<Map<String, dynamic>?> checkIp(String ip) async {
    try {
      final response = await ApiClient.get('/IpBlacklist/check/$ip');
      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = jsonDecode(response.body);
        return apiResponse['data'];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking IP: $e');
      }
    }
    return null;
  }
}
