import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ios_club_app/features/club/services/api_client.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

/// 日志服务类
///
/// 负责处理系统日志的查询、统计和清理操作
class LogsService {
  /// 获取日志列表
  ///
  /// @param pageIndex 页码（默认为1）
  /// @param pageSize 每页大小（默认为10）
  /// @param searchTerm 搜索关键词（可选）
  /// @param levelFilter 日志级别过滤（可选）
  /// @param timeRange 时间范围（可选）
  /// @return 分页的日志数据
  static Future<Map<String, dynamic>?> getLogs({
    int pageIndex = 1,
    int pageSize = 10,
    String? searchTerm,
    String? levelFilter,
    String? timeRange,
  }) async {
    try {
      final queryParams = <String, String>{
        'pageIndex': pageIndex.toString(),
        'pageSize': pageSize.toString(),
      };

      if (searchTerm != null && searchTerm.isNotEmpty) {
        queryParams['searchTerm'] = searchTerm;
      }
      if (levelFilter != null && levelFilter.isNotEmpty) {
        queryParams['levelFilter'] = levelFilter;
      }
      if (timeRange != null && timeRange.isNotEmpty) {
        queryParams['timeRange'] = timeRange;
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await ApiClient.get('/Logs?$queryString');
      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = jsonDecode(response.body);
        return apiResponse['data'];
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching logs: $e');
      }
    }
    return null;
  }

  /// 获取日志统计信息
  ///
  /// @return 日志统计数据，包括总数和各级别的数量
  static Future<Map<String, dynamic>?> getStatistics() async {
    try {
      final response = await ApiClient.get('/Logs/statistics');
      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = jsonDecode(response.body);
        return apiResponse['data'];
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching log statistics: $e');
      }
    }
    return null;
  }

  /// 清理旧日志
  ///
  /// @param days 保留最近多少天的日志（默认为7天）
  /// @return 清理成功返回结果信息
  static Future<Map<String, dynamic>?> cleanupLogs({int days = 7}) async {
    try {
      final response = await ApiClient.post('/Logs/cleanup?days=$days');
      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = jsonDecode(response.body);
        return apiResponse['data'];
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error cleaning up logs: $e');
      }
    }
    return null;
  }

  /// 获取日志分布
  ///
  /// @param timeRange 时间范围（默认为"today"）
  /// @return 日志分布数据
  static Future<List<dynamic>?> getDistribution({String timeRange = 'today'}) async {
    try {
      final response = await ApiClient.get('/Logs/distribution?timeRange=$timeRange');
      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = jsonDecode(response.body);
        return apiResponse['data'];
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching log distribution: $e');
      }
    }
    return null;
  }
}
