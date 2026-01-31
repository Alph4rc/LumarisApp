import 'dart:convert';

import 'package:ios_club_app/features/education/services/edu_service.dart';
import 'package:ios_club_app/features/education/services/exam_api.dart';
import 'package:ios_club_app/core/models/user_data.dart';
import 'package:ios_club_app/core/models/exam_model.dart';
import 'package:ios_club_app/core/models/exam_result.dart';
import 'package:ios_club_app/core/services/network_exception.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

/// 考试服务类，负责处理考试相关信息的获取和管理
/// 包括从服务器获取考试数据、缓存管理、数据解析等功能
class ExamService {
  /// 获取考试信息
  ///
  /// [isRefresh] 是否强制刷新数据，默认为false
  /// 返回考试结果，包含成功/失败状态和数据
  static Future<ExamResult> getExam({bool isRefresh = false}) async {
    final now = DateTime.now();
    final prefs = PrefsService.instance;

    // 缓存检查
    final cacheResult = _checkCache(prefs, now, isRefresh);
    if (!cacheResult.$1 && cacheResult.$2.isNotEmpty) {
      final parsedExams = _parseExamItems(cacheResult.$2, now);

      // 如果解析后的数据为空，尝试从服务器获取新数据
      // 这处理了缓存中只有过期考试的情况
      if (parsedExams.isNotEmpty) {
        return ExamResult.success(parsedExams);
      }
    }

    // 数据获取
    final cookieData = await EduService.getUserData();
    if (cookieData == null) {
      return ExamResult.error('未登录，请先登录');
    }

    // HTTP请求
    final result = await _fetchExamData(cookieData, now);
    if (result.$1) {
      await _updateCache(prefs, result.$2, now);
      final exams = _parseExamItems(result.$2, now);
      return exams.isEmpty ? ExamResult.empty() : ExamResult.success(exams);
    }

    // 请求失败，返回错误结果
    return result.$3;
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
    final cacheDuration =
        hasUpcomingExams ? Duration(hours: 2) : Duration(hours: 24);

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
  /// 返回一个元组，第一个元素表示是否成功，第二个元素是JSON响应字符串，第三个元素是错误结果
  ///
  /// 注意：EduHttpClient 已内置重试和重登录机制，这里不再额外处理
  static Future<(bool isSuccess, String jsonString, ExamResult errorResult)>
      _fetchExamData(UserData cookieData, DateTime now) async {
    try {
      // 使用ExamApi获取考试数据
      // ExamApi 使用 EduHttpClient，已内置重试和401/403重登录机制
      final response = await ExamApi.getExam(cookieData.studentId);

      final prefs = PrefsService.instance;
      final existingData = prefs.getString(PrefsKeys.EXAM_DATA) ?? '';

      // 合并现有数据和新数据，实现增量更新
      final mergedData = _mergeExamData(existingData, response, now);

      return (true, mergedData, ExamResult.empty());
    } on AuthenticationException catch (e) {
      AppLogger.debug('认证失败: $e');
      return (false, '', ExamResult.error('认证失败，请重新登录'));
    } on NetworkException catch (e) {
      AppLogger.debug('网络错误: $e');
      return (false, '', ExamResult.networkError(e.message));
    } catch (e) {
      AppLogger.debug('获取考试数据失败: $e');
      return (false, '', ExamResult.error('获取考试信息失败: $e'));
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
          AppLogger.debug('时间解析失败: $e');
          continue;
        }
      }
    } catch (e) {
      AppLogger.debug('JSON解析失败: $e');
    }

    AppLogger.debug('解析完成，找到${list.length}个有效考试');
    return list;
  }

  /// 合并考试数据，实现增量更新
  ///
  /// [existingExams] 现有考试数据JSON字符串
  /// [newExams] 新获取的考试数据JSON字符串
  /// [now] 当前时间
  /// 返回合并后的考试数据JSON字符串
  static String _mergeExamData(
      String existingExams, String newExams, DateTime now) {
    if (existingExams.isEmpty) return newExams;
    if (newExams.isEmpty) return existingExams;

    try {
      // 解析现有和新的考试数据
      final existingJson = jsonDecode(existingExams);
      final newJson = jsonDecode(newExams);

      // 获取现有和新的考试列表
      final existingExamList = (existingJson['exams'] as List<dynamic>)
          .map((e) => ExamItem.fromJson(e))
          .toList();
      final newExamList = (newJson['exams'] as List<dynamic>)
          .map((e) => ExamItem.fromJson(e))
          .toList();

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
        'exams': validExams
            .map((exam) => {
                  'name': exam.name,
                  'time': exam.examTime,
                  'location': exam.room,
                  'seat': exam.seatNo,
                })
            .toList()
      };

      return jsonEncode(mergedJson);
    } catch (e) {
      AppLogger.debug('合并考试数据失败: $e');
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

      final month = int.parse(dateSplit[1]);
      final day = int.parse(dateSplit[2]);
      final hour = int.parse(endHourSplit[0]);
      final minute = int.parse(endHourSplit[1]);

      // 智能判断年份，处理跨年考试
      int year = now.year;

      // 如果考试月份小于当前月份，且考试月份在上半年（1-6月），当前月份在下半年（7-12月）
      // 则可能是下一年的考试（例如：12月查看1月的考试）
      if (month < now.month && month <= 6 && now.month >= 7) {
        year++;
      }
      // 如果考试月份大于当前月份，且考试月份在下半年（7-12月），当前月份在上半年（1-6月）
      // 则可能是上一年的考试（例如：1月查看12月的考试，但这种情况应该已过期）
      else if (month > now.month && month >= 7 && now.month <= 6) {
        year--;
      }

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      AppLogger.debug('时间格式错误: $e');
      return null;
    }
  }
}
