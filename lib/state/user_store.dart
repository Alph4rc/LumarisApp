import 'dart:convert';
import 'package:get/get.dart';
import 'package:ios_club_app/ui/controllers/program_controller.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:ios_club_app/state/schedule_store.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/models/user_data.dart';
import 'prefs_keys.dart';

import 'package:ios_club_app/core/services/secure_storage_service.dart';

import 'package:ios_club_app/features/education/services/education_cache_service.dart';

class UserStore extends GetxController {
  static UserStore get to => Get.find();

  final _isLogin = false.obs;
  final _userData = Rxn<UserData>();

  bool get isLogin => _isLogin.value;

  UserData? get userData => _userData.value;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  /// 加载用户数据
  Future<void> _loadUserData() async {
    final prefs = PrefsService.instance;
    final String? userDataString = prefs.getString(PrefsKeys.USER_DATA);

    if (userDataString != null) {
      try {
        final userDataMap =
            Map<String, dynamic>.from(jsonDecode(userDataString));
        final userData = UserData.fromJson(userDataMap);
        _userData.value = userData;
        if (userData.studentId.isEmpty ||
            userData.studentId == '/student/login') {
          prefs.remove(PrefsKeys.USER_DATA);
        } else {
          _isLogin.value = true;
        }
      } catch (e) {
        // 解析失败，清除数据
        await _clearUserData();
      }
    }
  }

  /// 设置用户数据
  Future<void> setUserData(UserData userData) async {
    _userData.value = userData;
    _isLogin.value = true;
  }

  /// 清除用户数据
  Future<void> _clearUserData() async {
    _userData.value = null;
    _isLogin.value = false;

    final prefs = PrefsService.instance;
    final secureStorage = SecureStorageService.instance;

    await prefs.remove(PrefsKeys.USER_DATA);
    await prefs.remove(PrefsKeys.USERNAME);
    await prefs.remove(PrefsKeys.PASSWORD);
    await prefs.remove(PrefsKeys.COURSE_LAST_FETCH_TIME);
    await prefs.remove(PrefsKeys.EXAM_DATA);
    await prefs.remove(PrefsKeys.INFO_DATA);
    await prefs.remove(PrefsKeys.COURSE_DATA);

    await secureStorage.delete(key: PrefsKeys.USERNAME);
    await secureStorage.delete(key: PrefsKeys.PASSWORD);

    // 调用 EduService 清除所有相关缓存 (包括 Hive 和 RequestCache)
    await EducationCacheService.clearEduCache();

    final courseStore = Get.put(CourseStore());
    courseStore.clearCourseData();

    final scheduleStore = Get.put(ScheduleStore());
    scheduleStore.clean();

    final programStore = Get.put(ProgramController());
    programStore.clean();
  }

  /// 登出
  Future<void> logout() async {
    await _clearUserData();
  }
}
