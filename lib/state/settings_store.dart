import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'prefs_keys.dart';
import '../core/config/api_config.dart';
import '../features/education/services/edu_http_client_manager.dart';

class SettingsStore extends GetxController {
  static SettingsStore get to => Get.find();

  // 课程通知设置
  final _isRemind = false.obs;
  final _remindTime = 15.obs;

  // 明日课程显示设置
  final _isShowTomorrow = false.obs;

  // 待办事项同步设置
  final _isUpdateToClub = false.obs;

  // 主页设置
  final _pageIndex = 0.obs;

  // 触觉反馈设置
  final _enableHapticFeedback = false.obs;

  // 忽略更新设置
  final _updateIgnored = false.obs;

  // 字体设置
  final _fontFamily = ''.obs;
  
  // 课表网格线显示设置
  final _showCourseGrid = false.obs;
  
  // 待办事项提醒设置
  final _todoRemindEnabled = false.obs;

  // 课表背景设置
  final _scheduleBackground = ''.obs; // 空字符串表示无背景，其他值表示不同背景
  final _customBackgroundImage = ''.obs; // 自定义背景图片路径

  // 学校配置
  final _schoolId = ApiConfig.defaultSchoolId.obs;

  bool get isRemind => _isRemind.value;

  int get remindTime => _remindTime.value;

  bool get isShowTomorrow => _isShowTomorrow.value;

  bool get isUpdateToClub => _isUpdateToClub.value;

  int get pageIndex => _pageIndex.value;

  bool get enableHapticFeedback => _enableHapticFeedback.value;

  bool get updateIgnored => _updateIgnored.value;

  String get fontFamily => _fontFamily.value;
  
  bool get showCourseGrid => _showCourseGrid.value;
  
  bool get todoRemindEnabled => _todoRemindEnabled.value;

  String get scheduleBackground => _scheduleBackground.value;

  String get customBackgroundImage => _customBackgroundImage.value;

  String get schoolId => _schoolId.value;

