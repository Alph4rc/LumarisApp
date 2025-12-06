import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ios_club_app/features/education/services/edu_service.dart';
import 'package:ios_club_app/core/models/user_data.dart';
import 'package:ios_club_app/core/models/exam_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

/// 考试服务类，负责处理考试相关信息的获取和管理
/// 包括从服务器获取考试数据、缓存管理、数据解析等功能
class ExamService {
  /// 获取考试信息
  ///
  /// [isRefresh] 是否强制刷新数据，默认为false
  /// 返回有效的考试项目列表
  static Future<List<ExamItem>> getExam({bool isRefresh = false}) async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    // 缓存检查
    final cacheResult = _checkCache(prefs, now, isRefresh);
    if (!cacheResult.$1 && cacheResult.$2.isNotEmpty) {
      final parsedExams = _parseExamItems(cacheResult.$2, now);
      
      // 如果解析后的数据为空，尝试从服务器获取新数据
      // 这处理了缓存中只有过期考试的情况
      if (parsedExams.isNotEmpty) {
        return parsedExams;
      }
    }

    // 数据获取
    final cookieData = await EduService.getUserData();
    if (cookieData == null) return [];

    // HTTP请求
    final result = await _fetchExamData(cookieData, now);
    if (result.$1) {
      await _updateCache(prefs, result.$2, now);
      return _parseExamItems(result.$2, now);
    }

