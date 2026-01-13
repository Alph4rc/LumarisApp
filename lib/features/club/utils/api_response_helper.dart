import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ios_club_app/features/club/models/api_response.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

/// API 响应辅助工具类
///
/// 提供便捷的方法来解析和处理 API 响应
class ApiResponseHelper {
  /// 解析单个对象的响应
  ///
  /// [response] HTTP 响应
  /// [fromJson] 将 JSON 转换为对象的函数
  /// [errorMessage] 自定义错误消息前缀
  static Future<T?> parseSingleObject<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson, {
    String errorMessage = 'Error parsing response',
  }) async {
    try {
      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          jsonDecode(response.body),
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return fromJson(apiResponse.data!);
        } else {
          if (kDebugMode) {
            AppLogger.error('$errorMessage: ${apiResponse.errorMessage}');
          }
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
  /// [response] HTTP 响应
  /// [fromJson] 将 JSON 转换为对象的函数
  /// [errorMessage] 自定义错误消息前缀
  static Future<List<T>?> parseList<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson, {
    String errorMessage = 'Error parsing response',
  }) async {
    try {
      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<List<dynamic>>.fromJson(
          jsonDecode(response.body),
        );

        if (apiResponse.isSuccess && apiResponse.data != null) {
          return apiResponse.data!
              .map((e) => fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          if (kDebugMode) {
            AppLogger.error('$errorMessage: ${apiResponse.errorMessage}');
          }
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
  /// [response] HTTP 响应
  /// [errorMessage] 自定义错误消息前缀
  static Future<String?> parseString(
    http.Response response, {
    String errorMessage = 'Error parsing response',
  }) async {
    try {
      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<String>.fromJson(
          jsonDecode(response.body),
        );

        if (apiResponse.isSuccess) {
          return apiResponse.data;
        } else {
          if (kDebugMode) {
            AppLogger.error('$errorMessage: ${apiResponse.errorMessage}');
          }
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
  /// [response] HTTP 响应
  /// [errorMessage] 自定义错误消息前缀
  static Future<bool> parseBool(
    http.Response response, {
    String errorMessage = 'Error parsing response',
  }) async {
    try {
      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<bool>.fromJson(
          jsonDecode(response.body),
        );

        if (apiResponse.isSuccess) {
          return apiResponse.data ?? false;
        } else {
          if (kDebugMode) {
            AppLogger.error('$errorMessage: ${apiResponse.errorMessage}');
          }
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
  /// [response] HTTP 响应
  /// [errorMessage] 自定义错误消息前缀
  static Future<T?> parseRaw<T>(
    http.Response response, {
    String errorMessage = 'Error parsing response',
  }) async {
    try {
      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<T>.fromJson(
          jsonDecode(response.body),
        );

        if (apiResponse.isSuccess) {
          return apiResponse.data;
        } else {
          if (kDebugMode) {
            AppLogger.error('$errorMessage: ${apiResponse.errorMessage}');
          }
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
  /// [response] HTTP 响应
  /// [fromJsonT] 可选的数据转换函数
  static ApiResponse<T>? getApiResponse<T>(
    http.Response response, {
    T Function(dynamic)? fromJsonT,
  }) {
    try {
      if (response.statusCode == 200) {
        return ApiResponse<T>.fromJson(
          jsonDecode(response.body),
          fromJsonT: fromJsonT,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error getting ApiResponse: $e');
      }
    }
    return null;
  }
}
