import 'package:flutter/foundation.dart';
import '../models/school.dart';
import '../models/user.dart';
import '../models/timetable.dart';
import '../services/api_service.dart';

enum AuthStatus {
  initial,    // 启动中
  unauthenticated, // 未登录
  loading,    // 登录请求中
  authenticated,  // 已登录
  error,      // 登录失败
}

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  AuthStatus _status = AuthStatus.unauthenticated;
  User? _user;
  ApiErrorCode? _errorCode;
  List<School> _schools = [];
  bool _schoolsLoading = false;
  List<TimetableEntry> _timetable = [];
  bool _timetableLoading = false;

  // ─── Getters ──────────────────────────────────────────────

  AuthStatus get status => _status;
  User? get user => _user;
  ApiErrorCode? get errorCode => _errorCode;
  School? get selectedSchool => _user?.selectedSchool;
  SupportLevel get supportLevel =>
      _user?.selectedSchool.supportLevel ?? SupportLevel.basic;
  List<Feature> get availableFeatures =>
      _user?.selectedSchool.availableFeatures ?? [];
  List<School> get schools => _schools;
  bool get schoolsLoading => _schoolsLoading;
  List<TimetableEntry> get timetable => _timetable;
  bool get timetableLoading => _timetableLoading;

  bool supports(Feature feature) =>
      _user?.selectedSchool.supports(feature) ?? false;

  // ─── 加载学校列表 ─────────────────────────────────────────

  Future<void> loadSchools() async {
    _schoolsLoading = true;
    notifyListeners();
    try {
      _schools = await _api.fetchSchools();
    } catch (e) {
      _errorCode = ApiErrorCode.networkError;
    } finally {
      _schoolsLoading = false;
      notifyListeners();
    }
  }

  /// 搜索学校（即时搜索，无 loading 态避免闪烁）
  Future<List<School>> searchSchools(String query) async {
    if (query.trim().isEmpty) return _schools;
    return _api.searchSchools(query);
  }

  // ─── 登录 ─────────────────────────────────────────────────

  Future<bool> login({
    required String username,
    required String password,
    required String schoolId,
  }) async {
    _status = AuthStatus.loading;
    _errorCode = null;
    notifyListeners();

    try {
      _user = await _api.login(
        username: username,
        password: password,
        schoolId: schoolId,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _status = AuthStatus.error;
      _errorCode = e.code;
      notifyListeners();
      return false;
    }
  }

  // ─── 加载课表 ─────────────────────────────────────────────

  Future<void> loadTimetable() async {
    if (_user == null) return;
    _timetableLoading = true;
    notifyListeners();
    try {
      _timetable = await _api.fetchTimetable(_user!.selectedSchool.id);
    } finally {
      _timetableLoading = false;
      notifyListeners();
    }
  }

  // ─── 登出 ─────────────────────────────────────────────────

  void logout() {
    _user = null;
    _timetable = [];
    _status = AuthStatus.unauthenticated;
    _errorCode = null;
    notifyListeners();
  }

  /// 清除错误状态，让用户重试
  void clearError() {
    _status = AuthStatus.unauthenticated;
    _errorCode = null;
    notifyListeners();
  }
}