    return [];
  }

  /// 检查缓存是否有效
  ///
  /// [prefs] SharedPreferences实例
  /// [now] 当前时间
  /// [isRefresh] 是否强制刷新
  /// 返回一个元组，第一个元素表示是否需要刷新数据，第二个元素是缓存的JSON字符串
  static (bool needRefresh, String jsonString) _checkCache(
      SharedPreferences prefs, DateTime now, bool isRefresh) {
    final String jsonString = prefs.getString(PrefsKeys.EXAM_DATA) ?? '';
    final int? examTime = prefs.getInt(PrefsKeys.EXAM_TIME);

    // 解析缓存的考试数据，检查是否有即将到来的考试
    bool hasUpcomingExams = false;
    if (jsonString.isNotEmpty) {
      final upcomingExams = _parseExamItems(jsonString, now);
      hasUpcomingExams = upcomingExams.isNotEmpty;
    }

    // 根据是否有即将到来的考试设置不同的缓存过期时间
    // 有即将到来的考试：2小时过期
    // 没有即将到来的考试：24小时过期
    final cacheDuration = hasUpcomingExams ? Duration(hours: 2) : Duration(hours: 24);
    
    final bool isCached = examTime != null &&
        now.difference(DateTime.fromMicrosecondsSinceEpoch(examTime)) <
            cacheDuration &&
        jsonString.isNotEmpty;

    return (isRefresh || !isCached, jsonString);
  }

  /// 从服务器获取考试数据
  ///
  /// [cookieData] 用户认证信息
  /// [now] 当前时间
  /// 返回一个元组，第一个元素表示是否成功，第二个元素是JSON响应字符串
  static Future<(bool isSuccess, String jsonString)> _fetchExamData(
      UserData cookieData, DateTime now) async {
    try {
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Cookie': cookieData.cookie,
        'xauat': cookieData.cookie,
      };

      final url = Uri.parse(
          'https://xauatapi.xauat.site/Exam?studentId=${cookieData.studentId}');

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        final existingData = prefs.getString(PrefsKeys.EXAM_DATA) ?? '';
        final newData = response.body;
        
        // 合并现有数据和新数据，实现增量更新
        final mergedData = _mergeExamData(existingData, newData, now);
        
        return (true, mergedData);
      }

      debugPrint('Initial request failed: ${response.statusCode}');
      return await _retryWithNewLogin(cookieData, url, headers);
    } catch (e) {
      debugPrint('Error fetching data: $e');
      return (false, '');
    }
  }

  /// 使用新登录信息重试请求
  ///
  /// 当初次请求失败时，尝试重新登录并再次发送请求
  /// [oldCookie] 原始用户认证信息
  /// [url] 请求地址
  /// [headers] 请求头
  /// 返回一个元组，第一个元素表示是否成功，第二个元素是JSON响应字符串
  static Future<(bool isSuccess, String jsonString)> _retryWithNewLogin(
      UserData oldCookie, Uri url, Map<String, String> headers) async {
    // 尝试重新登录
    if (!(await EduService.login())) return (false, '');

    // 获取新的用户认证信息
    final newCookie = await EduService.getUserData();
    if (newCookie == null) return (false, '');

    try {
      final newHeaders = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Cookie': newCookie.cookie,
        'xauat': newCookie.cookie,
      };

      final response = await http.get(url, headers: newHeaders);
      final success = response.statusCode == 200;

      debugPrint(success ? '数据获取成功' : '重试失败: ${response.statusCode}');

      if (success) {
        final now = DateTime.now();
        final prefs = await SharedPreferences.getInstance();
        final existingData = prefs.getString(PrefsKeys.EXAM_DATA) ?? '';
        final newData = response.body;
        
        // 合并现有数据和新数据，实现增量更新
        final mergedData = _mergeExamData(existingData, newData, now);
        return (success, mergedData);
      }

      return (success, success ? jsonEncode(jsonDecode(response.body)) : '');
    } catch (e) {
      debugPrint('重试请求失败: $e');
      return (false, '');
    }
  }

  /// 更新缓存数据
  ///
  /// [prefs] SharedPreferences实例
  /// [jsonString] 要缓存的JSON字符串
  /// [now] 当前时间
  static Future<void> _updateCache(
      SharedPreferences prefs, String jsonString, DateTime now) async {
    // 解析新获取的考试数据，只缓存未来的考试
    final parsedExams = _parseExamItems(jsonString, now);
    
    // 如果有有效考试，才更新缓存
    if (parsedExams.isNotEmpty) {
      await prefs.setString(PrefsKeys.EXAM_DATA, jsonString);
      await prefs.setInt(PrefsKeys.EXAM_TIME, now.microsecondsSinceEpoch);
    } else {
      // 如果没有有效考试，清理缓存
      await prefs.remove(PrefsKeys.EXAM_DATA);
      await prefs.remove(PrefsKeys.EXAM_TIME);
    }
  }

  /// 解析考试项目
  ///
  /// [jsonString] JSON格式的考试数据字符串
  /// [now] 当前时间
  /// 返回有效的考试项目列表
  static List<ExamItem> _parseExamItems(String jsonString, DateTime now) {
    final List<ExamItem> list = [];
    if (jsonString.isEmpty) return list;

    try {
      final jsonList = jsonDecode(jsonString)['exams'];

      for (final json in jsonList) {
        final item = ExamItem.fromJson(json);

        try {
          final endTime = _parseExamTime(item.examTime, now);
          // 只添加未过期的考试
          if (endTime != null && !now.isAfter(endTime)) {
            list.add(item);
          }
        } catch (e) {
          debugPrint('时间解析失败: $e');
          continue;
        }
      }
    } catch (e) {
      debugPrint('JSON解析失败: $e');
    }

    debugPrint('解析完成，找到${list.length}个有效考试');
    return list;
  }

  /// 合并考试数据，实现增量更新
  ///
  /// [existingExams] 现有考试数据JSON字符串
  /// [newExams] 新获取的考试数据JSON字符串
  /// [now] 当前时间
  /// 返回合并后的考试数据JSON字符串
  static String _mergeExamData(String existingExams, String newExams, DateTime now) {
    if (existingExams.isEmpty) return newExams;
    if (newExams.isEmpty) return existingExams;

    try {
      // 解析现有和新的考试数据
      final existingJson = jsonDecode(existingExams);
      final newJson = jsonDecode(newExams);
      
      // 获取现有和新的考试列表
      final existingExamList = (existingJson['exams'] as List<dynamic>).map((e) => ExamItem.fromJson(e)).toList();
      final newExamList = (newJson['exams'] as List<dynamic>).map((e) => ExamItem.fromJson(e)).toList();
      
      // 创建考试项的唯一标识符映射，用于去重
      // 使用课程名称+考试时间+考试地点作为唯一标识符
      final examMap = <String, ExamItem>{};
      
      // 添加现有考试到映射中
      for (var exam in existingExamList) {
        final key = '${exam.name}_${exam.examTime}_${exam.room}';
        examMap[key] = exam;
      }
      
      // 添加新考试到映射中，覆盖现有考试（实现增量更新）
      for (var exam in newExamList) {
        final key = '${exam.name}_${exam.examTime}_${exam.room}';
        examMap[key] = exam;
      }
      
      // 过滤掉过期的考试
      final validExams = examMap.values.where((exam) {
        try {
          final endTime = _parseExamTime(exam.examTime, now);
          return endTime != null && !now.isAfter(endTime);
        } catch (e) {
          return false;
        }
      }).toList();
      
      // 转换回JSON格式
      // 直接使用原始数据结构，不依赖toJson方法
      final mergedJson = {
        'exams': validExams.map((exam) => {
          'name': exam.name,
          'time': exam.examTime,
          'location': exam.room,
          'seat': exam.seatNo,
        }).toList()
      };
      
      return jsonEncode(mergedJson);
    } catch (e) {
      debugPrint('合并考试数据失败: $e');
      // 合并失败时返回新数据
      return newExams;
    }
  }

  /// 解析考试时间字符串
  ///
  /// [timeStr] 时间字符串，格式如："12-25 14:00~16:00"
  /// [now] 当前时间
  /// 返回解析后的考试结束时间，如果解析失败返回null
  static DateTime? _parseExamTime(String timeStr, DateTime now) {
    try {
      final timeSplit = timeStr.split(' ');
      final dateSplit = timeSplit[0].split('-');
      final endHourSplit = timeSplit[1].split('~')[1].split(':');

      return DateTime(
        now.year, // 使用当前年份避免绝对过期
        int.parse(dateSplit[1]),
        int.parse(dateSplit[2]),
        int.parse(endHourSplit[0]),
        int.parse(endHourSplit[1]),
      );
    } catch (e) {
      debugPrint('时间格式错误: $e');
      return null;
    }
  }
}