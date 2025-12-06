import 'package:ios_club_app/core/models/bus_model.dart';
import 'package:ios_club_app/core/models/plan_course.dart';
import 'package:ios_club_app/core/models/score_model.dart';
import 'package:ios_club_app/core/models/user_data.dart';
import 'edu_service.dart';
import 'app_api.dart';
import 'bus_api.dart';
import 'payment_api.dart';

/// 统一的教务系统API服务类
/// 
/// 提供简洁的调用接口，整合所有教务系统相关的API方法，包括登录、课程、成绩、考试等功能。
/// 作为应用与教务系统之间的桥梁，封装了复杂的网络请求和数据处理逻辑。
class EduApiService {
  // MARK: - 登录相关
  
  /// 使用用户名和密码登录教务系统
  /// 
  /// @param username 用户名（通常是学号）
  /// @param password 密码
  /// @return 登录是否成功
  static Future<bool> login(String username, String password) async {
    return await EduService.loginFromData(username, password);
  }
  
  /// 从本地缓存登录教务系统
  /// 
  /// 使用之前保存的登录信息进行自动登录，无需再次输入用户名和密码。
  /// @return 登录是否成功
  static Future<bool> loginFromCache() async {
    return await EduService.login();
  }
  
  /// 获取当前登录用户的数据
  /// 
  /// @return 用户数据对象，包含用户基本信息
  static Future<UserData?> getUserData() async {
    return await EduService.getUserData();
  }
  
  /// 刷新所有用户数据
  /// 
  /// 重新从服务器获取所有用户相关数据，包括课程、成绩、考试等。
  /// @return 刷新是否成功
  static Future<bool> refreshAllData() async {
    return await EduService.refresh();
  }
  
  // MARK: - 课程相关
  
  /// 获取课程信息
  /// 
  /// @param userData 用户数据（可选，默认使用当前登录用户）
  /// @param isRefresh 是否强制刷新（可选，默认false）
  static Future<void> getCourses({UserData? userData, bool isRefresh = false}) async {
    return await EduService.getCourse(userData: userData, isRefresh: isRefresh);
  }
  
  // MARK: - 成绩相关
  
  /// 获取学期列表
  /// 
  /// @param userData 用户数据（可选，默认使用当前登录用户）
  static Future<void> getSemesters({UserData? userData}) async {
    return await EduService.getSemester(userData: userData);
  }
  
  /// 获取本学期成绩
  /// 
  /// @param userData 用户数据（可选，默认使用当前登录用户）
  static Future<void> getCurrentSemesterScores({UserData? userData}) async {
    return await EduService.getThisSemester(userData: userData);
  }
  
  /// 获取所有学期成绩
  /// 
  /// @param userData 用户数据（可选，默认使用当前登录用户）
  static Future<void> getAllScores({UserData? userData}) async {
    return await EduService.getAllScore(userData: userData);
  }
  
  /// 从本地获取所有成绩
  /// 
  /// @param isRefresh 是否强制刷新（可选，默认false）
  /// @return 成绩列表
  static Future<List<ScoreList>> getAllScoresFromLocal({bool isRefresh = false}) async {
    return await EduService.getAllScoreFromLocal(isRefresh: isRefresh);
  }
  
  // MARK: - 考试相关
  
  /// 获取考试信息
  /// 
  /// @param userData 用户数据（可选，默认使用当前登录用户）
  static Future<void> getExams({UserData? userData}) async {
    return await EduService.getExam(userData: userData);
  }
  
  // MARK: - 培养方案相关
  
  /// 获取培养方案
  /// 
  /// @return 培养方案课程列表
  static Future<List<PlanCourse>> getProgram() async {
    return await EduService.getProgram();
  }
  
  /// 获取培养方案字典
  /// 
  /// @return 培养方案课程列表集合
  static Future<List<PlanCourseList>> getPrograms() async {
    return await EduService.getPrograms();
  }
  
  // MARK: - 其他相关
  
  /// 获取时间信息
  /// 
  /// 获取当前学期时间、校历等相关信息。
  static Future<void> getTime() async {
    return await EduService.getTime();
  }
  
  /// 获取学生信息完成度
  /// 
  /// @param userData 用户数据（可选，默认使用当前登录用户）
  static Future<void> getInfoCompletion({UserData? userData}) async {
    return await EduService.getInfoCompletion(userData: userData);
  }
  
  /// 获取校巴信息
  /// 
  /// @param dayDate 日期（可选，格式：yyyy-MM-dd，默认获取当天）
  /// @return 校巴信息模型
  static Future<BusModel> getBus({String? dayDate}) async {
    return await EduService.getBus(dayDate: dayDate);
  }
  
  // MARK: - 新增API
  
  /// 获取App相关信息
  /// 
  /// @param token 令牌（可选，用于身份验证）
  /// @return App信息JSON字符串
  static Future<String> getAppInfo({String? token}) async {
    return await AppApi.getAppInfo(token: token);
  }
  
  /// 获取新的校巴数据
  /// 
  /// @param time 时间（格式：yyyy-MM-dd）
  /// @param loc 位置（可选，默认'ALL'表示所有位置）
  /// @return 校巴数据JSON字符串
  static Future<String> getBusNewData(String time, {String loc = 'ALL'}) async {
    return await BusApi.getBusNewData(time, loc: loc);
  }
  
  /// 获取旧的校巴数据
  /// 
  /// @param time 时间（格式：yyyy-MM-dd）
  /// @param isShow 是否显示（可选，默认false）
  /// @return 校巴数据JSON字符串
  static Future<String> getBusOldData(String time, {bool isShow = false}) async {
    return await BusApi.getBusOldData(time, isShow: isShow);
  }
  
  /// 获取缴费信息
  /// 
  /// @param id 用户ID
  /// @return 缴费信息JSON字符串
  static Future<String> getPayment(String id) async {
    return await PaymentApi.getPayment(id);
  }
  
  /// 获取缴费流水
  /// 
  /// @param id 用户ID
  /// @return 缴费流水JSON字符串
  static Future<String> getPaymentTurnover(String id) async {
    return await PaymentApi.getPaymentTurnover(id);
  }
}
