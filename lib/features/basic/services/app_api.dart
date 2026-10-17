import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:ios_club_app/features/basic/services/basic_http_client_manager.dart';
import 'package:ios_club_app/features/education/models/release_info.dart';

class AppApi {
  static Future<List<ReleaseInfo>> getAppInfo() async {
    final response = await BasicHttpClientManager.instance.get('/api/v1/app');
    return parseReleases(response);
  }

  /// 把版本接口的响应统一解析成 release 列表。
  ///
  /// 兼容三种线上形态：
  /// - 裸数组：`[{...}]`（Gitee Release 格式，1.2.2 及更早的约定）
  /// - 统一信封：`{code, message, data: {total, items: [{...}]}}`（Luminous）
  /// - 单条对象：`{...}`
  ///
  /// 后端改回裸数组后仍保留信封分支，避免以后响应格式调整再次让更新检查静默失效。
  @visibleForTesting
  static List<ReleaseInfo> parseReleases(dynamic response) {
    if (response is String) {
      return parseReleases(jsonDecode(response));
    }

    final List<dynamic> dataList;
    if (response is List) {
      dataList = response;
    } else if (response is Map) {
      final data = response['data'];
      if (data is Map && data['items'] is List) {
        dataList = data['items'] as List<dynamic>;
      } else if (data is List) {
        dataList = data;
      } else if (data is Map) {
        dataList = [data];
      } else {
        dataList = [response];
      }
    } else {
      throw const FormatException('Unexpected response type');
    }

    return dataList
        .map((e) => ReleaseInfo.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