  /// 获取当前学校配置
  SchoolConfig get currentSchool {
    return ApiConfig.getSchoolById(_schoolId.value) ?? ApiConfig.getDefaultSchool();
  }

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  /// 加载所有设置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _isRemind.value = prefs.getBool(PrefsKeys.IS_REMIND) ?? false;
    _remindTime.value = prefs.getInt(PrefsKeys.NOTIFICATION_TIME) ?? 15;
    _isShowTomorrow.value = prefs.getBool(PrefsKeys.IS_SHOW_TOMORROW) ?? false;
    _isUpdateToClub.value = prefs.getBool(PrefsKeys.IS_UPDATE_CLUB) ?? false;
    _pageIndex.value = prefs.getInt(PrefsKeys.PAGE_DATA) ?? 0;
    _enableHapticFeedback.value =
        prefs.getBool(PrefsKeys.ENABLE_HAPTIC_FEEDBACK) ?? false;
    _updateIgnored.value = prefs.getBool(PrefsKeys.UPDATE_IGNORED) ?? false;
    _fontFamily.value = prefs.getString(PrefsKeys.FONT_FAMILY) ?? '';
    _showCourseGrid.value = prefs.getBool(PrefsKeys.SHOW_COURSE_GRID) ?? false;
    _todoRemindEnabled.value = prefs.getBool(PrefsKeys.TODO_REMIND_ENABLED) ?? false;
    _scheduleBackground.value = prefs.getString(PrefsKeys.SCHEDULE_BACKGROUND) ?? '';
    _customBackgroundImage.value = prefs.getString(PrefsKeys.CUSTOM_BACKGROUND_IMAGE) ?? '';
    _schoolId.value = prefs.getString(PrefsKeys.SCHOOL_ID) ?? ApiConfig.defaultSchoolId;
  }

  /// 设置课程通知开关
  Future<void> setIsRemind(bool value) async {
    _isRemind.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.IS_REMIND, value);
  }

  /// 设置提醒时间
  Future<void> setRemindTime(int value) async {
    _remindTime.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefsKeys.NOTIFICATION_TIME, value);
  }

  /// 设置是否显示明日课程
  Future<void> setIsShowTomorrow(bool value) async {
    _isShowTomorrow.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.IS_SHOW_TOMORROW, value);
  }

  /// 设置是否同步待办事项到社团
  Future<void> setIsUpdateToClub(bool value) async {
    _isUpdateToClub.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.IS_UPDATE_CLUB, value);
  }

  /// 设置主页索引
  Future<void> setPageIndex(int value) async {
    _pageIndex.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefsKeys.PAGE_DATA, value);
  }

  /// 设置是否启用触觉反馈
  Future<void> setEnableHapticFeedback(bool value) async {
    _enableHapticFeedback.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.ENABLE_HAPTIC_FEEDBACK, value);
  }

  /// 设置是否忽略更新
  Future<void> setUpdateIgnored(bool value) async {
    _updateIgnored.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.UPDATE_IGNORED, value);
  }

  /// 设置字体
  Future<void> setFontFamily(String value) async {
    _fontFamily.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.FONT_FAMILY, value);
  }
  
  /// 设置是否显示课表网格线
  Future<void> setShowCourseGrid(bool value) async {
    _showCourseGrid.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.SHOW_COURSE_GRID, value);
  }
  
  /// 设置是否启用待办事项提醒
  Future<void> setTodoRemindEnabled(bool value) async {
    _todoRemindEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.TODO_REMIND_ENABLED, value);
  }
  
  /// 设置课表背景
  Future<void> setScheduleBackground(String value) async {
    _scheduleBackground.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.SCHEDULE_BACKGROUND, value);
  }
  
  /// 设置自定义背景图片路径
  Future<void> setCustomBackgroundImage(String value) async {
    _customBackgroundImage.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.CUSTOM_BACKGROUND_IMAGE, value);
  }

  /// 设置学校配置
  ///
  /// 切换学校时会清除以下缓存数据：
  /// - 用户登录数据和 Cookie
  /// - 课程数据
  /// - 成绩数据
  /// - 考试数据
  /// - 学期数据
  /// - 时间数据
  ///
  /// 注意：不会清除用户名和密码，方便用户重新登录
  Future<void> setSchoolId(String schoolId) async {
    // 验证学校 ID 是否有效
    final school = ApiConfig.getSchoolById(schoolId);
    if (school == null) {
      throw ArgumentError('Invalid school ID: $schoolId');
    }

    _schoolId.value = schoolId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.SCHOOL_ID, schoolId);

    // 更新 HTTP 客户端的基础 URL
    try {
      EduHttpClientManager.to.updateSchoolConfig(school);
    } catch (e) {
      // 如果管理器还未初始化，忽略错误
      // 下次初始化时会自动使用新的学校配置
    }

    // 清除与学校相关的缓存数据
    await _clearSchoolRelatedData();
  }

  /// 清除学校相关的缓存数据
  Future<void> _clearSchoolRelatedData() async {
    final prefs = await SharedPreferences.getInstance();

    // 清除用户登录数据
    await prefs.remove(PrefsKeys.USER_DATA);
    await prefs.remove(PrefsKeys.LAST_FETCH_TIME);

    // 清除课程数据
    await prefs.remove(PrefsKeys.COURSE_DATA);
    await prefs.remove(PrefsKeys.COURSE_LAST_FETCH_TIME);

    // 清除成绩数据
    await prefs.remove(PrefsKeys.ALL_SCORE_DATA);
    await prefs.remove(PrefsKeys.LAST_SCORE_TIME);
    await prefs.remove(PrefsKeys.THIS_SEMESTER_DATA);

    // 清除考试数据
    await prefs.remove(PrefsKeys.EXAM_DATA);
    await prefs.remove(PrefsKeys.EXAM_TIME);

    // 清除学期数据
    await prefs.remove(PrefsKeys.SEMESTER_DATA);
    await prefs.remove(PrefsKeys.SEMESTER_TIME);

    // 清除时间数据
    await prefs.remove(PrefsKeys.TIME_DATA);
    await prefs.remove(PrefsKeys.TIME_LAST_UPDATED);

    // 清除信息完成度数据
    await prefs.remove(PrefsKeys.INFO_DATA);
    await prefs.remove(PrefsKeys.INFO_DATA_TIME);
  }
}