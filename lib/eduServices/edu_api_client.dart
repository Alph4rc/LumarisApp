import 'app_api.dart';
import 'bus_api.dart';
import 'course_api.dart';
import 'exam_api.dart';
import 'info_api.dart';
import 'login_api.dart';
import 'payment_api.dart';
import 'program_api.dart';
import 'score_api.dart';

class EduApiClient {
  /// 获取学期信息
  static Future<String> getSemester(String studentId) async {
    return await ScoreApi.getSemester(studentId);
  }

  /// 获取课程信息
  static Future<String> getCourse(String studentId) async {
    return await CourseApi.getCourse(studentId);
  }

  /// 获取成绩信息
  static Future<String> getScore(
      String studentId, String semester) async {
    return await ScoreApi.getScore(studentId, semester);
  }

  /// 获取考试信息
  static Future<String> getExam(String studentId) async {
    return await ExamApi.getExam(studentId);
  }

  /// 获取学生信息完成度
  static Future<String> getInfoCompletion() async {
    return await InfoApi.getInfoCompletion();
  }

  /// 获取本学期成绩
  static Future<String> getThisSemester() async {
    return await ScoreApi.getThisSemester();
  }

  /// 获取培养方案
  static Future<String> getProgram(String studentId) async {
    return await ProgramApi.getProgram(studentId);
  }

  /// 获取培养方案字典
  static Future<String> getProgramDic(String studentId) async {
    return await ProgramApi.getProgramDic(studentId);
  }

  /// 获取时间信息
  static Future<String> getTime() async {
    return await InfoApi.getTime();
  }

  /// 获取校巴信息
  static Future<String> getBus({String? dayDate}) async {
    return await BusApi.getBus(dayDate: dayDate);
  }

  // 新增方法
  
  /// 获取App相关信息
  static Future<String> getAppInfo({String? token}) async {
    return await AppApi.getAppInfo(token: token);
  }
  
  /// 获取新的校巴数据
  static Future<String> getBusNewData(String time, {String loc = 'ALL'}) async {
    return await BusApi.getBusNewData(time, loc: loc);
  }
  
  /// 获取旧的校巴数据
  static Future<String> getBusOldData(String time, {bool isShow = false}) async {
    return await BusApi.getBusOldData(time, isShow: isShow);
  }
  
  /// 登录
  static Future<Map<String, dynamic>> login(String username, String password) async {
    return await LoginApi.login(username, password);
  }
  
  /// 获取缴费信息
  static Future<String> getPayment(String id) async {
    return await PaymentApi.getPayment(id);
  }
  
  /// 获取缴费流水
  static Future<String> getPaymentTurnover(String id) async {
    return await PaymentApi.getPaymentTurnover(id);
  }
}
