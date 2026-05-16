import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// Application name in English
  ///
  /// In en, this message translates to:
  /// **'Lumaris'**
  String get appName;

  /// Subtitle shown on the login page
  ///
  /// In en, this message translates to:
  /// **'Sign in to view your timetable'**
  String get appSubtitle;

  /// Label for school selector dropdown
  ///
  /// In en, this message translates to:
  /// **'Select School'**
  String get selectSchool;

  /// Placeholder text for school search input
  ///
  /// In en, this message translates to:
  /// **'Search school name...'**
  String get searchSchoolHint;

  /// Label for advanced support level
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get supportLevelAdvanced;

  /// Label for basic support level
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get supportLevelBasic;

  /// Description of advanced support level
  ///
  /// In en, this message translates to:
  /// **'Advanced support'**
  String get supportLevelAdvancedDesc;

  /// Description of basic support level
  ///
  /// In en, this message translates to:
  /// **'Basic support'**
  String get supportLevelBasicDesc;

  /// Info text when advanced school is selected
  ///
  /// In en, this message translates to:
  /// **'{schoolName} — Advanced: view, edit, export timetable, notifications'**
  String supportLevelAdvancedInfo(String schoolName);

  /// Info text when basic school is selected
  ///
  /// In en, this message translates to:
  /// **'{schoolName} — Basic: view timetable only'**
  String supportLevelBasicInfo(String schoolName);

  /// Label for username input field
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Placeholder for username input
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get usernameHint;

  /// Validation error when username is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get usernameRequired;

  /// Label for password input field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Placeholder for password input
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// Validation error when password is too short
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 3 characters'**
  String get passwordTooShort;

  /// Text on the login button
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get login;

  /// Generic login failure message
  ///
  /// In en, this message translates to:
  /// **'Sign in failed'**
  String get loginFailed;

  /// Reminder when user tries to login without selecting a school
  ///
  /// In en, this message translates to:
  /// **'Please select a school first'**
  String get pleaseSelectSchool;

  /// Error when the selected school is not in the system
  ///
  /// In en, this message translates to:
  /// **'School not found'**
  String get schoolNotFound;

  /// Error when login credentials are wrong
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get invalidCredentials;

  /// Default title for the home screen
  ///
  /// In en, this message translates to:
  /// **'Timetable'**
  String get timetable;

  /// Monday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// Tuesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// Wednesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// Thursday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// Friday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// Saturday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// Sunday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// Tooltip for export timetable button
  ///
  /// In en, this message translates to:
  /// **'Export timetable'**
  String get exportTimetable;

  /// Tooltip for notification settings button
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get notificationSettings;

  /// Tooltip for logout button
  ///
  /// In en, this message translates to:
  /// **'Switch school / Sign out'**
  String get switchSchoolOrLogout;

  /// Message shown when timetable is empty
  ///
  /// In en, this message translates to:
  /// **'No timetable data'**
  String get noTimetableData;

  /// Hint shown to users with basic support
  ///
  /// In en, this message translates to:
  /// **'Upgrade to advanced to edit timetable'**
  String get advancedCanEditHint;

  /// Placeholder for days with no courses
  ///
  /// In en, this message translates to:
  /// **'No courses'**
  String get noCourse;

  /// Tooltip for edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Message shown for features not yet implemented
  ///
  /// In en, this message translates to:
  /// **'This feature is under development'**
  String get featureInDevelopment;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
