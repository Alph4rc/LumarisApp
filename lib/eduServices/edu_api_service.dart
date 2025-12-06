import 'package:ios_club_app/models/bus_model.dart';
import 'package:ios_club_app/models/plan_course.dart';
import 'package:ios_club_app/models/score_model.dart';
import 'package:ios_club_app/models/user_data.dart';
import 'edu_service.dart';
import 'app_api.dart';
import 'bus_api.dart';
import 'payment_api.dart';

/// 统一的教务系统API服务
/// 提供简洁的调用接口，整合所有教务系统相关的API方法
class EduApiService {
  // MARK: - 登录相关
  
  /// 使用用户名和密码登录
  static Future<bool> login(String username, String password) async {
    return await EduService.loginFromData(username, password);
  }
  
  /// 从本地缓存登录
  static Future<bool> loginFromCache() async {
    return await EduService.login();
  }
  
  /// 获取用户数据
  static Future<UserData?> getUserData() async {
    return await EduService.getUserData();
  }
  
  /// 刷新所有数据
  static Future<bool> refreshAllData() async {
    return await EduService.refresh();
  }
  
  // MARK: - 课程相关
  
  /// 获取课程信息
  static Future<void> getCourses({UserData? userData, bool isRefresh = false}) async {
    return await EduService.getCourse(userData: userData, isRefresh: isRefresh);
  }
  
  // MARK: - 成绩相关
  
  /// 获取学期列表
  static Future<void> getSemesters({UserData? userData}) async {
    return await EduService.getSemester(userData: userData);
  }
  
  /// 获取本学期成绩
  static Future<void> getCurrentSemesterScores({UserData? userData}) async {
    return await EduService.getThisSemester(userData: userData);
  }
  
  /// 获取所有学期成绩
  static Future<void> getAllScores({UserData? userData}) async {
    return await EduService.getAllScore(userData: userData);
  }
  
  /// 从本地获取所有成绩
  static Future<List<ScoreList>> getAllScoresFromLocal({bool isRefresh = false}) async {
    return await EduService.getAllScoreFromLocal(isRefresh: isRefresh);
  }
  
  // MARK: - 考试相关
  
  /// 获取考试信息
  static Future<void> getExams({UserData? userData}) async {
    return await EduService.getExam(userData: userData);
  }
  
  // MARK: - 培养方案相关
  
  /// 获取培养方案
  static Future<List<PlanCourse>> getProgram() async {
    return await EduService.getProgram();
  }
  
  /// 获取培养方案字典
  static Future<List<PlanCourseList>> getPrograms() async {
    return await EduService.getPrograms();
  }
  
  // MARK: - 其他相关
  
  /// 获取时间信息
  static Future<void> getTime() async {
    return await EduService.getTime();
  }
  
  /// 获取学生信息完成度
  static Future<void> getInfoCompletion({UserData? userData}) async {
    return await EduService.getInfoCompletion(userData: userData);
  }
  
  /// 获取校巴信息
  static Future<BusModel> getBus({String? dayDate}) async {
    return await EduService.getBus(dayDate: dayDate);
  }
  
  // MARK: - 新增API
  
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
  
  /// 获取缴费信息
  static Future<String> getPayment(String id) async {
    return await PaymentApi.getPayment(id);
  }
  
  /// 获取缴费流水
  static Future<String> getPaymentTurnover(String id) async {
    return await PaymentApi.getPaymentTurnover(id);
  }
}
