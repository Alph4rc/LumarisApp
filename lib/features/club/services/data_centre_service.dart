import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ios_club_app/features/club/models/data_centre_model.dart';
import 'package:ios_club_app/features/club/services/api_client.dart';
import 'package:ios_club_app/features/club/models/year_count.dart';
import 'package:ios_club_app/features/club/models/academy_count.dart';
import 'package:ios_club_app/features/club/models/landscape_count.dart';
import 'package:ios_club_app/features/club/models/gender_count.dart';

class DataCentreService {
  /// 获取年份统计
  static Future<List<YearCount>?> getYearStatistics() async {
    try {
      final response = await ApiClient.get('/DataCentre/year');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => YearCount.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching year statistics: $e');
      }
    }
    return null;
  }

  /// 获取学院统计
  static Future<List<AcademyCount>?> getAcademyStatistics() async {
    try {
      final response = await ApiClient.get('/DataCentre/college');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => AcademyCount.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching academy statistics: $e');
      }
    }
    return null;
  }

  /// 获取年级统计
  static Future<List<LandscapeCount>?> getGradeStatistics() async {
    try {
      final response = await ApiClient.get('/DataCentre/grade');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => LandscapeCount.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching grade statistics: $e');
      }
    }
    return null;
  }

  /// 获取政治面貌统计
  static Future<List<LandscapeCount>?> getLandscapeStatistics() async {
    try {
      final response = await ApiClient.get('/DataCentre/landscape');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => LandscapeCount.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching landscape statistics: $e');
      }
    }
    return null;
  }

  /// 获取性别统计
  static Future<List<GenderCount>?> getGenderStatistics() async {
    try {
      final response = await ApiClient.get('/DataCentre/gender');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => GenderCount.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching gender statistics: $e');
      }
    }
    return null;
  }

  /// 从JSON更新数据
  static Future<bool> updateFromJson(String filePath) async {
    // 注意：这个端点需要multipart/form-data，这里只是一个占位符实现
    try {
      final response = await ApiClient.post('/DataCentre/update-from-json');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating from JSON: $e');
      }
    }
    return false;
  }

  /// 获取数据
  static Future<DataCentreModel?> getData() async {
    try {
      final response = await ApiClient.get('/DataCentre');
      if (response.statusCode == 200) {
        return DataCentreModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting data: $e');
      }
    }
    return null;
  }

  /// 导出JSON
  static Future<bool> exportToJson() async {
    try {
      final response = await ApiClient.get('/DataCentre/export-json');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error exporting to JSON: $e');
      }
    }
    return false;
  }

  /// 清理数据
  static Future<bool> cleanData() async {
    try {
      final response = await ApiClient.get('/DataCentre/clean');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning data: $e');
      }
    }
    return false;
  }
}