// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '光序';

  @override
  String get appSubtitle => '选择学校并登录以查看课表';

  @override
  String get selectSchool => '选择学校';

  @override
  String get searchSchoolHint => '输入学校名称搜索...';

  @override
  String get supportLevelAdvanced => '高级';

  @override
  String get supportLevelBasic => '基础';

  @override
  String get supportLevelAdvancedDesc => '高级支持';

  @override
  String get supportLevelBasicDesc => '基础支持';

  @override
  String supportLevelAdvancedInfo(String schoolName) {
    return '$schoolName — 高级支持：可查看、编辑、导出课表，支持通知';
  }

  @override
  String supportLevelBasicInfo(String schoolName) {
    return '$schoolName — 基础支持：仅可查看课表';
  }

  @override
  String get username => '用户名';

  @override
  String get usernameHint => '请输入用户名';

  @override
  String get usernameRequired => '请输入用户名';

  @override
  String get password => '密码';

  @override
  String get passwordHint => '请输入密码';

  @override
  String get passwordTooShort => '密码至少3位';

  @override
  String get login => '登录';

  @override
  String get loginFailed => '登录失败';

  @override
  String get pleaseSelectSchool => '请先选择学校';

  @override
  String get schoolNotFound => '未找到该学校';

  @override
  String get invalidCredentials => '用户名或密码错误';

  @override
  String get timetable => '课表';

  @override
  String get mon => '周一';

  @override
  String get tue => '周二';

  @override
  String get wed => '周三';

  @override
  String get thu => '周四';

  @override
  String get fri => '周五';

  @override
  String get sat => '周六';

  @override
  String get sun => '周日';

  @override
  String get exportTimetable => '导出课表';

  @override
  String get notificationSettings => '通知设置';

  @override
  String get switchSchoolOrLogout => '切换学校/退出';

  @override
  String get noTimetableData => '暂无课表数据';

  @override
  String get advancedCanEditHint => '升级至高级支持以编辑课表';

  @override
  String get noCourse => '暂无课程';

  @override
  String get edit => '编辑';

  @override
  String get featureInDevelopment => '此功能正在开发中';
}
