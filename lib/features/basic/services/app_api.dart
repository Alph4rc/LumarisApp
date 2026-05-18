import 'dart:convert';

import 'package:ios_club_app/features/basic/services/basic_http_client_manager.dart';
import 'package:ios_club_app/features/education/models/release_info.dart';

class AppApi {
  static Future<List<ReleaseInfo>> getAppInfo() async {
    try {
      final response = await BasicHttpClientManager.instance.get('/api/v1/App/GetTag');

      final List<dynamic> dataList;

      if (response is String) {
        dataList = jsonDecode(response) as List<dynamic>;
      } else if (response is List) {
        dataList = response;
      } else if (response is Map) {
        dataList = [response];
      } else {
        throw FormatException("Unexpected response type");
      }

      return dataList.map((e) => ReleaseInfo.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      rethrow;
    }
  }
}