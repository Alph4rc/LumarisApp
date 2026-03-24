import 'package:get/get.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/state/course_store.dart';

import 'auth_service.dart';
import 'course_service.dart';
import 'edu_time_service.dart';
import 'education_cache_service.dart';
import 'exam_service.dart';
import 'info_service.dart';
import 'score_service.dart';

class EducationRefreshService {
  static Future<bool> loginAndRefresh(String username, String password) async {
    await EducationCacheService.clearEduCache();
    final loginResult = await AuthService.loginFromData(username, password);
    if (!loginResult) {
      return false;
    }
    return refreshWithExistingSession();
  }

  static Future<bool> refresh() async {
    try {
      final loginResult = await AuthService.login();
      if (!loginResult) {
        return false;
      }
      return refreshWithExistingSession();
    } catch (e, stackTrace) {
      AppLogger.error('刷新数据失败', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  static Future<bool> refreshWithExistingSession() async {
    try {
      final cookieData = await AuthService.getUserData();
      if (cookieData == null) {
        return false;
      }

      await Future.wait([
        ScoreService.getSemester(userData: cookieData),
        EduTimeService.syncTime(),
        ExamService.getExam(userData: cookieData),
        InfoService.getInfoCompletion(userData: cookieData),
      ]);

      await CourseService.getCourse(userData: cookieData, isRefresh: true);

      final courseStore = Get.put(CourseStore());
      courseStore.loadCourses();
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('刷新数据失败', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}
