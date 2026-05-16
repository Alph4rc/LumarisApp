// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Lumaris';

  @override
  String get appSubtitle => 'Sign in to view your timetable';

  @override
  String get selectSchool => 'Select School';

  @override
  String get searchSchoolHint => 'Search school name...';

  @override
  String get supportLevelAdvanced => 'Advanced';

  @override
  String get supportLevelBasic => 'Basic';

  @override
  String get supportLevelAdvancedDesc => 'Advanced support';

  @override
  String get supportLevelBasicDesc => 'Basic support';

  @override
  String supportLevelAdvancedInfo(String schoolName) {
    return '$schoolName — Advanced: view, edit, export timetable, notifications';
  }

  @override
  String supportLevelBasicInfo(String schoolName) {
    return '$schoolName — Basic: view timetable only';
  }

  @override
  String get username => 'Username';

  @override
  String get usernameHint => 'Enter your username';

  @override
  String get usernameRequired => 'Please enter your username';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get passwordTooShort => 'Password must be at least 3 characters';

  @override
  String get login => 'Sign In';

  @override
  String get loginFailed => 'Sign in failed';

  @override
  String get pleaseSelectSchool => 'Please select a school first';

  @override
  String get schoolNotFound => 'School not found';

  @override
  String get invalidCredentials => 'Invalid username or password';

  @override
  String get timetable => 'Timetable';

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';

  @override
  String get exportTimetable => 'Export timetable';

  @override
  String get notificationSettings => 'Notification settings';

  @override
  String get switchSchoolOrLogout => 'Switch school / Sign out';

  @override
  String get noTimetableData => 'No timetable data';

  @override
  String get advancedCanEditHint => 'Upgrade to advanced to edit timetable';

  @override
  String get noCourse => 'No courses';

  @override
  String get edit => 'Edit';

  @override
  String get featureInDevelopment => 'This feature is under development';
}
