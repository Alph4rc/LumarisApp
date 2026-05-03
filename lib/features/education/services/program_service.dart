import 'package:flutter/foundation.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/features/education/models/plan_course.dart';

import 'auth_service.dart';
import 'program_api.dart';

class ProgramService {
  static Future<List<PlanCourse>> getProgram({
    bool forceRefresh = false,
  }) async {
    final cookieData = await AuthService.getUserData();
    if (cookieData == null) {
      return [];
    }

    try {
      final result = await ProgramApi.getProgram(
        cookieData.studentId,
        forceRefresh: forceRefresh,
      );
      if (kDebugMode) {
        AppLogger.debug('找到了培养方案：${result.length}');
      }
      return result;
    } catch (e, stackTrace) {
      AppLogger.error('获取培养方案失败', error: e, stackTrace: stackTrace);
    }

    return [];
  }

  static Future<List<PlanCourseList>> getPrograms({
    bool forceRefresh = false,
  }) async {
    final cookieData = await AuthService.getUserData();
    if (cookieData == null) {
      return [];
    }

    try {
      final result = await ProgramApi.getProgramDic(
        cookieData.studentId,
        forceRefresh: forceRefresh,
      );
      if (kDebugMode) {
        AppLogger.debug('找到了培养方案：${result.length}');
      }
      return result.entries
          .map<PlanCourseList>(
            (entry) => PlanCourseList.fromMap(entry.key, entry.value),
          )
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error('获取培养方案字典失败', error: e, stackTrace: stackTrace);
    }

    return [];
  }
}
