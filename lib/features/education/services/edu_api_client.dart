import 'package:ios_club_app/features/education/models/bus_model.dart';
import 'package:ios_club_app/features/education/models/edu_api_models.dart';
import 'package:ios_club_app/features/education/models/info_model.dart';
import 'package:ios_club_app/features/education/models/payment_model.dart';
import 'package:ios_club_app/features/education/models/plan_course.dart';
import 'package:ios_club_app/features/education/models/raw_string_response.dart';
import 'package:ios_club_app/features/education/models/score_model.dart';
import 'package:ios_club_app/features/education/models/semester_model.dart';
import 'package:ios_club_app/features/education/models/time_info.dart';
import 'app_api.dart';
import 'bus_api.dart';
import 'course_api.dart';
import 'exam_api.dart';
import 'info_api.dart';
import '../models/login_response.dart';
import 'login_api.dart';
import 'payment_api.dart';
import 'program_api.dart';
import 'score_api.dart';

class EduApiClient {
  /// 获取学期信息
  static Future<SemesterResult> getSemester(String studentId) async {
    return await ScoreApi.getSemester(studentId);
  }

  /// 获取课程信息
  static Future<CourseResultResponse> getCourse(String studentId) async {
    return await CourseApi.getCourse(studentId);
  }

  /// 获取成绩信息
  static Future<List<ScoreModel>> getScore(
      String studentId, String semester) async {
    return await ScoreApi.getScore(studentId, semester);
  }

  /// 获取考试信息
  static Future<ExamResponse> getExam(String studentId) async {
    return await ExamApi.getExam(studentId);
  }

  /// 获取学生信息完成度
  static Future<List<InfoModel>> getInfoCompletion() async {
    return await InfoApi.getInfoCompletion();
  }

  /// 获取本学期成绩
  static Future<SemesterModel> getThisSemester() async {
    return await ScoreApi.getThisSemester();
  }

  /// 获取培养方案
  static Future<List<PlanCourse>> getProgram(String studentId) async {
    return await ProgramApi.getProgram(studentId);
  }

  /// 获取培养方案字典
  static Future<Map<String, List<PlanCourse>>> getProgramDic(
      String studentId) async {
    return await ProgramApi.getProgramDic(studentId);
  }

  /// 获取时间信息
  static Future<TimeInfo> getTime() async {
    return await InfoApi.getTime();
  }

  /// 获取校巴信息
  static Future<BusModel> getBus({String? dayDate}) async {
    return await BusApi.getBus(dayDate: dayDate);
  }

  // 新增方法

  /// 获取App相关信息
  static Future<RawStringResponse> getAppInfo({String? token}) async {
    return await AppApi.getAppInfo(token: token);
  }

  /// 获取新的校巴数据
  static Future<BusModel> getBusNewData(String time,
      {String loc = 'ALL'}) async {
    return await BusApi.getBusNewData(time, loc: loc);
  }

  /// 获取旧的校巴数据
  static Future<BusModel> getBusOldData(String time,
      {bool isShow = false}) async {
    return await BusApi.getBusOldData(time, isShow: isShow);
  }

  /// 登录
  static Future<LoginResponse> login(String username, String password) async {
    return await LoginApi.login(username, password);
  }

  /// 获取缴费信息
  static Future<RawStringResponse> getPayment(String id) async {
    return await PaymentApi.getPayment(id);
  }

  /// 获取缴费流水
  static Future<PaymentData> getPaymentTurnover(String id) async {
    return await PaymentApi.getPaymentTurnover(id);
  }
}
