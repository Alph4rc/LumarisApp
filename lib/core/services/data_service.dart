import 'package:ios_club_app/core/models/course_time.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/features/education/models/info_model.dart';
import 'package:ios_club_app/features/education/models/score_model.dart';
import 'package:ios_club_app/features/education/models/semester_model.dart';
import 'package:ios_club_app/features/education/models/time_info.dart';
import 'package:ios_club_app/features/education/models/week_info.dart';
import 'package:ios_club_app/features/education/services/course_service.dart';
import 'package:ios_club_app/features/education/models/edu_fetch_models.dart';
import 'package:ios_club_app/features/education/services/edu_time_service.dart';
import 'package:ios_club_app/features/education/services/info_service.dart';
import 'package:ios_club_app/features/education/services/score_service.dart';

/// 兼容层，勿新增逻辑。
@Deprecated('Use education domain services instead.')
class DataService {
  static Future<FetchSnapshot<List<CourseModel>>> getCourses({
    FetchPolicy policy = FetchPolicy.localFirst,
    bool includeIgnored = false,
  }) {
    return CourseService.getCourses(
      policy: policy,
      includeIgnored: includeIgnored,
    );
  }

  static Future<List<CourseModel>> getAllCourse({
    bool isNeedIgnore = true,
  }) {
    return CourseService.getAllCourse(isNeedIgnore: isNeedIgnore);
  }

  static Future<List<String>> getCourseName() => CourseService.getCourseName();

  static Future<void> setIgnore(List<String> list) =>
      CourseService.setIgnore(list);

  static Future<List<String>> getIgnore() => CourseService.getIgnore();

  static Future<WeekInfo> getWeek({bool isRefresh = false}) {
    return EduTimeService.getWeek(isRefresh: isRefresh);
  }

  static Future<List<CourseModel>> getCourseByWeek({int week = 0}) {
    return CourseService.getCourseByWeek(week: week);
  }

  static Future<(bool, List<CourseModel>)> getTodayOrTomorrowCourse({
    bool isTomorrow = false,
  }) {
    return CourseService.getTodayOrTomorrowCourse(isTomorrow: isTomorrow);
  }

  static Future<Map<String, List<CourseModel>>> getTodayAndTomorrowCourses() {
    return CourseService.getTodayAndTomorrowCourses();
  }

  static Future<List<ScoreList>> getScore() =>
      ScoreService.getAllScoreFromLocal();

  static Future<FetchSnapshot<List<ScoreList>>> getScores({
    FetchPolicy policy = FetchPolicy.localFirst,
  }) {
    return ScoreService.getScores(policy: policy);
  }

  static Future<List<SemesterModel>> getSemester({bool isRefresh = false}) {
    return ScoreService.getSemesterList(isRefresh: isRefresh);
  }

  static Future<FetchSnapshot<List<SemesterModel>>> getSemesters({
    FetchPolicy policy = FetchPolicy.localFirst,
  }) {
    return ScoreService.getSemesters(policy: policy);
  }

  static Future<TimeInfo> getTime({bool isRefresh = false}) {
    return EduTimeService.getTime(isRefresh: isRefresh);
  }

  static Future<FetchSnapshot<TimeInfo>> getTimeInfo({
    FetchPolicy policy = FetchPolicy.localFirst,
  }) {
    return EduTimeService.getTimeSnapshot(policy: policy);
  }

  static Future<List<InfoModel>> getInfoList() => InfoService.getInfoList();

  static Future<List<CourseTime>> getAllTime() => CourseService.getAllTime();
}
