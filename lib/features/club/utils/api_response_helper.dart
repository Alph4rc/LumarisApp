import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ios_club_app/features/club/models/api_response.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

/// API 响应辅助工具类
///
/// 提供便捷的方法来解析和处理 API 响应
/// 支持 Dio 返回的动态数据类型
class ApiResponseHelper {
  /// 解析单个对象的响应
  ///
  /// [data] API 响应数据（可以是 Map 或 JSON 字符串）
  /// [fromJson] 将 JSON 转换为对象的函数
  /// [errorMessage] 自定义错误消息前缀
  static T? parseSingleObject<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson, {
    String errorMessage = 'Error parsing response',
  }) {
    try {
      final jsonData = _ensureMap(data);
      if (jsonData == null) return null;

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(jsonData);

      if (apiResponse.isSuccess && apiResponse.data != null) {
        return fromJson(apiResponse.data!);
      } else {
        if (kDebugMode) {
          AppLogger.error('$errorMessage: ${apiResponse.errorMessage}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('$errorMessage: $e');
      }
    }
    return null;
  }

  /// 解析对象列表的响应
  ///
  /// [data] API 响应数据（可以是 Map 或 JSON 字符串）
  /// [fromJson] 将 JSON 转换为对象的函数
  /// [errorMessage] 自定义错误消息前缀
  static List<T>? parseList<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson, {
    String errorMessage = 'Error parsing response',
  }) {
    try {
      final jsonData = _ensureMap(data);
      if (jsonData == null) return null;

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(jsonData);

      if (apiResponse.isSuccess && apiResponse.data != null) {
        return apiResponse.data!
            .map((e) => fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        if (kDebugMode) {
          AppLogger.error('$errorMessage: ${apiResponse.errorMessage}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('$errorMessage: $e');
      }
    }
    return null;
  }

  /// 解析字符串响应
  ///
  /// [data] API 响应数据（可以是 Map 或 JSON 字符串）
  /// [errorMessage] 自定义错误消息前缀
  static String? parseString(
    dynamic data, {
    String errorMessage = 'Error parsing response',
  }) {
    try {
      final jsonData = _ensureMap(data);
      if (jsonData == null) return null;

      final apiResponse = ApiResponse<String>.fromJson(jsonData);

      if (apiResponse.isSuccess) {
        return apiResponse.data;
      } else {
        if (kDebugMode) {
          AppLogger.error('$errorMessage: ${apiResponse.errorMessage}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('$errorMessage: $e');
      }
    }
    return null;
  }

  /// 解析布尔值响应
  ///
  /// [data] API 响应数据（可以是 Map 或 JSON 字符串）
  /// [errorMessage] 自定义错误消息前缀
  static bool parseBool(
    dynamic data, {
    String errorMessage = 'Error parsing response',
  }) {
    try {
      final jsonData = _ensureMap(data);
      if (jsonData == null) return false;

      final apiResponse = ApiResponse<bool>.fromJson(jsonData);

      if (apiResponse.isSuccess) {
        return apiResponse.data ?? false;
      } else {
        if (kDebugMode) {
          AppLogger.error('$errorMessage: ${apiResponse.errorMessage}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('$errorMessage: $e');
      }
    }
    return false;
  }

  /// 解析原始数据响应(不做类型转换)
  ///
  /// [data] API 响应数据（可以是 Map 或 JSON 字符串）
  /// [errorMessage] 自定义错误消息前缀
  static T? parseRaw<T>(
    dynamic data, {
    String errorMessage = 'Error parsing response',
  }) {
    try {
      final jsonData = _ensureMap(data);
      if (jsonData == null) return null;

      final apiResponse = ApiResponse<T>.fromJson(jsonData);

      if (apiResponse.isSuccess) {
        return apiResponse.data;
      } else {
        if (kDebugMode) {
          AppLogger.error('$errorMessage: ${apiResponse.errorMessage}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('$errorMessage: $e');
      }
    }
    return null;
  }

  /// 获取完整的 ApiResponse 对象
  ///
  /// [data] API 响应数据（可以是 Map 或 JSON 字符串）
  /// [fromJsonT] 可选的数据转换函数
  static ApiResponse<T>? getApiResponse<T>(
    dynamic data, {
    T Function(dynamic)? fromJsonT,
  }) {
    try {
      final jsonData = _ensureMap(data);
      if (jsonData == null) return null;

      return ApiResponse<T>.fromJson(
        jsonData,
        fromJsonT: fromJsonT,
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error getting ApiResponse: $e');
      }
    }
    return null;
  }

  /// 确保数据是 Map 类型
  static Map<String, dynamic>? _ensureMap(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      try {
        return jsonDecode(data) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }
}
