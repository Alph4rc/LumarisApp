import 'package:ios_club_app/features/education/models/bus_model.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/features/education/models/plan_course.dart';
import 'package:ios_club_app/features/education/models/score_model.dart';
import 'package:ios_club_app/features/education/models/semester_model.dart';
import 'package:ios_club_app/features/education/models/time_info.dart';
import 'package:ios_club_app/features/education/models/user_data.dart';

import 'auth_service.dart';
import 'bus_service.dart';
import 'course_service.dart';
import 'edu_time_service.dart';
import 'education_cache_service.dart';
import 'education_refresh_service.dart';
import 'exam_service.dart';
import 'info_service.dart';
import 'program_service.dart';
import 'score_service.dart';

/// 兼容层，勿新增逻辑。
@Deprecated('Use domain services in features/education/services instead.')
class EduService {
  static Future<void> migrateCredentials() => AuthService.migrateCredentials();

  static Future<void> clearEduCache() => EducationCacheService.clearEduCache();

  static Future<bool> refresh() => EducationRefreshService.refresh();

  static Future<bool> loginFromData(String username, String password) {
    return EducationRefreshService.loginAndRefresh(username, password);
  }

  static Future<bool> login() => AuthService.login();

  static Future<UserData?> getUserData() => AuthService.getUserData();

  static Future<UserData?> getCookie() => AuthService.getCookie();

  static Future<void> getThisSemester({UserData? userData}) {
    return ScoreService.getThisSemester(userData: userData);
  }

  static Future<void> getSemester({UserData? userData}) {
    return ScoreService.getSemester(userData: userData);
  }

  static Future<List<SemesterModel>> fetchSemestersFromRemote({
    UserData? userData,
    bool forceRefresh = false,
  }) {
    return ScoreService.fetchSemestersFromRemote(
      userData: userData,
      forceRefresh: forceRefresh,
    );
  }

  static Future<void> getCourse({
    UserData? userData,
    bool isRefresh = false,
  }) {
    return CourseService.getCourse(userData: userData, isRefresh: isRefresh);
  }

  static Future<List<CourseModel>> fetchCoursesFromRemote({
    UserData? userData,
    bool forceRefresh = false,
  }) {
    return CourseService.fetchCoursesFromRemote(
      userData: userData,
      forceRefresh: forceRefresh,
    );
  }

  static Future<void> getAllScore({UserData? userData}) {
    return ScoreService.getAllScore(userData: userData);
  }

  static Future<List<ScoreList>> getAllScoreFromLocal({
    bool isRefresh = false,
  }) {
    return ScoreService.getAllScoreFromLocal(isRefresh: isRefresh);
  }

  static Future<List<ScoreList>> fetchScoresFromRemote({
    UserData? userData,
    bool forceRefresh = false,
  }) {
    return ScoreService.fetchScoresFromRemote(
      userData: userData,
      forceRefresh: forceRefresh,
    );
  }

  static Future<void> getExam({UserData? userData}) {
    return ExamService.getExam(userData: userData);
  }

  static Future<void> getTime() => EduTimeService.syncTime();

  static Future<TimeInfo?> fetchTimeInfoFromRemote({
    bool forceRefresh = false,
  }) {
    return EduTimeService.fetchTimeInfoFromRemote(forceRefresh: forceRefresh);
  }

  static Future<void> getInfoCompletion({UserData? userData}) {
    return InfoService.getInfoCompletion(userData: userData);
  }

  static Future<BusModel> getBus({String? dayDate}) {
    return BusService.getBus(dayDate: dayDate);
  }

  static Future<List<PlanCourse>> getProgram() => ProgramService.getProgram();

  static Future<List<PlanCourseList>> getPrograms() {
    return ProgramService.getPrograms();
  }
}
