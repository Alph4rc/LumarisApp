import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ios_club_app/features/club/services/api_client.dart';

/// 监控服务类
///
/// 负责处理系统性能监控、HTTP统计和数据访问统计等功能
class MonitoringService {
  /// 获取性能监控数据
  ///
  /// @return 性能监控数据
  static Future<Map<String, dynamic>?> getPerformance() async {
    try {
      final response = await ApiClient.get('/Monitoring/performance');
      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = jsonDecode(response.body);
        return apiResponse['data'];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching performance data: $e');
      }
    }
    return null;
  }

  /// 获取HTTP统计数据
  ///
  /// @return HTTP请求统计数据
  static Future<Map<String, dynamic>?> getHttpStats() async {
    try {
      final response = await ApiClient.get('/Monitoring/http-stats');
      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = jsonDecode(response.body);
        return apiResponse['data'];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching HTTP stats: $e');
      }
    }
    return null;
  }

  /// 获取数据访问统计
  ///
  /// @param entityType 实体类型（可选）
  /// @param top 返回前N条记录（默认为10）
  /// @return 数据访问统计信息
  static Future<Map<String, dynamic>?> getDataAccessStats({
    String? entityType,
    int top = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'top': top.toString(),
      };

      if (entityType != null && entityType.isNotEmpty) {
        queryParams['entityType'] = entityType;
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await ApiClient.get('/Monitoring/data-access-stats?$queryString');
      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = jsonDecode(response.body);
        return apiResponse['data'];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data access stats: $e');
      }
    }
    return null;
  }

  /// 获取数据变更统计
  ///
  /// @param entityType 实体类型（可选）
  /// @param top 返回前N条记录（默认为10）
  /// @return 数据变更统计信息
  static Future<Map<String, dynamic>?> getDataChangeStats({
    String? entityType,
    int top = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'top': top.toString(),
      };

      if (entityType != null && entityType.isNotEmpty) {
        queryParams['entityType'] = entityType;
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await ApiClient.get('/Monitoring/data-change-stats?$queryString');
      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = jsonDecode(response.body);
        return apiResponse['data'];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data change stats: $e');
      }
    }
    return null;
  }

  /// 重置数据统计
  ///
  /// @param entityType 实体类型（可选）
  /// @return 重置成功返回true，失败返回false
  static Future<bool> resetDataStats({String? entityType}) async {
    try {
      final queryString = entityType != null && entityType.isNotEmpty
          ? '?entityType=${Uri.encodeComponent(entityType)}'
          : '';

      final response = await ApiClient.post('/Monitoring/reset-data-stats$queryString');
      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = jsonDecode(response.body);
        return apiResponse['data'] ?? false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting data stats: $e');
      }
    }
    return false;
  }
}
