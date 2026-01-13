import 'package:flutter/foundation.dart';
import 'package:ios_club_app/features/club/models/data_centre_model.dart';
import 'package:ios_club_app/features/club/services/api_client.dart';
import 'package:ios_club_app/features/club/models/year_count.dart';
import 'package:ios_club_app/features/club/models/academy_count.dart';
import 'package:ios_club_app/features/club/models/landscape_count.dart';
import 'package:ios_club_app/features/club/models/gender_count.dart';
import 'package:ios_club_app/features/club/utils/api_response_helper.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

class DataCentreService {
  /// 获取年份统计
  static Future<List<YearCount>?> getYearStatistics() async {
    try {
      final response = await ApiClient.get('/DataCentre/year');
      return await ApiResponseHelper.parseList(
        response,
        YearCount.fromJson,
        errorMessage: 'Error fetching year statistics',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching year statistics: $e');
      }
      return null;
    }
  }

  /// 获取学院统计
  static Future<List<AcademyCount>?> getAcademyStatistics() async {
    try {
      final response = await ApiClient.get('/DataCentre/college');
      return await ApiResponseHelper.parseList(
        response,
        AcademyCount.fromJson,
        errorMessage: 'Error fetching academy statistics',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching academy statistics: $e');
      }
      return null;
    }
  }

  /// 获取年级统计
  static Future<List<LandscapeCount>?> getGradeStatistics() async {
    try {
      final response = await ApiClient.get('/DataCentre/grade');
      return await ApiResponseHelper.parseList(
        response,
        LandscapeCount.fromJson,
        errorMessage: 'Error fetching grade statistics',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching grade statistics: $e');
      }
      return null;
    }
  }

  /// 获取政治面貌统计
  static Future<List<LandscapeCount>?> getLandscapeStatistics() async {
    try {
      final response = await ApiClient.get('/DataCentre/landscape');
      return await ApiResponseHelper.parseList(
        response,
        LandscapeCount.fromJson,
        errorMessage: 'Error fetching landscape statistics',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching landscape statistics: $e');
      }
      return null;
    }
  }

  /// 获取性别统计
  static Future<List<GenderCount>?> getGenderStatistics() async {
    try {
      final response = await ApiClient.get('/DataCentre/gender');
      return await ApiResponseHelper.parseList(
        response,
        GenderCount.fromJson,
        errorMessage: 'Error fetching gender statistics',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching gender statistics: $e');
      }
      return null;
    }
  }

  /// 从JSON更新数据
  static Future<bool> updateFromJson(String filePath) async {
    // 注意：这个端点需要multipart/form-data，这里只是一个占位符实现
    try {
      final response = await ApiClient.post('/DataCentre/update-from-json');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error updating from JSON: $e');
      }
    }
    return false;
  }

  /// 获取数据
  static Future<DataCentreModel?> getData() async {
    try {
      final response = await ApiClient.get('/DataCentre');
      return await ApiResponseHelper.parseSingleObject(
        response,
        DataCentreModel.fromJson,
        errorMessage: 'Error getting data',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error getting data: $e');
      }
      return null;
    }
  }

  /// 导出JSON
  static Future<bool> exportToJson() async {
    try {
      final response = await ApiClient.get('/DataCentre/export-json');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error exporting to JSON: $e');
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
        AppLogger.error('Error cleaning data: $e');
      }
    }
    return false;
  }
}