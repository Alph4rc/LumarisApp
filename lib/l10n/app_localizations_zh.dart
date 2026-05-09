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
  String get appSlogan => '试着把大学囊括其中';

  @override
  String get tagline => '致力于为建大学子提供更好的服务';

  @override
  String get home => '首页';

  @override
  String get schedule => '课表';

  @override
  String get score => '成绩';

  @override
  String get profile => '我的';

  @override
  String get electricity => '电费';

  @override
  String get schoolBus => '校车';

  @override
  String get payment => '饭卡';

  @override
  String get map => '地图';

  @override
  String get settings => '设置';

  @override
  String get basicSettings => '基本设置';

  @override
  String get version => '版本';

  @override
  String get widgets => '小组件';

  @override
  String get about => '关于';

  @override
  String get other => '其他';

  @override
  String get refreshData => '刷新数据';

  @override
  String get refreshingData => '正在刷新数据...';

  @override
  String get refreshDataSuccess => '刷新数据成功';

  @override
  String get refreshDataFailed => '刷新数据失败';

  @override
  String get appearance => '外观';

  @override
  String get followSystem => '跟随系统';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get language => '语言';

  @override
  String get systemLanguage => '跟随系统';

  @override
  String get simplifiedChinese => '简体中文';

  @override
  String get english => 'English';

  @override
  String get japanese => '日本語';

  @override
  String get russian => 'Русский';

  @override
  String get french => 'Français';

  @override
  String get german => 'Deutsch';

  @override
  String get korean => '한국어';

  @override
  String get team => '制作团队';

  @override
  String get teamName => 'Lumaris Team';

  @override
  String get openSourceLicense => '开源协议';

  @override
  String get mitLicense => 'MIT License';

  @override
  String get privacyPolicy => '隐私协议';

  @override
  String get privacyPolicySubtitle => '了解我们如何保护你的隐私';

  @override
  String get userAgreement => '用户协议';

  @override
  String get userAgreementSubtitle => '使用本应用即表示你同意本协议';

  @override
  String get clearCache => '清除缓存';

  @override
  String get clearingCache => '正在清除缓存...';

  @override
  String get cacheCleared => '缓存清除成功';

  @override
  String get confirmClearCacheTitle => '确定清除缓存吗？';

  @override
  String get confirmClearCacheContent => '这将删除所有缓存的数据，下次打开应用需要重新加载数据';

  @override
  String get logoutEduSystem => '退出教务系统';

  @override
  String get confirmLogoutTitle => '确定退出登录吗？';

  @override
  String get confirmLogoutContent => '退出后需要重新登录才能访问教务系统数据';

  @override
  String get logout => '退出登录';

  @override
  String get showCourseGrid => '显示课表网格线';

  @override
  String get agreementAuthDebug => '协议授权状态 [Debug]';

  @override
  String get agreementAuthDebugSubtitle => '关闭后下次启动将重新显示授权页';

  @override
  String get addToDesktop => '添加到桌面';

  @override
  String get widgetSetupTitle => '添加小组件到桌面';

  @override
  String get widgetSetupIntro => '请按照以下步骤操作：';

  @override
  String get widgetSetupStep1 => '长按手机桌面空白处';

  @override
  String get widgetSetupStep2 => '点击“小组件”或“Widgets”选项';

  @override
  String get widgetSetupStep3 => '找到“光序”并选择合适的小组件';

  @override
  String get widgetSetupStep4 => '将小组件拖拽到桌面合适位置';

  @override
  String get widgetSetupTip => '提示：小组件可以显示今日课程等信息，方便快速查看';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get back => '返回';

  @override
  String get collapseSidebar => '收起侧边栏';

  @override
  String get expandSidebar => '展开侧边栏';

  @override
  String get notLoggedIn => '未登录';

  @override
  String get academicSystem => '教务系统';

  @override
  String get clickToLogin => '点击登录';

  @override
  String get closeWindow => '关闭窗口';

  @override
  String get closeWindowChoice => '选择您要执行的操作';

  @override
  String get minimizeToTray => '最小化到任务栏';

  @override
  String get quitApp => '退出程序';

  @override
  String get goToSettings => '去设置';

  @override
  String get goAuthorize => '去授权';

  @override
  String get permissionRequired => '需要权限';

  @override
  String get permissionRequiredContent => '该功能需要您授予相应权限才能正常使用';

  @override
  String get permissionDenied => '权限已拒绝';

  @override
  String get permissionDeniedContent => '该权限已被永久拒绝，请前往系统设置手动开启';

  @override
  String get updateAvailable => '有新版本了！';

  @override
  String get ignoreThisUpdate => '忽略本次更新';

  @override
  String get ignoreAllUpdates => '忽略所有更新';

  @override
  String get goToBrowserUpdate => '前往浏览器更新';

  @override
  String get goToBrowser => '前往浏览器';

  @override
  String get dontUpdate => '暂不更新';

  @override
  String confirmUpdateTitle(Object version) {
    return '是否更新最新版本: $version';
  }

  @override
  String get confirmUpdateContent => '发现新版本可用，将在浏览器中打开下载链接，是否继续？';

  @override
  String get updateLog => '更新日志';

  @override
  String get ignoreVersionUpdate => '忽略版本更新';

  @override
  String get updateOpened => '已打开浏览器，请在浏览器中下载安装更新';

  @override
  String get openUpdateFailed => '打开更新链接失败';

  @override
  String get loginRequired => '请先登录';

  @override
  String get pleaseLoginEduAccount => '请先登录教务处账号';

  @override
  String get loadFailedTapRetry => '加载失败，点击重试';

  @override
  String get empty => '暂无数据';

  @override
  String get loading => '加载中';

  @override
  String get syncingData => '正在同步数据';

  @override
  String get syncingDataSubtitle => '网络较慢时可能需要几秒，请稍等一下';

  @override
  String get creditOverview => '学分概览';

  @override
  String get completionRate => '完成度';

  @override
  String get itemizedCredits => '分项学分';

  @override
  String get courseConflict => '当前时间存在多个冲突课程';

  @override
  String get networkError => '网络连接失败，请检查网络设置';

  @override
  String get requestTimeout => '请求超时，请检查网络连接';

  @override
  String get serverError => '服务器错误，请稍后重试';

  @override
  String get unknownError => '未知错误，请重试';

  @override
  String get agreementWelcomeTitle => '欢迎使用 光序';

  @override
  String get agreementDescription =>
      '在使用本应用前，请仔细阅读并同意以下协议。我们将严格遵守相关法律法规，保护您的个人信息安全。';

  @override
  String get agreementPrivacyDescription => '了解我们如何收集、使用和保护你的个人信息';

  @override
  String get agreementUserDescription => '了解使用本应用的权利、义务和免责条款';

  @override
  String get agreementReadTip => '点击上方卡片可查看协议全文。继续使用即表示你已阅读并同意以上协议。';

  @override
  String get agreeAndContinue => '同意并继续';

  @override
  String get disagree => '不同意';

  @override
  String get privacyPolicyTitle => '光序 隐私协议';

  @override
  String get privacyPolicyUpdatedAt => '更新日期：2026年5月5日';

  @override
  String get privacyPolicyEffectiveAt => '生效日期：2026年5月5日';

  @override
  String get privacyPolicyIntro =>
      '欢迎使用 光序（以下简称“本应用”）。本应用由 Lumaris Team（以下简称“我们”）开发和运营。我们深知个人信息对您的重要性，将严格遵守法律法规，遵循合法、正当、必要和诚信原则，保护您的个人信息安全。本隐私协议旨在向您说明我们如何收集、使用、存储和保护您的个人信息，以及您享有的相关权利。请您在使用本应用前仔细阅读本隐私协议。';

  @override
  String get privacySection1Title => '一、我们收集的信息';

  @override
  String get privacySection1_1 =>
      '1.1 账号信息：当您使用教务系统登录功能时，我们需要收集您的学号和密码，用于验证您的身份并获取教务系统数据。这些信息仅存储在您的设备本地，我们不会上传至任何服务器。';

  @override
  String get privacySection1_2 =>
      '1.2 课程与成绩信息：在您授权登录后，本应用会从学校教务系统获取您的课程表、考试成绩、培养方案等教育相关数据，并在您的设备本地进行存储和展示。';

  @override
  String get privacySection1_3 =>
      '1.3 校园生活信息：在您使用相关功能时，本应用会从学校相关系统获取您的电费余额、饭卡消费记录、校园网流量使用情况等信息，并在您的设备本地进行存储和展示。';

  @override
  String get privacySection1_4 =>
      '1.4 设备信息：为提供更好的服务体验，本应用可能收集您的设备型号、操作系统版本、设备标识符等信息，用于统计分析和问题排查。';

  @override
  String get privacySection1_5 =>
      '1.5 缓存数据：为提高应用响应速度，本应用会在您的设备上缓存部分数据，包括课程信息、成绩数据、网络请求响应等。您可以在设置中随时清除这些缓存。';

  @override
  String get privacySection2Title => '二、我们如何使用信息';

  @override
  String get privacySection2_1 =>
      '2.1 为您提供核心服务：我们使用您的学号和密码向学校教务系统进行身份认证，以获取并展示您的课程、成绩等信息。';

  @override
  String get privacySection2_2 =>
      '2.2 改善服务质量：我们可能使用设备信息和应用使用统计数据来分析和优化应用性能，提升用户体验。';

  @override
  String get privacySection2_3 =>
      '2.3 桌面小组件：如果您使用桌面小组件功能，本应用会在设备本地存储必要的课程数据以支持小组件的正常显示。';

  @override
  String get privacySection2_4 =>
      '2.4 通知提醒：如果您开启了课程提醒功能，本应用会在您的设备上设置本地通知，以在上课前提醒您。此功能完全在设备本地完成，不涉及数据传输。';

  @override
  String get privacySection3Title => '三、信息的存储与安全';

  @override
  String get privacySection3_1 =>
      '3.1 本地存储：您的个人信息（包括学号、密码、课程数据、成绩等）均存储在您的设备本地，我们不会将这些信息上传至我们的服务器。';

  @override
  String get privacySection3_2 =>
      '3.2 传输安全：本应用与学校服务器之间的数据传输采用加密通信，确保您的信息在传输过程中的安全性。';

  @override
  String get privacySection3_3 =>
      '3.3 数据清除：您可以随时在设置中清除缓存数据，或通过退出登录来清除账号相关数据。卸载应用将删除本应用存储在您设备上的所有数据。';

  @override
  String get privacySection4Title => '四、第三方服务';

  @override
  String get privacySection4_1 =>
      '4.1 学校教务系统：本应用需要与西安建筑科技大学教务系统进行数据交互，以获取课程、成绩等信息。您的登录凭据仅在您的设备与学校服务器之间传输。';

  @override
  String get privacySection4_2 =>
      '4.2 应用更新服务：本应用通过 Gitee 平台检查版本更新信息，此过程中不会传输您的个人信息。';

  @override
  String get privacySection4_3 => '4.3 本应用不会将您的个人信息分享、出售或出租给任何第三方。';

  @override
  String get privacySection5Title => '五、您的权利';

  @override
  String get privacySection5_1 => '5.1 访问和更正：您可以在应用内直接查看和更正您的个人信息。';

  @override
  String get privacySection5_2 => '5.2 删除数据：您可以通过退出登录、清除缓存或卸载应用来删除您的数据。';

  @override
  String get privacySection5_3 =>
      '5.3 撤回同意：您可以通过退出登录或卸载应用来撤回对本隐私协议的同意。但撤回同意不影响撤回前基于您同意已进行的个人信息处理活动的效力。';

  @override
  String get privacySection6Title => '六、未成年人保护';

  @override
  String get privacySection6_1 =>
      '6.1 本应用主要面向高等院校在校学生。如果您是未满18周岁的未成年人，请在监护人指导下使用本应用。';

  @override
  String get privacySection6_2 =>
      '6.2 我们不会主动收集未成年人的个人信息。如您发现我们在未获监护人同意的情况下收集了未成年人的个人信息，请联系我们进行删除。';

  @override
  String get privacySection7Title => '七、隐私协议的更新';

  @override
  String get privacySection7_1 =>
      '7.1 我们可能会适时更新本隐私协议。更新后的协议将在应用内发布，并在重大变更时通过应用内通知提醒您。';

  @override
  String get privacySection7_2 =>
      '7.2 请您定期查看本隐私协议，以了解我们如何保护您的信息。如您在协议更新后继续使用本应用，即视为您同意更新后的隐私协议。';

  @override
  String get privacySection8Title => '八、联系我们';

  @override
  String get privacySection8_1 => '如果您对本隐私协议或个人信息保护有任何疑问、意见或建议，请通过以下方式联系我们：';

  @override
  String get privacyContact =>
      '开发团队：Lumaris Team\n代码仓库：https://gitee.com/luckyfishisdashen/iOSClub.AppMobile';

  @override
  String get userAgreementTitle => '光序 用户协议';

  @override
  String get userAgreementUpdatedAt => '更新日期：2026年5月5日';

  @override
  String get userAgreementEffectiveAt => '生效日期：2026年5月5日';

  @override
  String get userAgreementIntro =>
      '欢迎使用 光序（以下简称“本应用”）。本应用由 Lumaris Team（以下简称“我们”）开发和运营。请您在使用本应用前仔细阅读本用户协议（以下简称“本协议”）。您使用本应用即表示您已阅读、理解并同意接受本协议的全部内容。如果您不同意本协议的任何条款，请停止使用本应用。';

  @override
  String get userAgreementSection1Title => '一、服务说明';

  @override
  String get userAgreementSection1_1 =>
      '1.1 本应用是西安建筑科技大学 iOS Club 开发的校园助手应用，旨在为在校学生提供便捷的校园信息服务，包括但不限于课程管理、成绩查询、校车时刻、电费查询、饭卡消费记录、校园网流量查询、培养方案查看等功能。';

  @override
  String get userAgreementSection1_2 =>
      '1.2 本应用的部分功能需要连接学校内部网络才能正常使用。我们不对因网络环境限制导致的功能不可用承担责任。';

  @override
  String get userAgreementSection1_3 =>
      '1.3 本应用显示的课程、成绩等信息来源于学校教务系统，仅供参考。如有差异，以学校官方系统数据为准。';

  @override
  String get userAgreementSection2Title => '二、用户账号与安全';

  @override
  String get userAgreementSection2_1 =>
      '2.1 您需要使用学校教务系统账号（学号和密码）登录本应用的教务相关功能。您应对自己的账号和密码的安全性负责，妥善保管账号信息。';

  @override
  String get userAgreementSection2_2 =>
      '2.2 您的登录凭据仅存储在您的设备本地，用于与学校服务器进行身份认证。我们不会收集或上传您的密码至任何第三方服务器。';

  @override
  String get userAgreementSection2_3 =>
      '2.3 如您发现账号存在安全风险或未经授权的使用，应及时修改密码并通知我们。';

  @override
  String get userAgreementSection3Title => '三、用户行为规范';

  @override
  String get userAgreementSection3_1 =>
      '3.1 您在使用本应用时应遵守中华人民共和国相关法律法规，不得利用本应用从事违法违规活动。';

  @override
  String get userAgreementSection3_2 =>
      '3.2 您不得对本应用进行反向工程、反向编译、反汇编或以其他方式试图获取本应用的源代码。但本应用作为 MIT 许可证下的开源项目，您可以通过官方代码仓库合法获取源代码。';

  @override
  String get userAgreementSection3_3 =>
      '3.3 您不得利用任何技术手段干扰本应用的正常运行，包括但不限于网络攻击、数据抓取、恶意注入等行为。';

  @override
  String get userAgreementSection3_4 =>
      '3.4 您不得利用本应用的功能漏洞获取未经授权的信息或进行非法操作。如发现漏洞，请及时联系我们。';

  @override
  String get userAgreementSection4Title => '四、知识产权';

  @override
  String get userAgreementSection4_1 =>
      '4.1 本应用的源代码基于 MIT 许可证开源发布，您可以在遵守 MIT 许可证的前提下自由使用、修改和分发本应用的源代码。';

  @override
  String get userAgreementSection4_2 =>
      '4.2 本应用的名称、图标、UI 设计等归 Lumaris Team 所有，未经授权不得用于商业目的。';

  @override
  String get userAgreementSection4_3 => '4.3 本应用中涉及的学校名称、标识等归西安建筑科技大学所有。';

  @override
  String get userAgreementSection5Title => '五、免责声明';

  @override
  String get userAgreementSection5_1 =>
      '5.1 本应用按“现状”提供，我们不对本应用的准确性、可靠性、完整性、及时性做任何明示或暗示的保证。';

  @override
  String get userAgreementSection5_2 =>
      '5.2 由于网络故障、系统维护、学校服务器问题或其他不可抗力因素导致的服务中断或数据不准确，我们不承担相关责任。';

  @override
  String get userAgreementSection5_3 =>
      '5.3 本应用中的课程、成绩等信息仅供参考，最终以学校官方系统数据为准。因依赖本应用数据而产生的任何直接或间接损失，我们不承担责任。';

  @override
  String get userAgreementSection5_4 =>
      '5.4 我们不对因您使用本应用而导致的设备损坏、数据丢失或其他损害承担责任，除非该等损害是由我们的故意或重大过失造成的。';

  @override
  String get userAgreementSection6Title => '六、协议的修改与终止';

  @override
  String get userAgreementSection6_1 =>
      '6.1 我们保留随时修改本协议的权利。修改后的协议将在应用内发布，重大变更将通过应用内通知告知。';

  @override
  String get userAgreementSection6_2 =>
      '6.2 如您在协议修改后继续使用本应用，即视为您同意修改后的协议。如您不同意修改后的协议，应停止使用本应用。';

  @override
  String get userAgreementSection6_3 =>
      '6.3 我们有权在以下情况下终止向您提供服务：（1）您违反本协议的相关约定；（2）因法律法规或政策要求的变更；（3）因学校相关系统政策变更导致无法继续提供服务。';

  @override
  String get userAgreementSection7Title => '七、其他条款';

  @override
  String get userAgreementSection7_1 =>
      '7.1 本协议中的任何条款无论因何种原因完全或部分无效或不具有执行力，其余条款仍应有效并具有约束力。';

  @override
  String get userAgreementSection7_2 => '7.2 本协议的订立、执行和解释及争议的解决均适用中华人民共和国法律。';

  @override
  String get userAgreementSection7_3 =>
      '7.3 如您和我们就本协议内容或其执行发生任何争议，应通过友好协商解决；协商不成的，任何一方均可向有管辖权的人民法院提起诉讼。';

  @override
  String get userAgreementSection8Title => '八、联系我们';

  @override
  String get userAgreementSection8_1 => '如果您对本协议有任何疑问、意见或建议，请通过以下方式联系我们：';

  @override
  String get userAgreementContact =>
      '开发团队：Lumaris Team\n代码仓库：https://gitee.com/luckyfishisdashen/iOSClub.AppMobile';

  @override
  String get aboutAuthor => '关于作者';

  @override
  String get coreTeam => '核心团队';

  @override
  String get specialThanks => '特别致谢';

  @override
  String get contactUs => '联系我们';

  @override
  String get thanksTitle => '致谢';

  @override
  String get thanksContent =>
      '感谢所有为本项目贡献代码、提出建议和报告问题的开发者和用户。你们的支持是我们前进的动力。特别感谢所有测试人员在开发阶段的辛勤付出。';

  @override
  String get githubRepository => 'GitHub 仓库';

  @override
  String get joinUs => '加入我们';

  @override
  String get madeWithLove => 'Made with ❤️ in Xi\'an';

  @override
  String get easterEggTitle => '🎉 彩蛋';

  @override
  String get easterEggFound => '恭喜你发现了隐藏彩蛋！';

  @override
  String get easterEggContent =>
      '你是少数知道这个秘密的人之一！\n\n感谢你对光序的喜爱与支持。\n\n继续探索，也许还有更多惊喜等着你...';

  @override
  String get fontSetting => '字体设置';

  @override
  String get fontSettingSubtitle => '为桌面平台选择字体(下次打开时才会应用)';

  @override
  String get systemDefault => '系统默认';

  @override
  String get customFont => '自定义';

  @override
  String get hapticFeedback => '触觉反馈';

  @override
  String get hapticFeedbackSubtitle => '底部导航栏点击时震动';

  @override
  String get cloudSyncTodo => '是否将待办保存至云端';

  @override
  String get servicePaused => '该服务已暂停';

  @override
  String get showTomorrowCourses => '显示明日课程';

  @override
  String get showTomorrowCoursesSubtitle => '当今日无课时显示明日课程';

  @override
  String get courseReminder => '课程通知';

  @override
  String get courseReminderSubtitle => '上课前进行提醒';

  @override
  String get remindMinutesBefore => '提前几分钟提醒';

  @override
  String remindMinutes(Object n) {
    return '$n分钟';
  }

  @override
  String get todoReminder => '待办事务提醒';

  @override
  String get todoReminderSubtitle => '在待办事务截止前进行提醒';

  @override
  String get schedulePage => '课程页';

  @override
  String get scorePage => '成绩页';

  @override
  String get profilePage => '个人页';

  @override
  String get firstPageOnLaunch => '打开应用的第一个页面';

  @override
  String get sunday => '周日';

  @override
  String get monday => '周一';

  @override
  String get tuesday => '周二';

  @override
  String get wednesday => '周三';

  @override
  String get thursday => '周四';

  @override
  String get friday => '周五';

  @override
  String get saturday => '周六';

  @override
  String get sundayShort => '日';

  @override
  String get mondayShort => '一';

  @override
  String get tuesdayShort => '二';

  @override
  String get wednesdayShort => '三';

  @override
  String get thursdayShort => '四';

  @override
  String get fridayShort => '五';

  @override
  String get saturdayShort => '六';

  @override
  String get janShort => '1月';

  @override
  String get febShort => '2月';

  @override
  String get marShort => '3月';

  @override
  String get aprShort => '4月';

  @override
  String get mayShort => '5月';

  @override
  String get junShort => '6月';

  @override
  String get julShort => '7月';

  @override
  String get augShort => '8月';

  @override
  String get sepShort => '9月';

  @override
  String get octShort => '10月';

  @override
  String get novShort => '11月';

  @override
  String get decShort => '12月';

  @override
  String weekUnit(Object n) {
    return '$n周';
  }

  @override
  String currentWeek(Object n) {
    return '当前为第$n周';
  }

  @override
  String weeksUntilStart(Object n) {
    return '距离开学还有$n周';
  }

  @override
  String periodRange(Object end, Object start) {
    return '第$start-$end节';
  }

  @override
  String get allSchedules => '全部课表';

  @override
  String get previousWeek => '上一周';

  @override
  String get nextWeek => '下一周';

  @override
  String get switchStyle => '切换样式';

  @override
  String get refreshSchedule => '刷新课表';

  @override
  String get scheduleSettingsTitle => '课表设置';

  @override
  String get compact => '紧凑';

  @override
  String get standard => '标准';

  @override
  String get relaxed => '宽松';

  @override
  String get selectCourse => '选择要查看的课程';

  @override
  String get editCourse => '编辑课程';

  @override
  String get deleteCourse => '删除课程';

  @override
  String get confirmDelete => '确认删除';

  @override
  String confirmDeleteCourseContent(Object name) {
    return '确定要删除课程\"$name\"吗？';
  }

  @override
  String get delete => '删除';

  @override
  String get courseModified => '课程修改成功';

  @override
  String get courseDeleted => '课程删除成功';

  @override
  String get deleteFailed => '删除失败';

  @override
  String get noLocation => '无地点';

  @override
  String get addCourse => '添加课程';

  @override
  String get save => '保存';

  @override
  String get courseName => '课程名称';

  @override
  String get courseRoom => '上课地点';

  @override
  String get courseTeacher => '授课教师';

  @override
  String get courseCredits => '课程学分';

  @override
  String get courseWeekday => '星期几';

  @override
  String get courseStartUnit => '开始节次';

  @override
  String get courseEndUnit => '结束节次';

  @override
  String get courseWeeks => '上课周次';

  @override
  String selectedWeeks(Object count) {
    return '已选$count周';
  }

  @override
  String get customCourses => '自定义课程';

  @override
  String customCoursesCount(Object count) {
    return '$count 门课程';
  }

  @override
  String get noCustomCourses => '暂无自定义课程';

  @override
  String get noCustomCoursesSubtitle => '点击右上角 + 号添加课程';

  @override
  String get readingCustomCourses => '正在读取自定义课程';

  @override
  String get readingCustomCoursesSubtitle => '正在整理本地保存的课程配置';

  @override
  String get courseAdded => '课程添加成功';

  @override
  String get scoresAndGpa => '成绩与绩点';

  @override
  String get passedCourses => '通过课程';

  @override
  String get totalCredits => '总学分';

  @override
  String get creditInfoTitle => '说明';

  @override
  String get creditInfoContent => '这里的学分是按照成绩算出来的，只要没有挂科就OK。教务系统给的一般来说要小于等于这个数';

  @override
  String get noScores => '没有成绩';

  @override
  String get noScoresSubtitle => '建议刷新或退出重进';

  @override
  String get refreshDataBtn => '刷新数据';

  @override
  String get goToLogin => '前往登录';

  @override
  String get minorCourse => '辅修课程';

  @override
  String get scoreDetail => '成绩详情';

  @override
  String get courseCreditLabel => '课程学分';

  @override
  String get courseScoreLabel => '课程成绩';

  @override
  String get courseGpaLabel => '课程绩点';

  @override
  String get fetchingScores => '正在获取成绩数据...';

  @override
  String get refreshFailedFallback => '刷新失败，已回退到本地数据';

  @override
  String get fetchTimeout => '获取数据超时，请检查网络连接后重试';

  @override
  String get fetchFailed => '获取数据失败';

  @override
  String get pleaseLoginFirst => '请先去登录即可查看成绩';

  @override
  String get readingScoresSubtitle => '正在读取缓存并同步教务成绩，网络较慢时可能需要几秒';

  @override
  String get foolishModeMessage => '是的，在下绩点5.0';

  @override
  String creditUnit(Object credit) {
    return '$credit 学分';
  }

  @override
  String gradeLabel(Object grade) {
    return '成绩 $grade';
  }

  @override
  String gpaLabel(Object gpa) {
    return '绩点 $gpa';
  }

  @override
  String scheduleCourseTime(
      Object end, Object start, Object weekRanges, Object weekday) {
    return '$weekRanges周 每周$weekday 第$start-$end节';
  }

  @override
  String semesterRange(Object end, Object num, Object start) {
    return '$start至$end年 第$num学期';
  }

  @override
  String get semesterAutumnShort => '上';

  @override
  String get semesterSpringShort => '下';

  @override
  String get year1 => '大一';

  @override
  String get year2 => '大二';

  @override
  String get year3 => '大三';

  @override
  String get year4 => '大四';

  @override
  String get year5 => '大五';

  @override
  String get year6 => '大六';

  @override
  String get year7 => '大七';

  @override
  String get year8 => '大八';

  @override
  String get year9 => '大九';

  @override
  String get year10 => '大十';

  @override
  String get loginTitle => '登录教务系统';

  @override
  String get loginSubtitle => '请使用您的账号继续';

  @override
  String get studentId => '学号';

  @override
  String get password => '统一身份认证密码';

  @override
  String get forgotPassword => '忘记密码?';

  @override
  String get loggingIn => '正在登录教务系统';

  @override
  String get loggingInSubtitle => '正在验证账号并同步课程、成绩等基础数据，首次登录可能需要几秒';

  @override
  String get emptyCredentials => '用户名和密码不能为空';

  @override
  String get loginTimeoutEdu => '教务系统登录超时，请检查网络连接';

  @override
  String get loginFailed => '登录失败，请检查用户名和密码';

  @override
  String get loginTimeout => '登录超时，请检查网络连接后重试';

  @override
  String get loginSecurityStorageUnavailable =>
      '登录成功，但安全存储不可用，下次启动后可能需要重新输入账号密码';

  @override
  String get loadingDefaultTitle => '正在同步数据';

  @override
  String get loadingDefaultSubtitle => '网络较慢时可能需要几秒，请稍等一下';

  @override
  String get errorOccurred => '出错了';

  @override
  String get retry => '重试';

  @override
  String get loadFailed => '加载失败';

  @override
  String get noData => '暂无数据';

  @override
  String get ok => '确定';

  @override
  String get classroom => '上课地点';

  @override
  String get teacherLabel => '授课教师';

  @override
  String get classTime => '上课时间';

  @override
  String get classCampus => '上课校区';

  @override
  String get todayScheduleLabel => '今日课表';

  @override
  String get tomorrowSchedule => '明日课表';

  @override
  String get noCourseToday => '今天没有课了';

  @override
  String get noCourseTodaySubtitle => '好好休息会儿吧，学一天累死个人';

  @override
  String get showTomorrowSchedule => '显示明天的课表';

  @override
  String get doubleTapExit => '再按一次退出应用';

  @override
  String copySuccess(Object text) {
    return '已复制: $text';
  }

  @override
  String get copyTooltip => '复制文本';

  @override
  String get pageSettings => '页面设置';

  @override
  String get showBusTile => '显示校车磁贴';

  @override
  String get showBusTileSubtitle => '在首页显示最近的班车信息';

  @override
  String get addToHome => '添加到首页';

  @override
  String get showElectricityTile => '在首页显示电费磁贴';

  @override
  String get electricityRecharge => '电费充值';

  @override
  String get electricityRechargeSubtitle => '跳转至微信进行电费充值';

  @override
  String get showPaymentTile => '显示饭卡磁贴';

  @override
  String get showPaymentTileSubtitle => '在首页显示余额概览';

  @override
  String get addTodo => '添加待办';

  @override
  String get todoTitle => '标题';

  @override
  String get deadline => '截止日期';

  @override
  String get change => '更改';

  @override
  String get edit => '编辑';

  @override
  String get done => '完成';

  @override
  String get todoListLabel => '待办事务';

  @override
  String get readingTodos => '正在读取待办事务';

  @override
  String get readingTodosSubtitle => '正在加载本地待办列表与提醒状态';

  @override
  String get noTodos => '当前没有待办事务';

  @override
  String get noTodosSubtitle => '点击右上角添加待办事项';

  @override
  String get todoLoadFailedSubtitle => '无法加载待办事项';

  @override
  String deadlineLabel(Object date) {
    return '截止日期: $date';
  }

  @override
  String get noDeadline => '无';

  @override
  String get titleRequired => '标题是必须项';

  @override
  String get deadlineRequired => '截至日期是必须项';

  @override
  String get add => '添加';

  @override
  String get upcomingExams => '近期考试';

  @override
  String get loadingExams => '正在加载考试信息';

  @override
  String get loadingExamsSubtitle => '正在同步近期考试安排、考场和座位信息';

  @override
  String get noExams => '最近没有考试';

  @override
  String get noExamsSubtitle => '说不定刷新一下就有了';

  @override
  String get examTime => '考试时间';

  @override
  String get examLocation => '考试地点';

  @override
  String get seatNumber => '座位号';

  @override
  String seatNumberLabel(Object seat) {
    return '座位号 $seat';
  }

  @override
  String get examNotLoggedIn => '未登录，请先登录';

  @override
  String get examAuthFailed => '认证失败，请重新登录';

  @override
  String get examFetchFailed => '获取考试信息失败，轻点重试';

  @override
  String get quickFeatures => '快捷功能';

  @override
  String get noQuickFeatures => '暂无快捷功能';

  @override
  String get noQuickFeaturesSubtitle => '请在编辑模式中添加';

  @override
  String get moreFeatures => '更多功能';

  @override
  String get scheduleWidgetTitle => '导入到日历';

  @override
  String get subscriptionLink => '订阅链接';

  @override
  String get copiedSuccess => '复制成功!';

  @override
  String get howToImport => '不会导入？';

  @override
  String get customCourseManage => '自定义课程管理';

  @override
  String get noBackground => '无背景';

  @override
  String get customImage => '自定义图片';

  @override
  String get noImageSelected => '未选择图片';

  @override
  String get noCalendarApp => '没有找到日历应用，请手动导入';

  @override
  String get cannotOpenCalendar => '无法打开日历应用';

  @override
  String get bgImageSetSuccess => '背景图片设置成功';

  @override
  String get selectImageFailed => '选择图片失败';

  @override
  String get addCalendarSub => '添加日历订阅';

  @override
  String get understand => '明白了';

  @override
  String get calendarSubscription => '日历订阅';

  @override
  String get scheduleManagement => '课表管理';

  @override
  String get scheduleBackground => '课表背景';

  @override
  String get ignoreCourses => '忽略课程';

  @override
  String get loadingSchedule => '正在加载课表';

  @override
  String get loadingScheduleSubtitle => '正在读取课程、偏好设置和背景配置';

  @override
  String get updatingSchedule => '正在更新课表...';

  @override
  String get updateComplete => '更新完成';

  @override
  String get updateTimeout => '更新超时，请检查网络连接后重试';

  @override
  String updateFailed(Object error) {
    return '更新失败: $error';
  }

  @override
  String get linkCopiedToClipboard => '链接已复制到剪贴板';

  @override
  String get currentWeekLabel => '本周';

  @override
  String periodUnit(Object n) {
    return '第$n节';
  }

  @override
  String get calendarGuidanceIntro => '您的设备似乎没有应用可以直接处理日历订阅。请按照以下步骤手动添加:';

  @override
  String get calendarGuidanceStep1 => '1. 打开您的日历应用';

  @override
  String get calendarGuidanceStep2 => '2. 找到\"添加日历\"或\"订阅\"选项';

  @override
  String get calendarGuidanceStep3 => '3. 选择\"通过URL添加\"或类似选项';

  @override
  String get calendarGuidanceStep4 => '4. 粘贴以下链接:';

  @override
  String get calendarGuidanceNote =>
      '注意: 不同的日历应用可能有不同的添加步骤。如果您遇到困难，请查阅您的日历应用帮助文档。';

  @override
  String get profileReading => '正在读取账号信息';

  @override
  String get profileReadingSubtitle => '正在同步本地登录状态和个人资料入口，请稍等一下';

  @override
  String get campusNavigation => '校园导航';

  @override
  String get settingsAbout => '设置/关于';

  @override
  String get programLabel => '培养方案';

  @override
  String get campusMap => '校园地图';

  @override
  String get help => '帮助';

  @override
  String get academicAccount => '教务系统账号';

  @override
  String get guest => '游客';

  @override
  String get syncingAcademic => '正在同步学业信息';

  @override
  String get syncingAcademicSubtitle => '正在读取学分与个人信息卡片';

  @override
  String get loginEduSystem => '登录教务系统';

  @override
  String get programLoading => '正在加载培养方案';

  @override
  String get programLoadingSubtitle => '正在整理学期课程结构和课程类别，请稍等一下';

  @override
  String get programLoadFailed => '加载失败';

  @override
  String get programNoData => '暂无数据';

  @override
  String get programRefreshFailed => '刷新失败，当前展示的是上次同步的培养方案';

  @override
  String get linkLoading => '正在加载导航链接';

  @override
  String get linkLoadingSubtitle => '正在整理常用站点与分类入口';

  @override
  String get linkLoadFailed => '加载失败';

  @override
  String get linkNoData => '暂无导航数据';

  @override
  String get linkNoDataSubtitle => '请重新进入此页，或检查当前网络';

  @override
  String get paymentLoading => '正在同步饭卡余额';

  @override
  String get paymentLoadingSubtitle => '正在获取最新流水，请稍候...';

  @override
  String get campusCard => '校园一卡通';

  @override
  String get currentBalance => '当前余额';

  @override
  String get recentTransactions => '最近交易';

  @override
  String get paymentFilter => '支付';

  @override
  String get consumptionFilter => '消费';

  @override
  String get rechargeFilter => '充值';

  @override
  String get noCardData => '无饭卡数据';

  @override
  String get noCardDataSubtitle => '请登录教务处账号以查看余额和交易流水';

  @override
  String get busLoading => '正在获取校车班次';

  @override
  String get busLoadingSubtitle => '正在按日期整理两校区往返班车信息';

  @override
  String get noBusToday => '今天没有车了';

  @override
  String get noBusTodaySubtitle => '明天再来吧';

  @override
  String get departureTime => '出发时间';

  @override
  String get destination => '终点站';

  @override
  String get estimatedArrival => '预计到达';

  @override
  String get busInfo => '班次信息';

  @override
  String get departure => '出发';

  @override
  String get arrival => '到达';

  @override
  String get netRefreshFailed => '刷新失败，已保留当前校园网数据';

  @override
  String get netData => '校园网数据';

  @override
  String get usedTraffic => '已用流量';

  @override
  String onlineDuration(Object time) {
    return '在线时长: $time';
  }

  @override
  String get username => '用户名';

  @override
  String get ipAddress => 'IP 地址';

  @override
  String get productPackage => '产品套餐';

  @override
  String get unknown => '未知';

  @override
  String get copiedToClipboard => '已复制到剪贴板';

  @override
  String get netLoading => '正在读取校园网数据';

  @override
  String get netLoadingSubtitle => '正在同步流量、在线时长和账号信息';

  @override
  String get netLoadFailed => '加载失败';

  @override
  String get netNoData => '暂无数据';

  @override
  String get electricityBalance => '当前余额';

  @override
  String get electricityNoData => '暂无数据';

  @override
  String get electricityLowBalance => '余额不足，请及时充值';

  @override
  String get electricitySufficient => '余额充足';

  @override
  String get electricityAddTip => '点击右上角添加电费数据';

  @override
  String get electricityLoading => '正在刷新用电趋势';

  @override
  String get electricityLoadingSubtitle => '正在读取最新电费记录';

  @override
  String get noUsageDetails => '没有用电明细';

  @override
  String get noUsageDetailsSubtitle => '刷新后会在这里展示每小时花费';

  @override
  String get electricityCost => '用电花费';

  @override
  String lastNDays(Object n) {
    return '近$n天';
  }

  @override
  String get totalCost => '总计花费';

  @override
  String get todayCost => '今日花费';

  @override
  String get avgDailyCost => '日均花费';

  @override
  String get peakHours => '峰值时段';

  @override
  String get hourlyDetails => '每小时明细';

  @override
  String get lowBalanceSub => '低余额订阅';

  @override
  String get lowBalanceSubDesc => '当余额低于阈值时...';

  @override
  String get addElectricityFirst => '先添加电费页面后...';

  @override
  String get noElectricityData => '还没有电费数据';

  @override
  String get noElectricityDataSubtitle => '先在本页绑定宿舍电费链接...';

  @override
  String get lowBalanceEnabled => '已开启低余额提醒';

  @override
  String get addLowBalanceAlert => '添加低余额提醒';

  @override
  String get deleteSubscription => '删除订阅';

  @override
  String get deleteSubDesc => '取消当前邮箱的低余额提醒...';

  @override
  String get electricityManagement => '电费管理';

  @override
  String get chooseAction => '选择要执行的操作';

  @override
  String get changeRoom => '更换房间';

  @override
  String get getElectricity => '获取电费';

  @override
  String get electricityUrlPrompt => '请打开建大财务处电费详情页面，复制页面URL并粘贴到下方输入框';

  @override
  String get urlPlaceholder => '请输入URL';

  @override
  String get createLowBalanceAlert => '添加低余额提醒';

  @override
  String get lowBalanceAlertDesc => '系统会使用当前绑定的宿舍电费页面，在余额低于设定阈值时发送邮件提醒。';

  @override
  String get remindEmail => '提醒邮箱';

  @override
  String get remindEmailPlaceholder => '提醒邮箱';

  @override
  String get remindThreshold => '提醒阈值，例如 10';

  @override
  String get remindThresholdPlaceholder => '提醒阈值，例如 10';

  @override
  String get pleaseEnterEmail => '请输入提醒邮箱';

  @override
  String get pleaseEnterValidEmail => '请输入有效的邮箱地址';

  @override
  String get pleaseEnterThreshold => '请输入大于 0 的提醒阈值';

  @override
  String get lowBalanceAlertCreated => '低余额提醒已创建';

  @override
  String get createSubFailed => '创建电费订阅失败';

  @override
  String currentSubInfo(Object email, Object threshold) {
    return '当前邮箱 $email 低于 $threshold 元时提醒';
  }

  @override
  String get subSetupHint => '设置阈值后，余额低于该金额时将通过邮箱提醒';

  @override
  String get remindEmailLabel => '提醒邮箱';

  @override
  String get notSet => '未设置';

  @override
  String get remindThresholdLabel => '提醒阈值';

  @override
  String get gotIt => '知道了';

  @override
  String get noSubToDelete => '当前没有可删除的订阅';

  @override
  String get deleteSubTitle => '删除订阅';

  @override
  String get deleteSubConfirmContent => '确定要删除当前的低余额订阅吗？';

  @override
  String get lowBalanceAlertDeleted => '低余额提醒已删除';

  @override
  String get deleteSubFailed => '删除电费订阅失败';

  @override
  String get electricitySubLoadFailed => '加载电费订阅失败';

  @override
  String get subscriptionDetail => '订阅内容';

  @override
  String get create => '创建';

  @override
  String get webNotSupported => '暂不支持Web版';

  @override
  String get webNotSupportedSubtitle => '请使用其他版本';

  @override
  String get reorderFailed => '重新排序失败';

  @override
  String get searchLocation => '搜索地点或建筑...';

  @override
  String get search => '搜索...';

  @override
  String get buildingIntro => '建筑介绍';

  @override
  String get specificLocation => '具体位置';

  @override
  String get licenseTitle => '开源许可证';

  @override
  String get licenseLoading => '正在读取许可证';

  @override
  String get licenseLoadingSubtitle => '正在加载应用附带的开源协议文本';

  @override
  String get licenseLoadFailed => '无法加载许可证文件';

  @override
  String get helpFeaturesTab => '功能介绍';

  @override
  String get helpInstructionsTab => '使用说明';

  @override
  String get helpNotesTab => '注意事项';

  @override
  String get helpAboutTab => '关于应用';

  @override
  String get helpFeatureHome => '首页';

  @override
  String get helpFeatureHomeDesc => '信息中心，展示个人信息、课程、待办事项和考试安排';

  @override
  String get helpFeatureSchedule => '课程表';

  @override
  String get helpFeatureScheduleDesc => '管理周课程安排，支持切换校区和设置提醒';

  @override
  String get helpFeatureScore => '成绩查询';

  @override
  String get helpFeatureScoreDesc => '查看学期成绩单、绩点计算和分析';

  @override
  String get helpFeatureProfile => '个人资料';

  @override
  String get helpFeatureProfileDesc => '展示学号、姓名、学院等个人信息';

  @override
  String get helpFeatureBus => '校园巴士';

  @override
  String get helpFeatureBusDesc => '查看校区间班车时刻表和路线信息';

  @override
  String get helpFeatureProgram => '培养方案';

  @override
  String get helpFeatureProgramDesc => '显示专业培养计划和学分要求';

  @override
  String get helpFeatureElectricity => '电费查询';

  @override
  String get helpFeatureElectricityDesc => '查看宿舍电量和用电历史记录';

  @override
  String get helpFeaturePayment => '饭卡消费';

  @override
  String get helpFeaturePaymentDesc => '查看饭卡余额和消费明细';

  @override
  String get helpFeatureNet => '校园网';

  @override
  String get helpFeatureNetDesc => '查看网络流量使用情况和统计';

  @override
  String get helpFeatureLinks => '常用链接';

  @override
  String get helpFeatureLinksDesc => '收集教务系统等常用工具链接';

  @override
  String get helpInstructionLogin => '登录与账户';

  @override
  String get helpInstructionLoginDesc => '首次使用需登录教务系统账户';

  @override
  String get helpInstructionCourse => '课程管理';

  @override
  String get helpInstructionCourseDesc => '进入课程表查看当周课程，左右滑动切换周次，点击课程查看详情';

  @override
  String get helpInstructionReminder => '日程提醒';

  @override
  String get helpInstructionReminderDesc => '在设置中开启课程提醒，应用会在上课前发送通知提醒';

  @override
  String get helpInstructionSync => '数据同步';

  @override
  String get helpInstructionSyncDesc => '应用自动同步教务系统数据，需要网络连接。下拉刷新可手动更新';

  @override
  String get helpInstructionWidget => '桌面小组件';

  @override
  String get helpInstructionWidgetDesc => '在桌面长按添加应用小组件，快速查看课程信息';

  @override
  String get helpNoteNetwork => '部分功能需要连接校园网才能正常使用';

  @override
  String get helpNoteUpdate => '请保持应用更新以获得最新功能和修复';

  @override
  String get helpNoteData => '数据不准确时，请检查是否正确登录教务系统';

  @override
  String get helpNoteFeedback => '遇到问题可通过设置页面进行反馈';

  @override
  String get helpNotePrivacy => '应用不会收集或上传您的个人隐私信息';

  @override
  String get helpAboutPlatform => '平台支持';

  @override
  String get helpAboutPlatformDesc => '跨平台应用，支持以下平台：';

  @override
  String get helpAboutOpenSource => '开源项目';

  @override
  String get helpAboutOpenSourceDesc => '本应用基于 MIT 许可证开源';

  @override
  String get helpAboutRepoLabel => '仓库地址：';

  @override
  String get underMaintenanceTitle => '正在维护！';

  @override
  String get underMaintenanceDescription => '我们目前正在进行定期维护。请稍后再查看。感谢您的耐心等待。';

  @override
  String get readingPaymentCard => '正在读取饭卡';

  @override
  String get lowBalance => '余额不足';

  @override
  String get campusCardBalance => '饭卡余额';

  @override
  String get tapToView => '点击查看';

  @override
  String get tapToSubscribe => '点击订阅';

  @override
  String get campusCaoTang => '草堂';

  @override
  String get campusYanTa => '雁塔';

  @override
  String get busRefreshStale => '刷新完成，已保留上次校车数据';

  @override
  String get poiMainLibrary => '主图书馆';

  @override
  String get poiMainLibraryDesc => '24小时开放自习室';

  @override
  String get poiCaoTangNorthGate => '草堂校区北门';

  @override
  String get poiCaoTangNorthGateDesc => '学校主入口';

  @override
  String get poiYanTaEastGate => '雁塔校区东门';

  @override
  String get poiYanTaEastGateDesc => '历史悠久的老校区入口';

  @override
  String durationDHMS(Object d, Object h, Object m, Object s) {
    return '$d天$h小时$m分$s秒';
  }

  @override
  String get shortcuts => '快捷功能';

  @override
  String get moreFunctions => '更多功能';

  @override
  String get noShortcuts => '暂无快捷功能';

  @override
  String get addInEditMode => '请在编辑模式中添加';

  @override
  String get eduSystem => '教务系统';
}
