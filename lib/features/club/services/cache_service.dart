import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ios_club_app/features/club/services/api_client.dart';

/// 缓存服务类
///
/// 负责处理服务器端缓存的清理操作
class CacheService {
  /// 清理缓存
  ///
  /// 清理服务器端的缓存数据
  /// @return 清理成功返回消息，失败返回null
  static Future<String?> cleanCache() async {
    try {
      final response = await ApiClient.get('/clean');
      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = jsonDecode(response.body);
        return apiResponse['data'];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning cache: $e');
      }
    }
    return null;
  }
}
