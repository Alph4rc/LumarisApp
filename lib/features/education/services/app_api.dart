import 'dart:convert';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/education/models/release_info.dart';
import '../../../core/services/network_exception.dart';
import 'edu_http_client_manager.dart';

/// App相关API
class AppApi {
  /// 获取App相关信息
  static Future<List<ReleaseInfo>> getAppInfo() async {
    try {
      final response = await EduHttpClientManager.instance.get('/App/GetTag');

      final List<dynamic> dataList;

      if (response is String) {
        dataList = jsonDecode(response) as List<dynamic>;
      } else if (response is List) {
        dataList = response;
      } else if (response is Map) {
        // 如果返回的是单个对象，也包装成列表
        dataList = [response];
      } else {
        throw NetworkException('返回数据格式错误', -1);
      }

      return dataList
          .map(
            (item) =>
                ReleaseInfo.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (e) {
      AppLogger.debug(e);
      rethrow;
    }
  }
}
