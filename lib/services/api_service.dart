import 'dart:async';
import '../models/school.dart';
import '../models/user.dart';
import '../models/timetable.dart';

/// API 错误码 —— 由 UI 层根据 locale 翻译为对应语言
enum ApiErrorCode {
  schoolNotFound,
  invalidCredentials,
  networkError,
}

class ApiException implements Exception {
  final ApiErrorCode code;
  const ApiException(this.code);
}

/// Mock API 服务 —— 模拟后端接口，实际项目中替换为真实 HTTP 调用
class ApiService {
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;
  ApiService._();

  // ─── Mock 数据 ────────────────────────────────────────────

  static const List<School> _mockSchools = [
    School(
      id: 'sc_001',
      name: '北京大学',
      shortName: '北大',
      supportLevel: SupportLevel.advanced,
    ),
    School(
      id: 'sc_002',
      name: '清华大学',
      shortName: '清华',
      supportLevel: SupportLevel.advanced,
    ),
    School(
      id: 'sc_003',
      name: '北京科技大学',
      shortName: '北科大',
      supportLevel: SupportLevel.basic,
    ),
    School(
      id: 'sc_004',
      name: '首都师范大学',
      shortName: '首师大',
      supportLevel: SupportLevel.basic,
    ),
    School(
      id: 'sc_005',
      name: '北京工业大学',
      shortName: '北工大',
      supportLevel: SupportLevel.advanced,
    ),
  ];

  static final Map<String, List<TimetableEntry>> _mockTimetables = {
    'sc_001': [
      TimetableEntry(id: 't1', courseName: '高等数学', teacher: '张教授', classroom: '教学楼A201', dayOfWeek: 1, startPeriod: 1, endPeriod: 2),
      TimetableEntry(id: 't2', courseName: '大学英语', teacher: '李老师', classroom: '教学楼B101', dayOfWeek: 1, startPeriod: 3, endPeriod: 4),
      TimetableEntry(id: 't3', courseName: '数据结构', teacher: '王教授', classroom: '实验楼301', dayOfWeek: 2, startPeriod: 1, endPeriod: 3),
      TimetableEntry(id: 't4', courseName: '操作系统', teacher: '赵教授', classroom: '教学楼A301', dayOfWeek: 3, startPeriod: 1, endPeriod: 2),
      TimetableEntry(id: 't5', courseName: '数据库原理', teacher: '陈教授', classroom: '实验楼202', dayOfWeek: 3, startPeriod: 5, endPeriod: 6),
      TimetableEntry(id: 't6', courseName: '思想政治教育', teacher: '刘老师', classroom: '教学楼C101', dayOfWeek: 4, startPeriod: 1, endPeriod: 2),
      TimetableEntry(id: 't7', courseName: '线性代数', teacher: '张教授', classroom: '教学楼A201', dayOfWeek: 5, startPeriod: 1, endPeriod: 2),
    ],
    'sc_002': [
      TimetableEntry(id: 't1', courseName: '微积分', teacher: '周教授', classroom: '六教A301', dayOfWeek: 1, startPeriod: 1, endPeriod: 2),
      TimetableEntry(id: 't2', courseName: '普通物理', teacher: '吴教授', classroom: '理学院101', dayOfWeek: 2, startPeriod: 1, endPeriod: 3),
    ],
  };

  // ─── API 接口 ─────────────────────────────────────────────

  Future<List<School>> fetchSchools() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockSchools;
  }

  Future<List<School>> searchSchools(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final q = query.toLowerCase();
    return _mockSchools.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.shortName.toLowerCase().contains(q);
    }).toList();
  }

  Future<User> login({
    required String username,
    required String password,
    required String schoolId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final schoolIndex = _mockSchools.indexWhere((s) => s.id == schoolId);
    if (schoolIndex == -1) throw const ApiException(ApiErrorCode.schoolNotFound);

    final school = _mockSchools[schoolIndex];

    if (username.isEmpty || password.length < 3) {
      throw const ApiException(ApiErrorCode.invalidCredentials);
    }

    return User(
      id: 'user_${schoolId}_001',
      username: username,
      token: 'mock_token_${schoolId}_${DateTime.now().millisecondsSinceEpoch}',
      selectedSchool: school,
    );
  }

  Future<List<TimetableEntry>> fetchTimetable(String schoolId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockTimetables[schoolId] ?? [];
  }
}
