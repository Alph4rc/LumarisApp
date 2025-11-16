import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ios_club_app/clubServices/api_client.dart';

class InfoService {
  /// 获取学院信息
  static Future<List<String>?> getAcademies() async {
    try {
      final response = await ApiClient.get('/Info/academies');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e as String).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching academies: $e');
      }
    }
    return null;
  }

  /// 获取用户信息
  static Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final response = await ApiClient.get('/Info/user-info');
      if (response.statusCode == 200) {
        // 根据API文档，这个端点没有指定返回格式，所以直接返回body
        return {'data': response.body};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user info: $e');
      }
    }
    return null;
  }
}