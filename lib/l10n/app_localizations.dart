import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ru.dart';
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
/// import 'l10n/app_localizations.dart';
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
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('ru'),
    Locale('zh')
  ];

  /// No description provided for @appName.
  ///
  /// In zh, this message translates to:
  /// **'光序'**
  String get appName;

  /// No description provided for @appSlogan.
  ///
  /// In zh, this message translates to:
  /// **'试着把大学囊括其中'**
  String get appSlogan;

  /// No description provided for @tagline.
  ///
  /// In zh, this message translates to:
  /// **'致力于为建大学子提供更好的服务'**
  String get tagline;

  /// No description provided for @home.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get home;

  /// No description provided for @schedule.
  ///
  /// In zh, this message translates to:
  /// **'课表'**
  String get schedule;

  /// No description provided for @score.
  ///
  /// In zh, this message translates to:
  /// **'成绩'**
  String get score;

  /// No description provided for @profile.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get profile;

  /// No description provided for @electricity.
  ///
  /// In zh, this message translates to:
  /// **'电费'**
  String get electricity;

  /// No description provided for @schoolBus.
  ///
  /// In zh, this message translates to:
  /// **'校车'**
  String get schoolBus;

  /// No description provided for @payment.
  ///
  /// In zh, this message translates to:
  /// **'饭卡'**
  String get payment;

  /// No description provided for @map.
  ///
  /// In zh, this message translates to:
  /// **'地图'**
  String get map;

  /// No description provided for @settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// No description provided for @basicSettings.
  ///
  /// In zh, this message translates to:
  /// **'基本设置'**
  String get basicSettings;

  /// No description provided for @version.
  ///
  /// In zh, this message translates to:
  /// **'版本'**
  String get version;

  /// No description provided for @widgets.
  ///
  /// In zh, this message translates to:
  /// **'小组件'**
  String get widgets;

  /// No description provided for @about.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get about;

  /// No description provided for @other.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get other;

  /// No description provided for @refreshData.
  ///
  /// In zh, this message translates to:
  /// **'刷新数据'**
  String get refreshData;

  /// No description provided for @refreshingData.
  ///
  /// In zh, this message translates to:
  /// **'正在刷新数据...'**
  String get refreshingData;

  /// No description provided for @refreshDataSuccess.
  ///
  /// In zh, this message translates to:
  /// **'刷新数据成功'**
  String get refreshDataSuccess;

  /// No description provided for @refreshDataFailed.
  ///
  /// In zh, this message translates to:
  /// **'刷新数据失败'**
  String get refreshDataFailed;

  /// No description provided for @appearance.
  ///
  /// In zh, this message translates to:
  /// **'外观'**
  String get appearance;

  /// No description provided for @followSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get followSystem;

  /// No description provided for @light.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get dark;

  /// No description provided for @language.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  /// No description provided for @systemLanguage.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get systemLanguage;

  /// No description provided for @simplifiedChinese.
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get simplifiedChinese;

  /// No description provided for @english.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @japanese.
  ///
  /// In zh, this message translates to:
  /// **'日本語'**
  String get japanese;

  /// No description provided for @russian.
  ///
  /// In zh, this message translates to:
  /// **'Русский'**
  String get russian;

  /// No description provided for @french.
  ///
  /// In zh, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @german.
  ///
  /// In zh, this message translates to:
  /// **'Deutsch'**
  String get german;

  /// No description provided for @korean.
  ///
  /// In zh, this message translates to:
  /// **'한국어'**
  String get korean;

  /// No description provided for @team.
  ///
  /// In zh, this message translates to:
  /// **'制作团队'**
  String get team;

  /// No description provided for @teamName.
  ///
  /// In zh, this message translates to:
  /// **'Lumaris Team'**
  String get teamName;

  /// No description provided for @openSourceLicense.
  ///
  /// In zh, this message translates to:
  /// **'开源协议'**
  String get openSourceLicense;

  /// No description provided for @mitLicense.
  ///
  /// In zh, this message translates to:
  /// **'MIT License'**
  String get mitLicense;

  /// No description provided for @privacyPolicy.
  ///
  /// In zh, this message translates to:
  /// **'隐私协议'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'了解我们如何保护你的隐私'**
  String get privacyPolicySubtitle;

  /// No description provided for @userAgreement.
  ///
  /// In zh, this message translates to:
  /// **'用户协议'**
  String get userAgreement;

  /// No description provided for @userAgreementSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'使用本应用即表示你同意本协议'**
  String get userAgreementSubtitle;

  /// No description provided for @clearCache.
  ///
  /// In zh, this message translates to:
  /// **'清除缓存'**
  String get clearCache;

  /// No description provided for @clearingCache.
  ///
  /// In zh, this message translates to:
  /// **'正在清除缓存...'**
  String get clearingCache;

  /// No description provided for @cacheCleared.
  ///
  /// In zh, this message translates to:
  /// **'缓存清除成功'**
  String get cacheCleared;

  /// No description provided for @confirmClearCacheTitle.
  ///
  /// In zh, this message translates to:
  /// **'确定清除缓存吗？'**
  String get confirmClearCacheTitle;

  /// No description provided for @confirmClearCacheContent.
  ///
  /// In zh, this message translates to:
  /// **'这将删除所有缓存的数据，下次打开应用需要重新加载数据'**
  String get confirmClearCacheContent;

  /// No description provided for @logoutEduSystem.
  ///
  /// In zh, this message translates to:
  /// **'退出教务系统'**
  String get logoutEduSystem;

  /// No description provided for @confirmLogoutTitle.
  ///
  /// In zh, this message translates to:
  /// **'确定退出登录吗？'**
  String get confirmLogoutTitle;

  /// No description provided for @confirmLogoutContent.
  ///
  /// In zh, this message translates to:
  /// **'退出后需要重新登录才能访问教务系统数据'**
  String get confirmLogoutContent;

  /// No description provided for @logout.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get logout;

  /// No description provided for @showCourseGrid.
  ///
  /// In zh, this message translates to:
  /// **'显示课表网格线'**
  String get showCourseGrid;

  /// No description provided for @agreementAuthDebug.
  ///
  /// In zh, this message translates to:
  /// **'协议授权状态 [Debug]'**
  String get agreementAuthDebug;

  /// No description provided for @agreementAuthDebugSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'关闭后下次启动将重新显示授权页'**
  String get agreementAuthDebugSubtitle;

  /// No description provided for @addToDesktop.
  ///
  /// In zh, this message translates to:
  /// **'添加到桌面'**
  String get addToDesktop;

  /// No description provided for @widgetSetupTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加小组件到桌面'**
  String get widgetSetupTitle;

  /// No description provided for @widgetSetupIntro.
  ///
  /// In zh, this message translates to:
  /// **'请按照以下步骤操作：'**
  String get widgetSetupIntro;

  /// No description provided for @widgetSetupStep1.
  ///
  /// In zh, this message translates to:
  /// **'长按手机桌面空白处'**
  String get widgetSetupStep1;

  /// No description provided for @widgetSetupStep2.
  ///
  /// In zh, this message translates to:
  /// **'点击“小组件”或“Widgets”选项'**
  String get widgetSetupStep2;

  /// No description provided for @widgetSetupStep3.
  ///
  /// In zh, this message translates to:
  /// **'找到“光序”并选择合适的小组件'**
  String get widgetSetupStep3;

  /// No description provided for @widgetSetupStep4.
  ///
  /// In zh, this message translates to:
  /// **'将小组件拖拽到桌面合适位置'**
  String get widgetSetupStep4;

  /// No description provided for @widgetSetupTip.
  ///
  /// In zh, this message translates to:
  /// **'提示：小组件可以显示今日课程等信息，方便快速查看'**
  String get widgetSetupTip;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get confirm;

  /// No description provided for @back.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get back;

  /// No description provided for @collapseSidebar.
  ///
  /// In zh, this message translates to:
  /// **'收起侧边栏'**
  String get collapseSidebar;

  /// No description provided for @expandSidebar.
  ///
  /// In zh, this message translates to:
  /// **'展开侧边栏'**
  String get expandSidebar;

  /// No description provided for @notLoggedIn.
  ///
  /// In zh, this message translates to:
  /// **'未登录'**
  String get notLoggedIn;

  /// No description provided for @academicSystem.
  ///
  /// In zh, this message translates to:
  /// **'教务系统'**
  String get academicSystem;

  /// No description provided for @clickToLogin.
  ///
  /// In zh, this message translates to:
  /// **'点击登录'**
  String get clickToLogin;

  /// No description provided for @closeWindow.
  ///
  /// In zh, this message translates to:
  /// **'关闭窗口'**
  String get closeWindow;

  /// No description provided for @closeWindowChoice.
  ///
  /// In zh, this message translates to:
  /// **'选择您要执行的操作'**
  String get closeWindowChoice;

  /// No description provided for @minimizeToTray.
  ///
  /// In zh, this message translates to:
  /// **'最小化到任务栏'**
  String get minimizeToTray;

  /// No description provided for @quitApp.
  ///
  /// In zh, this message translates to:
  /// **'退出程序'**
  String get quitApp;

  /// No description provided for @goToSettings.
  ///
  /// In zh, this message translates to:
  /// **'去设置'**
  String get goToSettings;

  /// No description provided for @goAuthorize.
  ///
  /// In zh, this message translates to:
  /// **'去授权'**
  String get goAuthorize;

  /// No description provided for @permissionRequired.
  ///
  /// In zh, this message translates to:
  /// **'需要权限'**
  String get permissionRequired;

  /// No description provided for @permissionRequiredContent.
  ///
  /// In zh, this message translates to:
  /// **'该功能需要您授予相应权限才能正常使用'**
  String get permissionRequiredContent;

  /// No description provided for @permissionDenied.
  ///
  /// In zh, this message translates to:
  /// **'权限已拒绝'**
  String get permissionDenied;

  /// No description provided for @permissionDeniedContent.
  ///
  /// In zh, this message translates to:
  /// **'该权限已被永久拒绝，请前往系统设置手动开启'**
  String get permissionDeniedContent;

  /// No description provided for @updateAvailable.
  ///
  /// In zh, this message translates to:
  /// **'有新版本了！'**
  String get updateAvailable;

  /// No description provided for @ignoreThisUpdate.
  ///
  /// In zh, this message translates to:
  /// **'忽略本次更新'**
  String get ignoreThisUpdate;

  /// No description provided for @ignoreAllUpdates.
  ///
  /// In zh, this message translates to:
  /// **'忽略所有更新'**
  String get ignoreAllUpdates;

  /// No description provided for @goToBrowserUpdate.
  ///
  /// In zh, this message translates to:
  /// **'前往浏览器更新'**
  String get goToBrowserUpdate;

  /// No description provided for @goToBrowser.
  ///
  /// In zh, this message translates to:
  /// **'前往浏览器'**
  String get goToBrowser;

  /// No description provided for @dontUpdate.
  ///
  /// In zh, this message translates to:
  /// **'暂不更新'**
  String get dontUpdate;

  /// No description provided for @confirmUpdateTitle.
  ///
  /// In zh, this message translates to:
  /// **'是否更新最新版本: {version}'**
  String confirmUpdateTitle(Object version);

  /// No description provided for @confirmUpdateContent.
  ///
  /// In zh, this message translates to:
  /// **'发现新版本可用，将在浏览器中打开下载链接，是否继续？'**
  String get confirmUpdateContent;

  /// No description provided for @updateLog.
  ///
  /// In zh, this message translates to:
  /// **'更新日志'**
  String get updateLog;

  /// No description provided for @ignoreVersionUpdate.
  ///
  /// In zh, this message translates to:
  /// **'忽略版本更新'**
  String get ignoreVersionUpdate;

  /// No description provided for @updateOpened.
  ///
  /// In zh, this message translates to:
  /// **'已打开浏览器，请在浏览器中下载安装更新'**
  String get updateOpened;

  /// No description provided for @openUpdateFailed.
  ///
  /// In zh, this message translates to:
  /// **'打开更新链接失败'**
  String get openUpdateFailed;

  /// No description provided for @loginRequired.
  ///
  /// In zh, this message translates to:
  /// **'请先登录'**
  String get loginRequired;

  /// No description provided for @pleaseLoginEduAccount.
  ///
  /// In zh, this message translates to:
  /// **'请先登录教务处账号'**
  String get pleaseLoginEduAccount;

  /// No description provided for @loadFailedTapRetry.
  ///
  /// In zh, this message translates to:
  /// **'加载失败，点击重试'**
  String get loadFailedTapRetry;

  /// No description provided for @empty.
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get empty;

  /// No description provided for @loading.
  ///
  /// In zh, this message translates to:
  /// **'加载中'**
  String get loading;

  /// No description provided for @syncingData.
  ///
  /// In zh, this message translates to:
  /// **'正在同步数据'**
  String get syncingData;

  /// No description provided for @syncingDataSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'网络较慢时可能需要几秒，请稍等一下'**
  String get syncingDataSubtitle;

  /// No description provided for @creditOverview.
  ///
  /// In zh, this message translates to:
  /// **'学分概览'**
  String get creditOverview;

  /// No description provided for @completionRate.
  ///
  /// In zh, this message translates to:
  /// **'完成度'**
  String get completionRate;

  /// No description provided for @itemizedCredits.
  ///
  /// In zh, this message translates to:
  /// **'分项学分'**
  String get itemizedCredits;

  /// No description provided for @courseConflict.
  ///
  /// In zh, this message translates to:
  /// **'当前时间存在多个冲突课程'**
  String get courseConflict;

  /// No description provided for @networkError.
  ///
  /// In zh, this message translates to:
  /// **'网络连接失败，请检查网络设置'**
  String get networkError;

  /// No description provided for @requestTimeout.
  ///
  /// In zh, this message translates to:
  /// **'请求超时，请检查网络连接'**
  String get requestTimeout;

  /// No description provided for @serverError.
  ///
  /// In zh, this message translates to:
  /// **'服务器错误，请稍后重试'**
  String get serverError;

  /// No description provided for @unknownError.
  ///
  /// In zh, this message translates to:
  /// **'未知错误，请重试'**
  String get unknownError;

  /// No description provided for @agreementWelcomeTitle.
  ///
  /// In zh, this message translates to:
  /// **'欢迎使用 光序'**
  String get agreementWelcomeTitle;

  /// No description provided for @agreementDescription.
  ///
  /// In zh, this message translates to:
  /// **'在使用本应用前，请仔细阅读并同意以下协议。我们将严格遵守相关法律法规，保护您的个人信息安全。'**
  String get agreementDescription;

  /// No description provided for @agreementPrivacyDescription.
  ///
  /// In zh, this message translates to:
  /// **'了解我们如何收集、使用和保护你的个人信息'**
  String get agreementPrivacyDescription;

  /// No description provided for @agreementUserDescription.
  ///
  /// In zh, this message translates to:
  /// **'了解使用本应用的权利、义务和免责条款'**
  String get agreementUserDescription;

  /// No description provided for @agreementReadTip.
  ///
  /// In zh, this message translates to:
  /// **'点击上方卡片可查看协议全文。继续使用即表示你已阅读并同意以上协议。'**
  String get agreementReadTip;

  /// No description provided for @agreeAndContinue.
  ///
  /// In zh, this message translates to:
  /// **'同意并继续'**
  String get agreeAndContinue;

  /// No description provided for @disagree.
  ///
  /// In zh, this message translates to:
  /// **'不同意'**
  String get disagree;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In zh, this message translates to:
  /// **'光序 隐私协议'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyUpdatedAt.
  ///
  /// In zh, this message translates to:
  /// **'更新日期：2026年5月5日'**
  String get privacyPolicyUpdatedAt;

  /// No description provided for @privacyPolicyEffectiveAt.
  ///
  /// In zh, this message translates to:
  /// **'生效日期：2026年5月5日'**
  String get privacyPolicyEffectiveAt;

  /// No description provided for @privacyPolicyIntro.
  ///
  /// In zh, this message translates to:
  /// **'欢迎使用 光序（以下简称“本应用”）。本应用由 Lumaris Team（以下简称“我们”）开发和运营。我们深知个人信息对您的重要性，将严格遵守法律法规，遵循合法、正当、必要和诚信原则，保护您的个人信息安全。本隐私协议旨在向您说明我们如何收集、使用、存储和保护您的个人信息，以及您享有的相关权利。请您在使用本应用前仔细阅读本隐私协议。'**
  String get privacyPolicyIntro;

  /// No description provided for @privacySection1Title.
  ///
  /// In zh, this message translates to:
  /// **'一、我们收集的信息'**
  String get privacySection1Title;

  /// No description provided for @privacySection1_1.
  ///
  /// In zh, this message translates to:
  /// **'1.1 账号信息：当您使用教务系统登录功能时，我们需要收集您的学号和密码，用于验证您的身份并获取教务系统数据。这些信息仅存储在您的设备本地，我们不会上传至任何服务器。'**
  String get privacySection1_1;

  /// No description provided for @privacySection1_2.
  ///
  /// In zh, this message translates to:
  /// **'1.2 课程与成绩信息：在您授权登录后，本应用会从学校教务系统获取您的课程表、考试成绩、培养方案等教育相关数据，并在您的设备本地进行存储和展示。'**
  String get privacySection1_2;

  /// No description provided for @privacySection1_3.
  ///
  /// In zh, this message translates to:
  /// **'1.3 校园生活信息：在您使用相关功能时，本应用会从学校相关系统获取您的电费余额、饭卡消费记录、校园网流量使用情况等信息，并在您的设备本地进行存储和展示。'**
  String get privacySection1_3;

  /// No description provided for @privacySection1_4.
  ///
  /// In zh, this message translates to:
  /// **'1.4 设备信息：为提供更好的服务体验，本应用可能收集您的设备型号、操作系统版本、设备标识符等信息，用于统计分析和问题排查。'**
  String get privacySection1_4;

  /// No description provided for @privacySection1_5.
  ///
  /// In zh, this message translates to:
  /// **'1.5 缓存数据：为提高应用响应速度，本应用会在您的设备上缓存部分数据，包括课程信息、成绩数据、网络请求响应等。您可以在设置中随时清除这些缓存。'**
  String get privacySection1_5;

  /// No description provided for @privacySection2Title.
  ///
  /// In zh, this message translates to:
  /// **'二、我们如何使用信息'**
  String get privacySection2Title;

  /// No description provided for @privacySection2_1.
  ///
  /// In zh, this message translates to:
  /// **'2.1 为您提供核心服务：我们使用您的学号和密码向学校教务系统进行身份认证，以获取并展示您的课程、成绩等信息。'**
  String get privacySection2_1;

  /// No description provided for @privacySection2_2.
  ///
  /// In zh, this message translates to:
  /// **'2.2 改善服务质量：我们可能使用设备信息和应用使用统计数据来分析和优化应用性能，提升用户体验。'**
  String get privacySection2_2;

  /// No description provided for @privacySection2_3.
  ///
  /// In zh, this message translates to:
  /// **'2.3 桌面小组件：如果您使用桌面小组件功能，本应用会在设备本地存储必要的课程数据以支持小组件的正常显示。'**
  String get privacySection2_3;

  /// No description provided for @privacySection2_4.
  ///
  /// In zh, this message translates to:
  /// **'2.4 通知提醒：如果您开启了课程提醒功能，本应用会在您的设备上设置本地通知，以在上课前提醒您。此功能完全在设备本地完成，不涉及数据传输。'**
  String get privacySection2_4;

  /// No description provided for @privacySection3Title.
  ///
  /// In zh, this message translates to:
  /// **'三、信息的存储与安全'**
  String get privacySection3Title;

  /// No description provided for @privacySection3_1.
  ///
  /// In zh, this message translates to:
  /// **'3.1 本地存储：您的个人信息（包括学号、密码、课程数据、成绩等）均存储在您的设备本地，我们不会将这些信息上传至我们的服务器。'**
  String get privacySection3_1;

  /// No description provided for @privacySection3_2.
  ///
  /// In zh, this message translates to:
  /// **'3.2 传输安全：本应用与学校服务器之间的数据传输采用加密通信，确保您的信息在传输过程中的安全性。'**
  String get privacySection3_2;

  /// No description provided for @privacySection3_3.
  ///
  /// In zh, this message translates to:
  /// **'3.3 数据清除：您可以随时在设置中清除缓存数据，或通过退出登录来清除账号相关数据。卸载应用将删除本应用存储在您设备上的所有数据。'**
  String get privacySection3_3;

  /// No description provided for @privacySection4Title.
  ///
  /// In zh, this message translates to:
  /// **'四、第三方服务'**
  String get privacySection4Title;

  /// No description provided for @privacySection4_1.
  ///
  /// In zh, this message translates to:
  /// **'4.1 学校教务系统：本应用需要与西安建筑科技大学教务系统进行数据交互，以获取课程、成绩等信息。您的登录凭据仅在您的设备与学校服务器之间传输。'**
  String get privacySection4_1;

  /// No description provided for @privacySection4_2.
  ///
  /// In zh, this message translates to:
  /// **'4.2 应用更新服务：本应用通过 Gitee 平台检查版本更新信息，此过程中不会传输您的个人信息。'**
  String get privacySection4_2;

  /// No description provided for @privacySection4_3.
  ///
  /// In zh, this message translates to:
  /// **'4.3 本应用不会将您的个人信息分享、出售或出租给任何第三方。'**
  String get privacySection4_3;

  /// No description provided for @privacySection5Title.
  ///
  /// In zh, this message translates to:
  /// **'五、您的权利'**
  String get privacySection5Title;

  /// No description provided for @privacySection5_1.
  ///
  /// In zh, this message translates to:
  /// **'5.1 访问和更正：您可以在应用内直接查看和更正您的个人信息。'**
  String get privacySection5_1;

  /// No description provided for @privacySection5_2.
  ///
  /// In zh, this message translates to:
  /// **'5.2 删除数据：您可以通过退出登录、清除缓存或卸载应用来删除您的数据。'**
  String get privacySection5_2;

  /// No description provided for @privacySection5_3.
  ///
  /// In zh, this message translates to:
  /// **'5.3 撤回同意：您可以通过退出登录或卸载应用来撤回对本隐私协议的同意。但撤回同意不影响撤回前基于您同意已进行的个人信息处理活动的效力。'**
  String get privacySection5_3;

  /// No description provided for @privacySection6Title.
  ///
  /// In zh, this message translates to:
  /// **'六、未成年人保护'**
  String get privacySection6Title;

  /// No description provided for @privacySection6_1.
  ///
  /// In zh, this message translates to:
  /// **'6.1 本应用主要面向高等院校在校学生。如果您是未满18周岁的未成年人，请在监护人指导下使用本应用。'**
  String get privacySection6_1;

  /// No description provided for @privacySection6_2.
  ///
  /// In zh, this message translates to:
  /// **'6.2 我们不会主动收集未成年人的个人信息。如您发现我们在未获监护人同意的情况下收集了未成年人的个人信息，请联系我们进行删除。'**
  String get privacySection6_2;

  /// No description provided for @privacySection7Title.
  ///
  /// In zh, this message translates to:
  /// **'七、隐私协议的更新'**
  String get privacySection7Title;

  /// No description provided for @privacySection7_1.
  ///
  /// In zh, this message translates to:
  /// **'7.1 我们可能会适时更新本隐私协议。更新后的协议将在应用内发布，并在重大变更时通过应用内通知提醒您。'**
  String get privacySection7_1;

  /// No description provided for @privacySection7_2.
  ///
  /// In zh, this message translates to:
  /// **'7.2 请您定期查看本隐私协议，以了解我们如何保护您的信息。如您在协议更新后继续使用本应用，即视为您同意更新后的隐私协议。'**
  String get privacySection7_2;

  /// No description provided for @privacySection8Title.
  ///
  /// In zh, this message translates to:
  /// **'八、联系我们'**
  String get privacySection8Title;

  /// No description provided for @privacySection8_1.
  ///
  /// In zh, this message translates to:
  /// **'如果您对本隐私协议或个人信息保护有任何疑问、意见或建议，请通过以下方式联系我们：'**
  String get privacySection8_1;

  /// No description provided for @privacyContact.
  ///
  /// In zh, this message translates to:
  /// **'开发团队：Lumaris Team\n代码仓库：https://gitee.com/luckyfishisdashen/iOSClub.AppMobile'**
  String get privacyContact;

  /// No description provided for @userAgreementTitle.
  ///
  /// In zh, this message translates to:
  /// **'光序 用户协议'**
  String get userAgreementTitle;

  /// No description provided for @userAgreementUpdatedAt.
  ///
  /// In zh, this message translates to:
  /// **'更新日期：2026年5月5日'**
  String get userAgreementUpdatedAt;

  /// No description provided for @userAgreementEffectiveAt.
  ///
  /// In zh, this message translates to:
  /// **'生效日期：2026年5月5日'**
  String get userAgreementEffectiveAt;

  /// No description provided for @userAgreementIntro.
  ///
  /// In zh, this message translates to:
  /// **'欢迎使用 光序（以下简称“本应用”）。本应用由 Lumaris Team（以下简称“我们”）开发和运营。请您在使用本应用前仔细阅读本用户协议（以下简称“本协议”）。您使用本应用即表示您已阅读、理解并同意接受本协议的全部内容。如果您不同意本协议的任何条款，请停止使用本应用。'**
  String get userAgreementIntro;

  /// No description provided for @userAgreementSection1Title.
  ///
  /// In zh, this message translates to:
  /// **'一、服务说明'**
  String get userAgreementSection1Title;

  /// No description provided for @userAgreementSection1_1.
  ///
  /// In zh, this message translates to:
  /// **'1.1 本应用是西安建筑科技大学 iOS Club 开发的校园助手应用，旨在为在校学生提供便捷的校园信息服务，包括但不限于课程管理、成绩查询、校车时刻、电费查询、饭卡消费记录、校园网流量查询、培养方案查看等功能。'**
  String get userAgreementSection1_1;

  /// No description provided for @userAgreementSection1_2.
  ///
  /// In zh, this message translates to:
  /// **'1.2 本应用的部分功能需要连接学校内部网络才能正常使用。我们不对因网络环境限制导致的功能不可用承担责任。'**
  String get userAgreementSection1_2;

  /// No description provided for @userAgreementSection1_3.
  ///
  /// In zh, this message translates to:
  /// **'1.3 本应用显示的课程、成绩等信息来源于学校教务系统，仅供参考。如有差异，以学校官方系统数据为准。'**
  String get userAgreementSection1_3;

  /// No description provided for @userAgreementSection2Title.
  ///
  /// In zh, this message translates to:
  /// **'二、用户账号与安全'**
  String get userAgreementSection2Title;

  /// No description provided for @userAgreementSection2_1.
  ///
  /// In zh, this message translates to:
  /// **'2.1 您需要使用学校教务系统账号（学号和密码）登录本应用的教务相关功能。您应对自己的账号和密码的安全性负责，妥善保管账号信息。'**
  String get userAgreementSection2_1;

  /// No description provided for @userAgreementSection2_2.
  ///
  /// In zh, this message translates to:
  /// **'2.2 您的登录凭据仅存储在您的设备本地，用于与学校服务器进行身份认证。我们不会收集或上传您的密码至任何第三方服务器。'**
  String get userAgreementSection2_2;

  /// No description provided for @userAgreementSection2_3.
  ///
  /// In zh, this message translates to:
  /// **'2.3 如您发现账号存在安全风险或未经授权的使用，应及时修改密码并通知我们。'**
  String get userAgreementSection2_3;

  /// No description provided for @userAgreementSection3Title.
  ///
  /// In zh, this message translates to:
  /// **'三、用户行为规范'**
  String get userAgreementSection3Title;

  /// No description provided for @userAgreementSection3_1.
  ///
  /// In zh, this message translates to:
  /// **'3.1 您在使用本应用时应遵守中华人民共和国相关法律法规，不得利用本应用从事违法违规活动。'**
  String get userAgreementSection3_1;

  /// No description provided for @userAgreementSection3_2.
  ///
  /// In zh, this message translates to:
  /// **'3.2 您不得对本应用进行反向工程、反向编译、反汇编或以其他方式试图获取本应用的源代码。但本应用作为 MIT 许可证下的开源项目，您可以通过官方代码仓库合法获取源代码。'**
  String get userAgreementSection3_2;

  /// No description provided for @userAgreementSection3_3.
  ///
  /// In zh, this message translates to:
  /// **'3.3 您不得利用任何技术手段干扰本应用的正常运行，包括但不限于网络攻击、数据抓取、恶意注入等行为。'**
  String get userAgreementSection3_3;

  /// No description provided for @userAgreementSection3_4.
  ///
  /// In zh, this message translates to:
  /// **'3.4 您不得利用本应用的功能漏洞获取未经授权的信息或进行非法操作。如发现漏洞，请及时联系我们。'**
  String get userAgreementSection3_4;

  /// No description provided for @userAgreementSection4Title.
  ///
  /// In zh, this message translates to:
  /// **'四、知识产权'**
  String get userAgreementSection4Title;

  /// No description provided for @userAgreementSection4_1.
  ///
  /// In zh, this message translates to:
  /// **'4.1 本应用的源代码基于 MIT 许可证开源发布，您可以在遵守 MIT 许可证的前提下自由使用、修改和分发本应用的源代码。'**
  String get userAgreementSection4_1;

  /// No description provided for @userAgreementSection4_2.
  ///
  /// In zh, this message translates to:
  /// **'4.2 本应用的名称、图标、UI 设计等归 Lumaris Team 所有，未经授权不得用于商业目的。'**
  String get userAgreementSection4_2;

  /// No description provided for @userAgreementSection4_3.
  ///
  /// In zh, this message translates to:
  /// **'4.3 本应用中涉及的学校名称、标识等归西安建筑科技大学所有。'**
  String get userAgreementSection4_3;

  /// No description provided for @userAgreementSection5Title.
  ///
  /// In zh, this message translates to:
  /// **'五、免责声明'**
  String get userAgreementSection5Title;

  /// No description provided for @userAgreementSection5_1.
  ///
  /// In zh, this message translates to:
  /// **'5.1 本应用按“现状”提供，我们不对本应用的准确性、可靠性、完整性、及时性做任何明示或暗示的保证。'**
  String get userAgreementSection5_1;

  /// No description provided for @userAgreementSection5_2.
  ///
  /// In zh, this message translates to:
  /// **'5.2 由于网络故障、系统维护、学校服务器问题或其他不可抗力因素导致的服务中断或数据不准确，我们不承担相关责任。'**
  String get userAgreementSection5_2;

  /// No description provided for @userAgreementSection5_3.
  ///
  /// In zh, this message translates to:
  /// **'5.3 本应用中的课程、成绩等信息仅供参考，最终以学校官方系统数据为准。因依赖本应用数据而产生的任何直接或间接损失，我们不承担责任。'**
  String get userAgreementSection5_3;

  /// No description provided for @userAgreementSection5_4.
  ///
  /// In zh, this message translates to:
  /// **'5.4 我们不对因您使用本应用而导致的设备损坏、数据丢失或其他损害承担责任，除非该等损害是由我们的故意或重大过失造成的。'**
  String get userAgreementSection5_4;

  /// No description provided for @userAgreementSection6Title.
  ///
  /// In zh, this message translates to:
  /// **'六、协议的修改与终止'**
  String get userAgreementSection6Title;

  /// No description provided for @userAgreementSection6_1.
  ///
  /// In zh, this message translates to:
  /// **'6.1 我们保留随时修改本协议的权利。修改后的协议将在应用内发布，重大变更将通过应用内通知告知。'**
  String get userAgreementSection6_1;

  /// No description provided for @userAgreementSection6_2.
  ///
  /// In zh, this message translates to:
  /// **'6.2 如您在协议修改后继续使用本应用，即视为您同意修改后的协议。如您不同意修改后的协议，应停止使用本应用。'**
  String get userAgreementSection6_2;

  /// No description provided for @userAgreementSection6_3.
  ///
  /// In zh, this message translates to:
  /// **'6.3 我们有权在以下情况下终止向您提供服务：（1）您违反本协议的相关约定；（2）因法律法规或政策要求的变更；（3）因学校相关系统政策变更导致无法继续提供服务。'**
  String get userAgreementSection6_3;

  /// No description provided for @userAgreementSection7Title.
  ///
  /// In zh, this message translates to:
  /// **'七、其他条款'**
  String get userAgreementSection7Title;

  /// No description provided for @userAgreementSection7_1.
  ///
  /// In zh, this message translates to:
  /// **'7.1 本协议中的任何条款无论因何种原因完全或部分无效或不具有执行力，其余条款仍应有效并具有约束力。'**
  String get userAgreementSection7_1;

  /// No description provided for @userAgreementSection7_2.
  ///
  /// In zh, this message translates to:
  /// **'7.2 本协议的订立、执行和解释及争议的解决均适用中华人民共和国法律。'**
  String get userAgreementSection7_2;

  /// No description provided for @userAgreementSection7_3.
  ///
  /// In zh, this message translates to:
  /// **'7.3 如您和我们就本协议内容或其执行发生任何争议，应通过友好协商解决；协商不成的，任何一方均可向有管辖权的人民法院提起诉讼。'**
  String get userAgreementSection7_3;

  /// No description provided for @userAgreementSection8Title.
  ///
  /// In zh, this message translates to:
  /// **'八、联系我们'**
  String get userAgreementSection8Title;

  /// No description provided for @userAgreementSection8_1.
  ///
  /// In zh, this message translates to:
  /// **'如果您对本协议有任何疑问、意见或建议，请通过以下方式联系我们：'**
  String get userAgreementSection8_1;

  /// No description provided for @userAgreementContact.
  ///
  /// In zh, this message translates to:
  /// **'开发团队：Lumaris Team\n代码仓库：https://gitee.com/luckyfishisdashen/iOSClub.AppMobile'**
  String get userAgreementContact;

  /// No description provided for @aboutAuthor.
  ///
  /// In zh, this message translates to:
  /// **'关于作者'**
  String get aboutAuthor;

  /// No description provided for @coreTeam.
  ///
  /// In zh, this message translates to:
  /// **'核心团队'**
  String get coreTeam;

  /// No description provided for @specialThanks.
  ///
  /// In zh, this message translates to:
  /// **'特别致谢'**
  String get specialThanks;

  /// No description provided for @contactUs.
  ///
  /// In zh, this message translates to:
  /// **'联系我们'**
  String get contactUs;

  /// No description provided for @thanksTitle.
  ///
  /// In zh, this message translates to:
  /// **'致谢'**
  String get thanksTitle;

  /// No description provided for @thanksContent.
  ///
  /// In zh, this message translates to:
  /// **'感谢所有为本项目贡献代码、提出建议和报告问题的开发者和用户。你们的支持是我们前进的动力。特别感谢所有测试人员在开发阶段的辛勤付出。'**
  String get thanksContent;

  /// No description provided for @githubRepository.
  ///
  /// In zh, this message translates to:
  /// **'GitHub 仓库'**
  String get githubRepository;

  /// No description provided for @joinUs.
  ///
  /// In zh, this message translates to:
  /// **'加入我们'**
  String get joinUs;

  /// No description provided for @madeWithLove.
  ///
  /// In zh, this message translates to:
  /// **'Made with ❤️ in Xi\'an'**
  String get madeWithLove;

  /// No description provided for @easterEggTitle.
  ///
  /// In zh, this message translates to:
  /// **'🎉 彩蛋'**
  String get easterEggTitle;

  /// No description provided for @easterEggFound.
  ///
  /// In zh, this message translates to:
  /// **'恭喜你发现了隐藏彩蛋！'**
  String get easterEggFound;

  /// No description provided for @easterEggContent.
  ///
  /// In zh, this message translates to:
  /// **'你是少数知道这个秘密的人之一！\n\n感谢你对光序的喜爱与支持。\n\n继续探索，也许还有更多惊喜等着你...'**
  String get easterEggContent;

  /// No description provided for @fontSetting.
  ///
  /// In zh, this message translates to:
  /// **'字体设置'**
  String get fontSetting;

  /// No description provided for @fontSettingSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'为桌面平台选择字体(下次打开时才会应用)'**
  String get fontSettingSubtitle;

  /// No description provided for @systemDefault.
  ///
  /// In zh, this message translates to:
  /// **'系统默认'**
  String get systemDefault;

  /// No description provided for @customFont.
  ///
  /// In zh, this message translates to:
  /// **'自定义'**
  String get customFont;

  /// No description provided for @hapticFeedback.
  ///
  /// In zh, this message translates to:
  /// **'触觉反馈'**
  String get hapticFeedback;

  /// No description provided for @hapticFeedbackSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'底部导航栏点击时震动'**
  String get hapticFeedbackSubtitle;

  /// No description provided for @cloudSyncTodo.
  ///
  /// In zh, this message translates to:
  /// **'是否将待办保存至云端'**
  String get cloudSyncTodo;

  /// No description provided for @servicePaused.
  ///
  /// In zh, this message translates to:
  /// **'该服务已暂停'**
  String get servicePaused;

  /// No description provided for @showTomorrowCourses.
  ///
  /// In zh, this message translates to:
  /// **'显示明日课程'**
  String get showTomorrowCourses;

  /// No description provided for @showTomorrowCoursesSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'当今日无课时显示明日课程'**
  String get showTomorrowCoursesSubtitle;

  /// No description provided for @courseReminder.
  ///
  /// In zh, this message translates to:
  /// **'课程通知'**
  String get courseReminder;

  /// No description provided for @courseReminderSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'上课前进行提醒'**
  String get courseReminderSubtitle;

  /// No description provided for @remindMinutesBefore.
  ///
  /// In zh, this message translates to:
  /// **'提前几分钟提醒'**
  String get remindMinutesBefore;

  /// No description provided for @remindMinutes.
  ///
  /// In zh, this message translates to:
  /// **'{n}分钟'**
  String remindMinutes(Object n);

  /// No description provided for @todoReminder.
  ///
  /// In zh, this message translates to:
  /// **'待办事务提醒'**
  String get todoReminder;

  /// No description provided for @todoReminderSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'在待办事务截止前进行提醒'**
  String get todoReminderSubtitle;

  /// No description provided for @schedulePage.
  ///
  /// In zh, this message translates to:
  /// **'课程页'**
  String get schedulePage;

  /// No description provided for @scorePage.
  ///
  /// In zh, this message translates to:
  /// **'成绩页'**
  String get scorePage;

  /// No description provided for @profilePage.
  ///
  /// In zh, this message translates to:
  /// **'个人页'**
  String get profilePage;

  /// No description provided for @firstPageOnLaunch.
  ///
  /// In zh, this message translates to:
  /// **'打开应用的第一个页面'**
  String get firstPageOnLaunch;

  /// No description provided for @sunday.
  ///
  /// In zh, this message translates to:
  /// **'周日'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In zh, this message translates to:
  /// **'周一'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In zh, this message translates to:
  /// **'周二'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In zh, this message translates to:
  /// **'周三'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In zh, this message translates to:
  /// **'周四'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In zh, this message translates to:
  /// **'周五'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In zh, this message translates to:
  /// **'周六'**
  String get saturday;

  /// No description provided for @sundayShort.
  ///
  /// In zh, this message translates to:
  /// **'日'**
  String get sundayShort;

  /// No description provided for @mondayShort.
  ///
  /// In zh, this message translates to:
  /// **'一'**
  String get mondayShort;

  /// No description provided for @tuesdayShort.
  ///
  /// In zh, this message translates to:
  /// **'二'**
  String get tuesdayShort;

  /// No description provided for @wednesdayShort.
  ///
  /// In zh, this message translates to:
  /// **'三'**
  String get wednesdayShort;

  /// No description provided for @thursdayShort.
  ///
  /// In zh, this message translates to:
  /// **'四'**
  String get thursdayShort;

  /// No description provided for @fridayShort.
  ///
  /// In zh, this message translates to:
  /// **'五'**
  String get fridayShort;

  /// No description provided for @saturdayShort.
  ///
  /// In zh, this message translates to:
  /// **'六'**
  String get saturdayShort;

  /// No description provided for @janShort.
  ///
  /// In zh, this message translates to:
  /// **'1月'**
  String get janShort;

  /// No description provided for @febShort.
  ///
  /// In zh, this message translates to:
  /// **'2月'**
  String get febShort;

  /// No description provided for @marShort.
  ///
  /// In zh, this message translates to:
  /// **'3月'**
  String get marShort;

  /// No description provided for @aprShort.
  ///
  /// In zh, this message translates to:
  /// **'4月'**
  String get aprShort;

  /// No description provided for @mayShort.
  ///
  /// In zh, this message translates to:
  /// **'5月'**
  String get mayShort;

  /// No description provided for @junShort.
  ///
  /// In zh, this message translates to:
  /// **'6月'**
  String get junShort;

  /// No description provided for @julShort.
  ///
  /// In zh, this message translates to:
  /// **'7月'**
  String get julShort;

  /// No description provided for @augShort.
  ///
  /// In zh, this message translates to:
  /// **'8月'**
  String get augShort;

  /// No description provided for @sepShort.
  ///
  /// In zh, this message translates to:
  /// **'9月'**
  String get sepShort;

  /// No description provided for @octShort.
  ///
  /// In zh, this message translates to:
  /// **'10月'**
  String get octShort;

  /// No description provided for @novShort.
  ///
  /// In zh, this message translates to:
  /// **'11月'**
  String get novShort;

  /// No description provided for @decShort.
  ///
  /// In zh, this message translates to:
  /// **'12月'**
  String get decShort;

  /// No description provided for @weekUnit.
  ///
  /// In zh, this message translates to:
  /// **'{n}周'**
  String weekUnit(Object n);

  /// No description provided for @currentWeek.
  ///
  /// In zh, this message translates to:
  /// **'当前为第{n}周'**
  String currentWeek(Object n);

  /// No description provided for @weeksUntilStart.
  ///
  /// In zh, this message translates to:
  /// **'距离开学还有{n}周'**
  String weeksUntilStart(Object n);

  /// No description provided for @periodRange.
  ///
  /// In zh, this message translates to:
  /// **'第{start}-{end}节'**
  String periodRange(Object end, Object start);

  /// No description provided for @allSchedules.
  ///
  /// In zh, this message translates to:
  /// **'全部课表'**
  String get allSchedules;

  /// No description provided for @previousWeek.
  ///
  /// In zh, this message translates to:
  /// **'上一周'**
  String get previousWeek;

  /// No description provided for @nextWeek.
  ///
  /// In zh, this message translates to:
  /// **'下一周'**
  String get nextWeek;

  /// No description provided for @switchStyle.
  ///
  /// In zh, this message translates to:
  /// **'切换样式'**
  String get switchStyle;

  /// No description provided for @refreshSchedule.
  ///
  /// In zh, this message translates to:
  /// **'刷新课表'**
  String get refreshSchedule;

  /// No description provided for @scheduleSettingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'课表设置'**
  String get scheduleSettingsTitle;

  /// No description provided for @compact.
  ///
  /// In zh, this message translates to:
  /// **'紧凑'**
  String get compact;

  /// No description provided for @standard.
  ///
  /// In zh, this message translates to:
  /// **'标准'**
  String get standard;

  /// No description provided for @relaxed.
  ///
  /// In zh, this message translates to:
  /// **'宽松'**
  String get relaxed;

  /// No description provided for @selectCourse.
  ///
  /// In zh, this message translates to:
  /// **'选择要查看的课程'**
  String get selectCourse;

  /// No description provided for @editCourse.
  ///
  /// In zh, this message translates to:
  /// **'编辑课程'**
  String get editCourse;

  /// No description provided for @deleteCourse.
  ///
  /// In zh, this message translates to:
  /// **'删除课程'**
  String get deleteCourse;

  /// No description provided for @confirmDelete.
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteCourseContent.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除课程\"{name}\"吗？'**
  String confirmDeleteCourseContent(Object name);

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @courseModified.
  ///
  /// In zh, this message translates to:
  /// **'课程修改成功'**
  String get courseModified;

  /// No description provided for @courseDeleted.
  ///
  /// In zh, this message translates to:
  /// **'课程删除成功'**
  String get courseDeleted;

  /// No description provided for @deleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除失败'**
  String get deleteFailed;

  /// No description provided for @noLocation.
  ///
  /// In zh, this message translates to:
  /// **'无地点'**
  String get noLocation;

  /// No description provided for @addCourse.
  ///
  /// In zh, this message translates to:
  /// **'添加课程'**
  String get addCourse;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @courseName.
  ///
  /// In zh, this message translates to:
  /// **'课程名称'**
  String get courseName;

  /// No description provided for @courseRoom.
  ///
  /// In zh, this message translates to:
  /// **'上课地点'**
  String get courseRoom;

  /// No description provided for @courseTeacher.
  ///
  /// In zh, this message translates to:
  /// **'授课教师'**
  String get courseTeacher;

  /// No description provided for @courseCredits.
  ///
  /// In zh, this message translates to:
  /// **'课程学分'**
  String get courseCredits;

  /// No description provided for @courseWeekday.
  ///
  /// In zh, this message translates to:
  /// **'星期几'**
  String get courseWeekday;

  /// No description provided for @courseStartUnit.
  ///
  /// In zh, this message translates to:
  /// **'开始节次'**
  String get courseStartUnit;

  /// No description provided for @courseEndUnit.
  ///
  /// In zh, this message translates to:
  /// **'结束节次'**
  String get courseEndUnit;

  /// No description provided for @courseWeeks.
  ///
  /// In zh, this message translates to:
  /// **'上课周次'**
  String get courseWeeks;

  /// No description provided for @selectedWeeks.
  ///
  /// In zh, this message translates to:
  /// **'已选{count}周'**
  String selectedWeeks(Object count);

  /// No description provided for @customCourses.
  ///
  /// In zh, this message translates to:
  /// **'自定义课程'**
  String get customCourses;

  /// No description provided for @customCoursesCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 门课程'**
  String customCoursesCount(Object count);

  /// No description provided for @noCustomCourses.
  ///
  /// In zh, this message translates to:
  /// **'暂无自定义课程'**
  String get noCustomCourses;

  /// No description provided for @noCustomCoursesSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'点击右上角 + 号添加课程'**
  String get noCustomCoursesSubtitle;

  /// No description provided for @readingCustomCourses.
  ///
  /// In zh, this message translates to:
  /// **'正在读取自定义课程'**
  String get readingCustomCourses;

  /// No description provided for @readingCustomCoursesSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'正在整理本地保存的课程配置'**
  String get readingCustomCoursesSubtitle;

  /// No description provided for @courseAdded.
  ///
  /// In zh, this message translates to:
  /// **'课程添加成功'**
  String get courseAdded;

  /// No description provided for @scoresAndGpa.
  ///
  /// In zh, this message translates to:
  /// **'成绩与绩点'**
  String get scoresAndGpa;

  /// No description provided for @passedCourses.
  ///
  /// In zh, this message translates to:
  /// **'通过课程'**
  String get passedCourses;

  /// No description provided for @totalCredits.
  ///
  /// In zh, this message translates to:
  /// **'总学分'**
  String get totalCredits;

  /// No description provided for @creditInfoTitle.
  ///
  /// In zh, this message translates to:
  /// **'说明'**
  String get creditInfoTitle;

  /// No description provided for @creditInfoContent.
  ///
  /// In zh, this message translates to:
  /// **'这里的学分是按照成绩算出来的，只要没有挂科就OK。教务系统给的一般来说要小于等于这个数'**
  String get creditInfoContent;

  /// No description provided for @noScores.
  ///
  /// In zh, this message translates to:
  /// **'没有成绩'**
  String get noScores;

  /// No description provided for @noScoresSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'建议刷新或退出重进'**
  String get noScoresSubtitle;

  /// No description provided for @refreshDataBtn.
  ///
  /// In zh, this message translates to:
  /// **'刷新数据'**
  String get refreshDataBtn;

  /// No description provided for @goToLogin.
  ///
  /// In zh, this message translates to:
  /// **'前往登录'**
  String get goToLogin;

  /// No description provided for @minorCourse.
  ///
  /// In zh, this message translates to:
  /// **'辅修课程'**
  String get minorCourse;

  /// No description provided for @scoreDetail.
  ///
  /// In zh, this message translates to:
  /// **'成绩详情'**
  String get scoreDetail;

  /// No description provided for @courseCreditLabel.
  ///
  /// In zh, this message translates to:
  /// **'课程学分'**
  String get courseCreditLabel;

  /// No description provided for @courseScoreLabel.
  ///
  /// In zh, this message translates to:
  /// **'课程成绩'**
  String get courseScoreLabel;

  /// No description provided for @courseGpaLabel.
  ///
  /// In zh, this message translates to:
  /// **'课程绩点'**
  String get courseGpaLabel;

  /// No description provided for @fetchingScores.
  ///
  /// In zh, this message translates to:
  /// **'正在获取成绩数据...'**
  String get fetchingScores;

  /// No description provided for @refreshFailedFallback.
  ///
  /// In zh, this message translates to:
  /// **'刷新失败，已回退到本地数据'**
  String get refreshFailedFallback;

  /// No description provided for @fetchTimeout.
  ///
  /// In zh, this message translates to:
  /// **'获取数据超时，请检查网络连接后重试'**
  String get fetchTimeout;

  /// No description provided for @fetchFailed.
  ///
  /// In zh, this message translates to:
  /// **'获取数据失败'**
  String get fetchFailed;

  /// No description provided for @pleaseLoginFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先去登录即可查看成绩'**
  String get pleaseLoginFirst;

  /// No description provided for @readingScoresSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'正在读取缓存并同步教务成绩，网络较慢时可能需要几秒'**
  String get readingScoresSubtitle;

  /// No description provided for @foolishModeMessage.
  ///
  /// In zh, this message translates to:
  /// **'是的，在下绩点5.0'**
  String get foolishModeMessage;

  /// No description provided for @creditUnit.
  ///
  /// In zh, this message translates to:
  /// **'{credit} 学分'**
  String creditUnit(Object credit);

  /// No description provided for @gradeLabel.
  ///
  /// In zh, this message translates to:
  /// **'成绩 {grade}'**
  String gradeLabel(Object grade);

  /// No description provided for @gpaLabel.
  ///
  /// In zh, this message translates to:
  /// **'绩点 {gpa}'**
  String gpaLabel(Object gpa);

  /// No description provided for @scheduleCourseTime.
  ///
  /// In zh, this message translates to:
  /// **'{weekRanges}周 每周{weekday} 第{start}-{end}节'**
  String scheduleCourseTime(
      Object end, Object start, Object weekRanges, Object weekday);

  /// No description provided for @semesterRange.
  ///
  /// In zh, this message translates to:
  /// **'{start}至{end}年 第{num}学期'**
  String semesterRange(Object end, Object num, Object start);

  /// No description provided for @semesterAutumnShort.
  ///
  /// In zh, this message translates to:
  /// **'上'**
  String get semesterAutumnShort;

  /// No description provided for @semesterSpringShort.
  ///
  /// In zh, this message translates to:
  /// **'下'**
  String get semesterSpringShort;

  /// No description provided for @year1.
  ///
  /// In zh, this message translates to:
  /// **'大一'**
  String get year1;

  /// No description provided for @year2.
  ///
  /// In zh, this message translates to:
  /// **'大二'**
  String get year2;

  /// No description provided for @year3.
  ///
  /// In zh, this message translates to:
  /// **'大三'**
  String get year3;

  /// No description provided for @year4.
  ///
  /// In zh, this message translates to:
  /// **'大四'**
  String get year4;

  /// No description provided for @year5.
  ///
  /// In zh, this message translates to:
  /// **'大五'**
  String get year5;

  /// No description provided for @year6.
  ///
  /// In zh, this message translates to:
  /// **'大六'**
  String get year6;

  /// No description provided for @year7.
  ///
  /// In zh, this message translates to:
  /// **'大七'**
  String get year7;

  /// No description provided for @year8.
  ///
  /// In zh, this message translates to:
  /// **'大八'**
  String get year8;

  /// No description provided for @year9.
  ///
  /// In zh, this message translates to:
  /// **'大九'**
  String get year9;

  /// No description provided for @year10.
  ///
  /// In zh, this message translates to:
  /// **'大十'**
  String get year10;

  /// No description provided for @loginTitle.
  ///
  /// In zh, this message translates to:
  /// **'登录教务系统'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'请使用您的账号继续'**
  String get loginSubtitle;

  /// No description provided for @studentId.
  ///
  /// In zh, this message translates to:
  /// **'学号'**
  String get studentId;

  /// No description provided for @password.
  ///
  /// In zh, this message translates to:
  /// **'统一身份认证密码'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In zh, this message translates to:
  /// **'忘记密码?'**
  String get forgotPassword;

  /// No description provided for @loggingIn.
  ///
  /// In zh, this message translates to:
  /// **'正在登录教务系统'**
  String get loggingIn;

  /// No description provided for @loggingInSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'正在验证账号并同步课程、成绩等基础数据，首次登录可能需要几秒'**
  String get loggingInSubtitle;

  /// No description provided for @emptyCredentials.
  ///
  /// In zh, this message translates to:
  /// **'用户名和密码不能为空'**
  String get emptyCredentials;

  /// No description provided for @loginTimeoutEdu.
  ///
  /// In zh, this message translates to:
  /// **'教务系统登录超时，请检查网络连接'**
  String get loginTimeoutEdu;

  /// No description provided for @loginFailed.
  ///
  /// In zh, this message translates to:
  /// **'登录失败，请检查用户名和密码'**
  String get loginFailed;

  /// No description provided for @loginTimeout.
  ///
  /// In zh, this message translates to:
  /// **'登录超时，请检查网络连接后重试'**
  String get loginTimeout;

  /// No description provided for @loginSecurityStorageUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'登录成功，但安全存储不可用，下次启动后可能需要重新输入账号密码'**
  String get loginSecurityStorageUnavailable;

  /// No description provided for @loadingDefaultTitle.
  ///
  /// In zh, this message translates to:
  /// **'正在同步数据'**
  String get loadingDefaultTitle;

  /// No description provided for @loadingDefaultSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'网络较慢时可能需要几秒，请稍等一下'**
  String get loadingDefaultSubtitle;

  /// No description provided for @errorOccurred.
  ///
  /// In zh, this message translates to:
  /// **'出错了'**
  String get errorOccurred;

  /// No description provided for @retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// No description provided for @loadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get loadFailed;

  /// No description provided for @noData.
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get noData;

  /// No description provided for @ok.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get ok;

  /// No description provided for @classroom.
  ///
  /// In zh, this message translates to:
  /// **'上课地点'**
  String get classroom;

  /// No description provided for @teacherLabel.
  ///
  /// In zh, this message translates to:
  /// **'授课教师'**
  String get teacherLabel;

  /// No description provided for @classTime.
  ///
  /// In zh, this message translates to:
  /// **'上课时间'**
  String get classTime;

  /// No description provided for @classCampus.
  ///
  /// In zh, this message translates to:
  /// **'上课校区'**
  String get classCampus;

  /// No description provided for @todayScheduleLabel.
  ///
  /// In zh, this message translates to:
  /// **'今日课表'**
  String get todayScheduleLabel;

  /// No description provided for @tomorrowSchedule.
  ///
  /// In zh, this message translates to:
  /// **'明日课表'**
  String get tomorrowSchedule;

  /// No description provided for @noCourseToday.
  ///
  /// In zh, this message translates to:
  /// **'今天没有课了'**
  String get noCourseToday;

  /// No description provided for @noCourseTodaySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'好好休息会儿吧，学一天累死个人'**
  String get noCourseTodaySubtitle;

  /// No description provided for @showTomorrowSchedule.
  ///
  /// In zh, this message translates to:
  /// **'显示明天的课表'**
  String get showTomorrowSchedule;

  /// No description provided for @doubleTapExit.
  ///
  /// In zh, this message translates to:
  /// **'再按一次退出应用'**
  String get doubleTapExit;

  /// No description provided for @copySuccess.
  ///
  /// In zh, this message translates to:
  /// **'已复制: {text}'**
  String copySuccess(Object text);

  /// No description provided for @copyTooltip.
  ///
  /// In zh, this message translates to:
  /// **'复制文本'**
  String get copyTooltip;

  /// No description provided for @pageSettings.
  ///
  /// In zh, this message translates to:
  /// **'页面设置'**
  String get pageSettings;

  /// No description provided for @showBusTile.
  ///
  /// In zh, this message translates to:
  /// **'显示校车磁贴'**
  String get showBusTile;

  /// No description provided for @showBusTileSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'在首页显示最近的班车信息'**
  String get showBusTileSubtitle;

  /// No description provided for @addToHome.
  ///
  /// In zh, this message translates to:
  /// **'添加到首页'**
  String get addToHome;

  /// No description provided for @showElectricityTile.
  ///
  /// In zh, this message translates to:
  /// **'在首页显示电费磁贴'**
  String get showElectricityTile;

  /// No description provided for @electricityRecharge.
  ///
  /// In zh, this message translates to:
  /// **'电费充值'**
  String get electricityRecharge;

  /// No description provided for @electricityRechargeSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'跳转至微信进行电费充值'**
  String get electricityRechargeSubtitle;

  /// No description provided for @showPaymentTile.
  ///
  /// In zh, this message translates to:
  /// **'显示饭卡磁贴'**
  String get showPaymentTile;

  /// No description provided for @showPaymentTileSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'在首页显示余额概览'**
  String get showPaymentTileSubtitle;

  /// No description provided for @addTodo.
  ///
  /// In zh, this message translates to:
  /// **'添加待办'**
  String get addTodo;

  /// No description provided for @todoTitle.
  ///
  /// In zh, this message translates to:
  /// **'标题'**
  String get todoTitle;

  /// No description provided for @deadline.
  ///
  /// In zh, this message translates to:
  /// **'截止日期'**
  String get deadline;

  /// No description provided for @change.
  ///
  /// In zh, this message translates to:
  /// **'更改'**
  String get change;

  /// No description provided for @edit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get edit;

  /// No description provided for @done.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get done;

  /// No description provided for @todoListLabel.
  ///
  /// In zh, this message translates to:
  /// **'待办事务'**
  String get todoListLabel;

  /// No description provided for @readingTodos.
  ///
  /// In zh, this message translates to:
  /// **'正在读取待办事务'**
  String get readingTodos;

  /// No description provided for @readingTodosSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'正在加载本地待办列表与提醒状态'**
  String get readingTodosSubtitle;

  /// No description provided for @noTodos.
  ///
  /// In zh, this message translates to:
  /// **'当前没有待办事务'**
  String get noTodos;

  /// No description provided for @noTodosSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'点击右上角添加待办事项'**
  String get noTodosSubtitle;

  /// No description provided for @todoLoadFailedSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'无法加载待办事项'**
  String get todoLoadFailedSubtitle;

  /// No description provided for @deadlineLabel.
  ///
  /// In zh, this message translates to:
  /// **'截止日期: {date}'**
  String deadlineLabel(Object date);

  /// No description provided for @noDeadline.
  ///
  /// In zh, this message translates to:
  /// **'无'**
  String get noDeadline;

  /// No description provided for @titleRequired.
  ///
  /// In zh, this message translates to:
  /// **'标题是必须项'**
  String get titleRequired;

  /// No description provided for @deadlineRequired.
  ///
  /// In zh, this message translates to:
  /// **'截至日期是必须项'**
  String get deadlineRequired;

  /// No description provided for @add.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get add;

  /// No description provided for @upcomingExams.
  ///
  /// In zh, this message translates to:
  /// **'近期考试'**
  String get upcomingExams;

  /// No description provided for @loadingExams.
  ///
  /// In zh, this message translates to:
  /// **'正在加载考试信息'**
  String get loadingExams;

  /// No description provided for @loadingExamsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'正在同步近期考试安排、考场和座位信息'**
  String get loadingExamsSubtitle;

  /// No description provided for @noExams.
  ///
  /// In zh, this message translates to:
  /// **'最近没有考试'**
  String get noExams;

  /// No description provided for @noExamsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'说不定刷新一下就有了'**
  String get noExamsSubtitle;

  /// No description provided for @examTime.
  ///
  /// In zh, this message translates to:
  /// **'考试时间'**
  String get examTime;

  /// No description provided for @examLocation.
  ///
  /// In zh, this message translates to:
  /// **'考试地点'**
  String get examLocation;

  /// No description provided for @seatNumber.
  ///
  /// In zh, this message translates to:
  /// **'座位号'**
  String get seatNumber;

  /// No description provided for @seatNumberLabel.
  ///
  /// In zh, this message translates to:
  /// **'座位号 {seat}'**
  String seatNumberLabel(Object seat);

  /// No description provided for @examNotLoggedIn.
  ///
  /// In zh, this message translates to:
  /// **'未登录，请先登录'**
  String get examNotLoggedIn;

  /// No description provided for @examAuthFailed.
  ///
  /// In zh, this message translates to:
  /// **'认证失败，请重新登录'**
  String get examAuthFailed;

  /// No description provided for @examFetchFailed.
  ///
  /// In zh, this message translates to:
  /// **'获取考试信息失败，轻点重试'**
  String get examFetchFailed;

  /// No description provided for @quickFeatures.
  ///
  /// In zh, this message translates to:
  /// **'快捷功能'**
  String get quickFeatures;

  /// No description provided for @noQuickFeatures.
  ///
  /// In zh, this message translates to:
  /// **'暂无快捷功能'**
  String get noQuickFeatures;

  /// No description provided for @noQuickFeaturesSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'请在编辑模式中添加'**
  String get noQuickFeaturesSubtitle;

  /// No description provided for @moreFeatures.
  ///
  /// In zh, this message translates to:
  /// **'更多功能'**
  String get moreFeatures;

  /// No description provided for @scheduleWidgetTitle.
  ///
  /// In zh, this message translates to:
  /// **'导入到日历'**
  String get scheduleWidgetTitle;

  /// No description provided for @subscriptionLink.
  ///
  /// In zh, this message translates to:
  /// **'订阅链接'**
  String get subscriptionLink;

  /// No description provided for @copiedSuccess.
  ///
  /// In zh, this message translates to:
  /// **'复制成功!'**
  String get copiedSuccess;

  /// No description provided for @howToImport.
  ///
  /// In zh, this message translates to:
  /// **'不会导入？'**
  String get howToImport;

  /// No description provided for @customCourseManage.
  ///
  /// In zh, this message translates to:
  /// **'自定义课程管理'**
  String get customCourseManage;

  /// No description provided for @noBackground.
  ///
  /// In zh, this message translates to:
  /// **'无背景'**
  String get noBackground;

  /// No description provided for @customImage.
  ///
  /// In zh, this message translates to:
  /// **'自定义图片'**
  String get customImage;

  /// No description provided for @noImageSelected.
  ///
  /// In zh, this message translates to:
  /// **'未选择图片'**
  String get noImageSelected;

  /// No description provided for @noCalendarApp.
  ///
  /// In zh, this message translates to:
  /// **'没有找到日历应用，请手动导入'**
  String get noCalendarApp;

  /// No description provided for @cannotOpenCalendar.
  ///
  /// In zh, this message translates to:
  /// **'无法打开日历应用'**
  String get cannotOpenCalendar;

  /// No description provided for @bgImageSetSuccess.
  ///
  /// In zh, this message translates to:
  /// **'背景图片设置成功'**
  String get bgImageSetSuccess;

  /// No description provided for @selectImageFailed.
  ///
  /// In zh, this message translates to:
  /// **'选择图片失败'**
  String get selectImageFailed;

  /// No description provided for @addCalendarSub.
  ///
  /// In zh, this message translates to:
  /// **'添加日历订阅'**
  String get addCalendarSub;

  /// No description provided for @understand.
  ///
  /// In zh, this message translates to:
  /// **'明白了'**
  String get understand;

  /// No description provided for @calendarSubscription.
  ///
  /// In zh, this message translates to:
  /// **'日历订阅'**
  String get calendarSubscription;

  /// No description provided for @scheduleManagement.
  ///
  /// In zh, this message translates to:
  /// **'课表管理'**
  String get scheduleManagement;

  /// No description provided for @scheduleBackground.
  ///
  /// In zh, this message translates to:
  /// **'课表背景'**
  String get scheduleBackground;

  /// No description provided for @ignoreCourses.
  ///
  /// In zh, this message translates to:
  /// **'忽略课程'**
  String get ignoreCourses;

  /// No description provided for @loadingSchedule.
  ///
  /// In zh, this message translates to:
  /// **'正在加载课表'**
  String get loadingSchedule;

  /// No description provided for @loadingScheduleSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'正在读取课程、偏好设置和背景配置'**
  String get loadingScheduleSubtitle;

  /// No description provided for @updatingSchedule.
  ///
  /// In zh, this message translates to:
  /// **'正在更新课表...'**
  String get updatingSchedule;

  /// No description provided for @updateComplete.
  ///
  /// In zh, this message translates to:
  /// **'更新完成'**
  String get updateComplete;

  /// No description provided for @updateTimeout.
  ///
  /// In zh, this message translates to:
  /// **'更新超时，请检查网络连接后重试'**
  String get updateTimeout;

  /// No description provided for @updateFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新失败: {error}'**
  String updateFailed(Object error);

  /// No description provided for @linkCopiedToClipboard.
  ///
  /// In zh, this message translates to:
  /// **'链接已复制到剪贴板'**
  String get linkCopiedToClipboard;

  /// No description provided for @currentWeekLabel.
  ///
  /// In zh, this message translates to:
  /// **'本周'**
  String get currentWeekLabel;

  /// No description provided for @periodUnit.
  ///
  /// In zh, this message translates to:
  /// **'第{n}节'**
  String periodUnit(Object n);

  /// No description provided for @calendarGuidanceIntro.
  ///
  /// In zh, this message translates to:
  /// **'您的设备似乎没有应用可以直接处理日历订阅。请按照以下步骤手动添加:'**
  String get calendarGuidanceIntro;

  /// No description provided for @calendarGuidanceStep1.
  ///
  /// In zh, this message translates to:
  /// **'1. 打开您的日历应用'**
  String get calendarGuidanceStep1;

  /// No description provided for @calendarGuidanceStep2.
  ///
  /// In zh, this message translates to:
  /// **'2. 找到\"添加日历\"或\"订阅\"选项'**
  String get calendarGuidanceStep2;

  /// No description provided for @calendarGuidanceStep3.
  ///
  /// In zh, this message translates to:
  /// **'3. 选择\"通过URL添加\"或类似选项'**
  String get calendarGuidanceStep3;

  /// No description provided for @calendarGuidanceStep4.
  ///
  /// In zh, this message translates to:
  /// **'4. 粘贴以下链接:'**
  String get calendarGuidanceStep4;

  /// No description provided for @calendarGuidanceNote.
  ///
  /// In zh, this message translates to:
  /// **'注意: 不同的日历应用可能有不同的添加步骤。如果您遇到困难，请查阅您的日历应用帮助文档。'**
  String get calendarGuidanceNote;

  /// No description provided for @profileReading.
  ///
  /// In zh, this message translates to:
  /// **'正在读取账号信息'**
  String get profileReading;

  /// No description provided for @profileReadingSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'正在同步本地登录状态和个人资料入口，请稍等一下'**
  String get profileReadingSubtitle;

  /// No description provided for @campusNavigation.
  ///
  /// In zh, this message translates to:
  /// **'校园导航'**
  String get campusNavigation;

  /// No description provided for @settingsAbout.
  ///
  /// In zh, this message translates to:
  /// **'设置/关于'**
  String get settingsAbout;

  /// No description provided for @programLabel.
  ///
  /// In zh, this message translates to:
  /// **'培养方案'**
  String get programLabel;

  /// No description provided for @campusMap.
  ///
  /// In zh, this message translates to:
  /// **'校园地图'**
  String get campusMap;

  /// No description provided for @help.
  ///
  /// In zh, this message translates to:
  /// **'帮助'**
  String get help;

  /// No description provided for @academicAccount.
  ///
  /// In zh, this message translates to:
  /// **'教务系统账号'**
  String get academicAccount;

  /// No description provided for @guest.
  ///
  /// In zh, this message translates to:
  /// **'游客'**
  String get guest;

  /// No description provided for @syncingAcademic.
  ///
  /// In zh, this message translates to:
  /// **'正在同步学业信息'**
  String get syncingAcademic;

  /// No description provided for @syncingAcademicSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'正在读取学分与个人信息卡片'**
  String get syncingAcademicSubtitle;

  /// No description provided for @loginEduSystem.
  ///
  /// In zh, this message translates to:
  /// **'登录教务系统'**
  String get loginEduSystem;

  /// No description provided for @programLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在加载培养方案'**
  String get programLoading;

  /// No description provided for @programLoadingSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'正在整理学期课程结构和课程类别，请稍等一下'**
  String get programLoadingSubtitle;

  /// No description provided for @programLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get programLoadFailed;

  /// No description provided for @programNoData.
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get programNoData;

  /// No description provided for @programRefreshFailed.
  ///
  /// In zh, this message translates to:
  /// **'刷新失败，当前展示的是上次同步的培养方案'**
  String get programRefreshFailed;

  /// No description provided for @linkLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在加载导航链接'**
  String get linkLoading;

  /// No description provided for @linkLoadingSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'正在整理常用站点与分类入口'**
  String get linkLoadingSubtitle;

  /// No description provided for @linkLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get linkLoadFailed;

  /// No description provided for @linkNoData.
  ///
  /// In zh, this message translates to:
  /// **'暂无导航数据'**
  String get linkNoData;

  /// No description provided for @linkNoDataSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'请重新进入此页，或检查当前网络'**
  String get linkNoDataSubtitle;

  /// No description provided for @paymentLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在同步饭卡余额'**
  String get paymentLoading;

  /// No description provided for @paymentLoadingSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'正在获取最新流水，请稍候...'**
  String get paymentLoadingSubtitle;

  /// No description provided for @campusCard.
  ///
  /// In zh, this message translates to:
  /// **'校园一卡通'**
  String get campusCard;

  /// No description provided for @currentBalance.
  ///
  /// In zh, this message translates to:
  /// **'当前余额'**
  String get currentBalance;

  /// No description provided for @recentTransactions.
  ///
  /// In zh, this message translates to:
  /// **'最近交易'**
  String get recentTransactions;

  /// No description provided for @paymentFilter.
  ///
  /// In zh, this message translates to:
  /// **'支付'**
  String get paymentFilter;

  /// No description provided for @consumptionFilter.
  ///
  /// In zh, this message translates to:
  /// **'消费'**
  String get consumptionFilter;

  /// No description provided for @rechargeFilter.
  ///
  /// In zh, this message translates to:
  /// **'充值'**
  String get rechargeFilter;

  /// No description provided for @noCardData.
  ///
  /// In zh, this message translates to:
  /// **'无饭卡数据'**
  String get noCardData;

  /// No description provided for @noCardDataSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'请登录教务处账号以查看余额和交易流水'**
  String get noCardDataSubtitle;

  /// No description provided for @busLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在获取校车班次'**
  String get busLoading;

  /// No description provided for @busLoadingSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'正在按日期整理两校区往返班车信息'**
  String get busLoadingSubtitle;

  /// No description provided for @noBusToday.
  ///
  /// In zh, this message translates to:
  /// **'今天没有车了'**
  String get noBusToday;

  /// No description provided for @noBusTodaySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'明天再来吧'**
  String get noBusTodaySubtitle;

  /// No description provided for @departureTime.
  ///
  /// In zh, this message translates to:
  /// **'出发时间'**
  String get departureTime;

  /// No description provided for @destination.
  ///
  /// In zh, this message translates to:
  /// **'终点站'**
  String get destination;

  /// No description provided for @estimatedArrival.
  ///
  /// In zh, this message translates to:
  /// **'预计到达'**
  String get estimatedArrival;

  /// No description provided for @busInfo.
  ///
  /// In zh, this message translates to:
  /// **'班次信息'**
  String get busInfo;

  /// No description provided for @departure.
  ///
  /// In zh, this message translates to:
  /// **'出发'**
  String get departure;

  /// No description provided for @arrival.
  ///
  /// In zh, this message translates to:
  /// **'到达'**
  String get arrival;

  /// No description provided for @netRefreshFailed.
  ///
  /// In zh, this message translates to:
  /// **'刷新失败，已保留当前校园网数据'**
  String get netRefreshFailed;

  /// No description provided for @netData.
  ///
  /// In zh, this message translates to:
  /// **'校园网数据'**
  String get netData;

  /// No description provided for @usedTraffic.
  ///
  /// In zh, this message translates to:
  /// **'已用流量'**
  String get usedTraffic;

  /// No description provided for @onlineDuration.
  ///
  /// In zh, this message translates to:
  /// **'在线时长: {time}'**
  String onlineDuration(Object time);

  /// No description provided for @username.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get username;

  /// No description provided for @ipAddress.
  ///
  /// In zh, this message translates to:
  /// **'IP 地址'**
  String get ipAddress;

  /// No description provided for @productPackage.
  ///
  /// In zh, this message translates to:
  /// **'产品套餐'**
  String get productPackage;

  /// No description provided for @unknown.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get unknown;

  /// No description provided for @copiedToClipboard.
  ///
  /// In zh, this message translates to:
  /// **'已复制到剪贴板'**
  String get copiedToClipboard;

  /// No description provided for @netLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在读取校园网数据'**
  String get netLoading;

  /// No description provided for @netLoadingSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'正在同步流量、在线时长和账号信息'**
  String get netLoadingSubtitle;

  /// No description provided for @netLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get netLoadFailed;

  /// No description provided for @netNoData.
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get netNoData;

  /// No description provided for @electricityBalance.
  ///
  /// In zh, this message translates to:
  /// **'当前余额'**
  String get electricityBalance;

  /// No description provided for @electricityNoData.
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get electricityNoData;

  /// No description provided for @electricityLowBalance.
  ///
  /// In zh, this message translates to:
  /// **'余额不足，请及时充值'**
  String get electricityLowBalance;

  /// No description provided for @electricitySufficient.
  ///
  /// In zh, this message translates to:
  /// **'余额充足'**
  String get electricitySufficient;

  /// No description provided for @electricityAddTip.
  ///
  /// In zh, this message translates to:
  /// **'点击右上角添加电费数据'**
  String get electricityAddTip;

  /// No description provided for @electricityLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在刷新用电趋势'**
  String get electricityLoading;

  /// No description provided for @electricityLoadingSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'正在读取最新电费记录'**
  String get electricityLoadingSubtitle;

  /// No description provided for @noUsageDetails.
  ///
  /// In zh, this message translates to:
  /// **'没有用电明细'**
  String get noUsageDetails;

  /// No description provided for @noUsageDetailsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'刷新后会在这里展示每小时花费'**
  String get noUsageDetailsSubtitle;

  /// No description provided for @electricityCost.
  ///
  /// In zh, this message translates to:
  /// **'用电花费'**
  String get electricityCost;

  /// No description provided for @lastNDays.
  ///
  /// In zh, this message translates to:
  /// **'近{n}天'**
  String lastNDays(Object n);

  /// No description provided for @totalCost.
  ///
  /// In zh, this message translates to:
  /// **'总计花费'**
  String get totalCost;

  /// No description provided for @todayCost.
  ///
  /// In zh, this message translates to:
  /// **'今日花费'**
  String get todayCost;

  /// No description provided for @avgDailyCost.
  ///
  /// In zh, this message translates to:
  /// **'日均花费'**
  String get avgDailyCost;

  /// No description provided for @peakHours.
  ///
  /// In zh, this message translates to:
  /// **'峰值时段'**
  String get peakHours;

  /// No description provided for @hourlyDetails.
  ///
  /// In zh, this message translates to:
  /// **'每小时明细'**
  String get hourlyDetails;

  /// No description provided for @lowBalanceSub.
  ///
  /// In zh, this message translates to:
  /// **'低余额订阅'**
  String get lowBalanceSub;

  /// No description provided for @lowBalanceSubDesc.
  ///
  /// In zh, this message translates to:
  /// **'当余额低于阈值时...'**
  String get lowBalanceSubDesc;

  /// No description provided for @addElectricityFirst.
  ///
  /// In zh, this message translates to:
  /// **'先添加电费页面后...'**
  String get addElectricityFirst;

  /// No description provided for @noElectricityData.
  ///
  /// In zh, this message translates to:
  /// **'还没有电费数据'**
  String get noElectricityData;

  /// No description provided for @noElectricityDataSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'先在本页绑定宿舍电费链接...'**
  String get noElectricityDataSubtitle;

  /// No description provided for @lowBalanceEnabled.
  ///
  /// In zh, this message translates to:
  /// **'已开启低余额提醒'**
  String get lowBalanceEnabled;

  /// No description provided for @addLowBalanceAlert.
  ///
  /// In zh, this message translates to:
  /// **'添加低余额提醒'**
  String get addLowBalanceAlert;

  /// No description provided for @deleteSubscription.
  ///
  /// In zh, this message translates to:
  /// **'删除订阅'**
  String get deleteSubscription;

  /// No description provided for @deleteSubDesc.
  ///
  /// In zh, this message translates to:
  /// **'取消当前邮箱的低余额提醒...'**
  String get deleteSubDesc;

  /// No description provided for @electricityManagement.
  ///
  /// In zh, this message translates to:
  /// **'电费管理'**
  String get electricityManagement;

  /// No description provided for @chooseAction.
  ///
  /// In zh, this message translates to:
  /// **'选择要执行的操作'**
  String get chooseAction;

  /// No description provided for @changeRoom.
  ///
  /// In zh, this message translates to:
  /// **'更换房间'**
  String get changeRoom;

  /// No description provided for @getElectricity.
  ///
  /// In zh, this message translates to:
  /// **'获取电费'**
  String get getElectricity;

  /// No description provided for @electricityUrlPrompt.
  ///
  /// In zh, this message translates to:
  /// **'请打开建大财务处电费详情页面，复制页面URL并粘贴到下方输入框'**
  String get electricityUrlPrompt;

  /// No description provided for @urlPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'请输入URL'**
  String get urlPlaceholder;

  /// No description provided for @createLowBalanceAlert.
  ///
  /// In zh, this message translates to:
  /// **'添加低余额提醒'**
  String get createLowBalanceAlert;

  /// No description provided for @lowBalanceAlertDesc.
  ///
  /// In zh, this message translates to:
  /// **'系统会使用当前绑定的宿舍电费页面，在余额低于设定阈值时发送邮件提醒。'**
  String get lowBalanceAlertDesc;

  /// No description provided for @remindEmail.
  ///
  /// In zh, this message translates to:
  /// **'提醒邮箱'**
  String get remindEmail;

  /// No description provided for @remindEmailPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'提醒邮箱'**
  String get remindEmailPlaceholder;

  /// No description provided for @remindThreshold.
  ///
  /// In zh, this message translates to:
  /// **'提醒阈值，例如 10'**
  String get remindThreshold;

  /// No description provided for @remindThresholdPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'提醒阈值，例如 10'**
  String get remindThresholdPlaceholder;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In zh, this message translates to:
  /// **'请输入提醒邮箱'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的邮箱地址'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterThreshold.
  ///
  /// In zh, this message translates to:
  /// **'请输入大于 0 的提醒阈值'**
  String get pleaseEnterThreshold;

  /// No description provided for @lowBalanceAlertCreated.
  ///
  /// In zh, this message translates to:
  /// **'低余额提醒已创建'**
  String get lowBalanceAlertCreated;

  /// No description provided for @createSubFailed.
  ///
  /// In zh, this message translates to:
  /// **'创建电费订阅失败'**
  String get createSubFailed;

  /// No description provided for @currentSubInfo.
  ///
  /// In zh, this message translates to:
  /// **'当前邮箱 {email} 低于 {threshold} 元时提醒'**
  String currentSubInfo(Object email, Object threshold);

  /// No description provided for @subSetupHint.
  ///
  /// In zh, this message translates to:
  /// **'设置阈值后，余额低于该金额时将通过邮箱提醒'**
  String get subSetupHint;

  /// No description provided for @remindEmailLabel.
  ///
  /// In zh, this message translates to:
  /// **'提醒邮箱'**
  String get remindEmailLabel;

  /// No description provided for @notSet.
  ///
  /// In zh, this message translates to:
  /// **'未设置'**
  String get notSet;

  /// No description provided for @remindThresholdLabel.
  ///
  /// In zh, this message translates to:
  /// **'提醒阈值'**
  String get remindThresholdLabel;

  /// No description provided for @gotIt.
  ///
  /// In zh, this message translates to:
  /// **'知道了'**
  String get gotIt;

  /// No description provided for @noSubToDelete.
  ///
  /// In zh, this message translates to:
  /// **'当前没有可删除的订阅'**
  String get noSubToDelete;

  /// No description provided for @deleteSubTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除订阅'**
  String get deleteSubTitle;

  /// No description provided for @deleteSubConfirmContent.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除当前的低余额订阅吗？'**
  String get deleteSubConfirmContent;

  /// No description provided for @lowBalanceAlertDeleted.
  ///
  /// In zh, this message translates to:
  /// **'低余额提醒已删除'**
  String get lowBalanceAlertDeleted;

  /// No description provided for @deleteSubFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除电费订阅失败'**
  String get deleteSubFailed;

  /// No description provided for @electricitySubLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载电费订阅失败'**
  String get electricitySubLoadFailed;

  /// No description provided for @subscriptionDetail.
  ///
  /// In zh, this message translates to:
  /// **'订阅内容'**
  String get subscriptionDetail;

  /// No description provided for @create.
  ///
  /// In zh, this message translates to:
  /// **'创建'**
  String get create;

  /// No description provided for @webNotSupported.
  ///
  /// In zh, this message translates to:
  /// **'暂不支持Web版'**
  String get webNotSupported;

  /// No description provided for @webNotSupportedSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'请使用其他版本'**
  String get webNotSupportedSubtitle;

  /// No description provided for @reorderFailed.
  ///
  /// In zh, this message translates to:
  /// **'重新排序失败'**
  String get reorderFailed;

  /// No description provided for @searchLocation.
  ///
  /// In zh, this message translates to:
  /// **'搜索地点或建筑...'**
  String get searchLocation;

  /// No description provided for @search.
  ///
  /// In zh, this message translates to:
  /// **'搜索...'**
  String get search;

  /// No description provided for @buildingIntro.
  ///
  /// In zh, this message translates to:
  /// **'建筑介绍'**
  String get buildingIntro;

  /// No description provided for @specificLocation.
  ///
  /// In zh, this message translates to:
  /// **'具体位置'**
  String get specificLocation;

  /// No description provided for @licenseTitle.
  ///
  /// In zh, this message translates to:
  /// **'开源许可证'**
  String get licenseTitle;

  /// No description provided for @licenseLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在读取许可证'**
  String get licenseLoading;

  /// No description provided for @licenseLoadingSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'正在加载应用附带的开源协议文本'**
  String get licenseLoadingSubtitle;

  /// No description provided for @licenseLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法加载许可证文件'**
  String get licenseLoadFailed;

  /// No description provided for @helpFeaturesTab.
  ///
  /// In zh, this message translates to:
  /// **'功能介绍'**
  String get helpFeaturesTab;

  /// No description provided for @helpInstructionsTab.
  ///
  /// In zh, this message translates to:
  /// **'使用说明'**
  String get helpInstructionsTab;

  /// No description provided for @helpNotesTab.
  ///
  /// In zh, this message translates to:
  /// **'注意事项'**
  String get helpNotesTab;

  /// No description provided for @helpAboutTab.
  ///
  /// In zh, this message translates to:
  /// **'关于应用'**
  String get helpAboutTab;

  /// No description provided for @helpFeatureHome.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get helpFeatureHome;

  /// No description provided for @helpFeatureHomeDesc.
  ///
  /// In zh, this message translates to:
  /// **'信息中心，展示个人信息、课程、待办事项和考试安排'**
  String get helpFeatureHomeDesc;

  /// No description provided for @helpFeatureSchedule.
  ///
  /// In zh, this message translates to:
  /// **'课程表'**
  String get helpFeatureSchedule;

  /// No description provided for @helpFeatureScheduleDesc.
  ///
  /// In zh, this message translates to:
  /// **'管理周课程安排，支持切换校区和设置提醒'**
  String get helpFeatureScheduleDesc;

  /// No description provided for @helpFeatureScore.
  ///
  /// In zh, this message translates to:
  /// **'成绩查询'**
  String get helpFeatureScore;

  /// No description provided for @helpFeatureScoreDesc.
  ///
  /// In zh, this message translates to:
  /// **'查看学期成绩单、绩点计算和分析'**
  String get helpFeatureScoreDesc;

  /// No description provided for @helpFeatureProfile.
  ///
  /// In zh, this message translates to:
  /// **'个人资料'**
  String get helpFeatureProfile;

  /// No description provided for @helpFeatureProfileDesc.
  ///
  /// In zh, this message translates to:
  /// **'展示学号、姓名、学院等个人信息'**
  String get helpFeatureProfileDesc;

  /// No description provided for @helpFeatureBus.
  ///
  /// In zh, this message translates to:
  /// **'校园巴士'**
  String get helpFeatureBus;

  /// No description provided for @helpFeatureBusDesc.
  ///
  /// In zh, this message translates to:
  /// **'查看校区间班车时刻表和路线信息'**
  String get helpFeatureBusDesc;

  /// No description provided for @helpFeatureProgram.
  ///
  /// In zh, this message translates to:
  /// **'培养方案'**
  String get helpFeatureProgram;

  /// No description provided for @helpFeatureProgramDesc.
  ///
  /// In zh, this message translates to:
  /// **'显示专业培养计划和学分要求'**
  String get helpFeatureProgramDesc;

  /// No description provided for @helpFeatureElectricity.
  ///
  /// In zh, this message translates to:
  /// **'电费查询'**
  String get helpFeatureElectricity;

  /// No description provided for @helpFeatureElectricityDesc.
  ///
  /// In zh, this message translates to:
  /// **'查看宿舍电量和用电历史记录'**
  String get helpFeatureElectricityDesc;

  /// No description provided for @helpFeaturePayment.
  ///
  /// In zh, this message translates to:
  /// **'饭卡消费'**
  String get helpFeaturePayment;

  /// No description provided for @helpFeaturePaymentDesc.
  ///
  /// In zh, this message translates to:
  /// **'查看饭卡余额和消费明细'**
  String get helpFeaturePaymentDesc;

  /// No description provided for @helpFeatureNet.
  ///
  /// In zh, this message translates to:
  /// **'校园网'**
  String get helpFeatureNet;

  /// No description provided for @helpFeatureNetDesc.
  ///
  /// In zh, this message translates to:
  /// **'查看网络流量使用情况和统计'**
  String get helpFeatureNetDesc;

  /// No description provided for @helpFeatureLinks.
  ///
  /// In zh, this message translates to:
  /// **'常用链接'**
  String get helpFeatureLinks;

  /// No description provided for @helpFeatureLinksDesc.
  ///
  /// In zh, this message translates to:
  /// **'收集教务系统等常用工具链接'**
  String get helpFeatureLinksDesc;

  /// No description provided for @helpInstructionLogin.
  ///
  /// In zh, this message translates to:
  /// **'登录与账户'**
  String get helpInstructionLogin;

  /// No description provided for @helpInstructionLoginDesc.
  ///
  /// In zh, this message translates to:
  /// **'首次使用需登录教务系统账户'**
  String get helpInstructionLoginDesc;

  /// No description provided for @helpInstructionCourse.
  ///
  /// In zh, this message translates to:
  /// **'课程管理'**
  String get helpInstructionCourse;

  /// No description provided for @helpInstructionCourseDesc.
  ///
  /// In zh, this message translates to:
  /// **'进入课程表查看当周课程，左右滑动切换周次，点击课程查看详情'**
  String get helpInstructionCourseDesc;

  /// No description provided for @helpInstructionReminder.
  ///
  /// In zh, this message translates to:
  /// **'日程提醒'**
  String get helpInstructionReminder;

  /// No description provided for @helpInstructionReminderDesc.
  ///
  /// In zh, this message translates to:
  /// **'在设置中开启课程提醒，应用会在上课前发送通知提醒'**
  String get helpInstructionReminderDesc;

  /// No description provided for @helpInstructionSync.
  ///
  /// In zh, this message translates to:
  /// **'数据同步'**
  String get helpInstructionSync;

  /// No description provided for @helpInstructionSyncDesc.
  ///
  /// In zh, this message translates to:
  /// **'应用自动同步教务系统数据，需要网络连接。下拉刷新可手动更新'**
  String get helpInstructionSyncDesc;

  /// No description provided for @helpInstructionWidget.
  ///
  /// In zh, this message translates to:
  /// **'桌面小组件'**
  String get helpInstructionWidget;

  /// No description provided for @helpInstructionWidgetDesc.
  ///
  /// In zh, this message translates to:
  /// **'在桌面长按添加应用小组件，快速查看课程信息'**
  String get helpInstructionWidgetDesc;

  /// No description provided for @helpNoteNetwork.
  ///
  /// In zh, this message translates to:
  /// **'部分功能需要连接校园网才能正常使用'**
  String get helpNoteNetwork;

  /// No description provided for @helpNoteUpdate.
  ///
  /// In zh, this message translates to:
  /// **'请保持应用更新以获得最新功能和修复'**
  String get helpNoteUpdate;

  /// No description provided for @helpNoteData.
  ///
  /// In zh, this message translates to:
  /// **'数据不准确时，请检查是否正确登录教务系统'**
  String get helpNoteData;

  /// No description provided for @helpNoteFeedback.
  ///
  /// In zh, this message translates to:
  /// **'遇到问题可通过设置页面进行反馈'**
  String get helpNoteFeedback;

  /// No description provided for @helpNotePrivacy.
  ///
  /// In zh, this message translates to:
  /// **'应用不会收集或上传您的个人隐私信息'**
  String get helpNotePrivacy;

  /// No description provided for @helpAboutPlatform.
  ///
  /// In zh, this message translates to:
  /// **'平台支持'**
  String get helpAboutPlatform;

  /// No description provided for @helpAboutPlatformDesc.
  ///
  /// In zh, this message translates to:
  /// **'跨平台应用，支持以下平台：'**
  String get helpAboutPlatformDesc;

  /// No description provided for @helpAboutOpenSource.
  ///
  /// In zh, this message translates to:
  /// **'开源项目'**
  String get helpAboutOpenSource;

  /// No description provided for @helpAboutOpenSourceDesc.
  ///
  /// In zh, this message translates to:
  /// **'本应用基于 MIT 许可证开源'**
  String get helpAboutOpenSourceDesc;

  /// No description provided for @helpAboutRepoLabel.
  ///
  /// In zh, this message translates to:
  /// **'仓库地址：'**
  String get helpAboutRepoLabel;

  /// No description provided for @underMaintenanceTitle.
  ///
  /// In zh, this message translates to:
  /// **'正在维护！'**
  String get underMaintenanceTitle;

  /// No description provided for @underMaintenanceDescription.
  ///
  /// In zh, this message translates to:
  /// **'我们目前正在进行定期维护。请稍后再查看。感谢您的耐心等待。'**
  String get underMaintenanceDescription;

  /// No description provided for @readingPaymentCard.
  ///
  /// In zh, this message translates to:
  /// **'正在读取饭卡'**
  String get readingPaymentCard;

  /// No description provided for @lowBalance.
  ///
  /// In zh, this message translates to:
  /// **'余额不足'**
  String get lowBalance;

  /// No description provided for @campusCardBalance.
  ///
  /// In zh, this message translates to:
  /// **'饭卡余额'**
  String get campusCardBalance;

  /// No description provided for @tapToView.
  ///
  /// In zh, this message translates to:
  /// **'点击查看'**
  String get tapToView;

  /// No description provided for @tapToSubscribe.
  ///
  /// In zh, this message translates to:
  /// **'点击订阅'**
  String get tapToSubscribe;

  /// No description provided for @campusCaoTang.
  ///
  /// In zh, this message translates to:
  /// **'草堂'**
  String get campusCaoTang;

  /// No description provided for @campusYanTa.
  ///
  /// In zh, this message translates to:
  /// **'雁塔'**
  String get campusYanTa;

  /// No description provided for @busRefreshStale.
  ///
  /// In zh, this message translates to:
  /// **'刷新完成，已保留上次校车数据'**
  String get busRefreshStale;

  /// No description provided for @poiMainLibrary.
  ///
  /// In zh, this message translates to:
  /// **'主图书馆'**
  String get poiMainLibrary;

  /// No description provided for @poiMainLibraryDesc.
  ///
  /// In zh, this message translates to:
  /// **'24小时开放自习室'**
  String get poiMainLibraryDesc;

  /// No description provided for @poiCaoTangNorthGate.
  ///
  /// In zh, this message translates to:
  /// **'草堂校区北门'**
  String get poiCaoTangNorthGate;

  /// No description provided for @poiCaoTangNorthGateDesc.
  ///
  /// In zh, this message translates to:
  /// **'学校主入口'**
  String get poiCaoTangNorthGateDesc;

  /// No description provided for @poiYanTaEastGate.
  ///
  /// In zh, this message translates to:
  /// **'雁塔校区东门'**
  String get poiYanTaEastGate;

  /// No description provided for @poiYanTaEastGateDesc.
  ///
  /// In zh, this message translates to:
  /// **'历史悠久的老校区入口'**
  String get poiYanTaEastGateDesc;

  /// No description provided for @durationDHMS.
  ///
  /// In zh, this message translates to:
  /// **'{d}天{h}小时{m}分{s}秒'**
  String durationDHMS(Object d, Object h, Object m, Object s);

  /// No description provided for @shortcuts.
  ///
  /// In zh, this message translates to:
  /// **'快捷功能'**
  String get shortcuts;

  /// No description provided for @moreFunctions.
  ///
  /// In zh, this message translates to:
  /// **'更多功能'**
  String get moreFunctions;

  /// No description provided for @noShortcuts.
  ///
  /// In zh, this message translates to:
  /// **'暂无快捷功能'**
  String get noShortcuts;

  /// No description provided for @addInEditMode.
  ///
  /// In zh, this message translates to:
  /// **'请在编辑模式中添加'**
  String get addInEditMode;

  /// No description provided for @eduSystem.
  ///
  /// In zh, this message translates to:
  /// **'教务系统'**
  String get eduSystem;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'fr',
        'ja',
        'ko',
        'ru',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
