import 'package:flutter/cupertino.dart';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:ios_club_app/core/services/data_service.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

class ScheduleSettingPage extends StatefulWidget {
  const ScheduleSettingPage({super.key});

  @override
  State<ScheduleSettingPage> createState() => _ScheduleSettingPageState();
}

class _ScheduleSettingPageState extends State<ScheduleSettingPage>
    with AutomaticKeepAliveClientMixin {
  final CourseStore courseStore = CourseStore.to;
  final SettingsStore settingsStore = SettingsStore.to;
  List<String> totalList = [];
  List<String> ignoreList = [];
  late List<CourseIgnore> _ignores = [];
  String url = "";
  final ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _loadCredentials();
    await _loadCourseData();
  }

  Future<void> _loadCredentials() async {
    try {
      final prefs = PrefsService.instance;
      final username = prefs.getString('username');
      final password = prefs.getString('password');

      if (username != null && password != null) {
        setState(() {
          url =
              '://schedule.xauat.site/class?school=xauat&username=$username&password=$password';
        });
      }
    } catch (e) {
      AppLogger.debug('Failed to load credentials: $e');
    }
  }

  Future<void> _loadCourseData() async {
    try {
      await courseStore.loadIgnoreCourses();
      final courseNames = await DataService.getCourseName();

      final ignores = courseNames
          .map((i) => CourseIgnore(
                title: i,
                isCompleted: courseStore.ignoreCourses.isNotEmpty &&
                    courseStore.ignoreCourses.any((x) => x == i),
              ))
          .toList();

      setState(() {
        ignoreList = courseStore.ignoreCourses;
        totalList = courseNames;
        _ignores = ignores;
      });
    } catch (e) {
      AppLogger.debug('Failed to load course data: $e');
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDesktop = PlatformUtils.isDesktop;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;

    return Scaffold(
        appBar: ClubAppBar(
          title: '课表设置',
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isDesktop) ...[
                _buildSectionTitle('日历订阅'),
                const SizedBox(height: 12),
                _buildCalendarSection(context, isDark, cardColor),
                const SizedBox(height: 24),
              ],
              _buildSectionTitle('课表管理'),
              const SizedBox(height: 12),
              _buildManagementSection(context, isDark, cardColor),
              const SizedBox(height: 24),
              _buildSectionTitle('课表背景'),
              const SizedBox(height: 12),
              _buildBackgroundSection(context, isDark, cardColor),
              const SizedBox(height: 24),
              _buildSectionTitle('忽略课程'),
              const SizedBox(height: 12),
              _buildIgnoreCourseSection(context, isDark, cardColor),
            ],
          ),
        ));
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildCalendarSection(
      BuildContext context, bool isDark, Color? cardColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.calendar_today_outlined,
              color: isDark ? Colors.blue[300] : Colors.blue[600],
            ),
            title: const Text(
              '导入到日历',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.open_in_new, size: 20),
              onPressed: () => _launchCalendar(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '订阅链接',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'https$url',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                            fontFamily: 'monospace',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: 'webcal$url'));
                          if (context.mounted) {
                            showClubSnackBar(context, const Text('复制成功!'));
                          }
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => showCalendarGuidanceDialog(context),
                  icon: const Icon(Icons.help_outline, size: 18),
                  label: const Text('不会导入？'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementSection(
      BuildContext context, bool isDark, Color? cardColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.edit_calendar_outlined,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            title: const Text(
              '自定义课程管理',
              style: TextStyle(fontSize: 16),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Get.toNamed('/CustomCourseManage'),
          ),
          ListTile(
            leading: Icon(
              Icons.grid_on_outlined,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            title: const Text(
              '显示课表网格线',
              style: TextStyle(fontSize: 16),
            ),
            trailing: CupertinoSwitch(
              value: settingsStore.showCourseGrid,
              onChanged: (value) {
                setState(() {
                  settingsStore.setShowCourseGrid(value);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundSection(
      BuildContext context, bool isDark, Color? cardColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildBackgroundOption('无背景', '', isDark),
          _buildBackgroundOption('自定义图片', 'custom', isDark),
          if (settingsStore.scheduleBackground == 'custom') ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(56, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      settingsStore.customBackgroundImage.isEmpty
                          ? '未选择图片'
                          : settingsStore.customBackgroundImage,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.folder_outlined, size: 20),
                    onPressed: _pickCustomBackgroundImage,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBackgroundOption(String title, String value, bool isDark) {
    final isSelected = settingsStore.scheduleBackground == value;
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            settingsStore.setScheduleBackground(value);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : (isDark ? Colors.grey[600] : Colors.grey[400]),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIgnoreCourseSection(
      BuildContext context, bool isDark, Color? cardColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _ignores.length,
        itemBuilder: (context, index) {
          final ignore = _ignores[index];
          return CourseIgnoreItem(
            ignore: ignore,
            onChanged: _handleIgnoreChange,
          );
        },
      ),
    );
  }

  Future<void> _launchCalendar(BuildContext context) async {
    if (url == '') {
      return;
    }

    if (PlatformUtils.isAndroid) {
      final intent = AndroidIntent(
        action: 'android.intent.action.VIEW',
        data: 'webcal$url',
        type: 'text/calendar',
      );
      var result = await intent.canResolveActivity();
      if (result != null && result) {
        await intent.launch();
      } else {
        if (context.mounted) {
          showClubSnackBar(
            context,
            const Text('没有找到日历应用，请手动导入'),
          );
        }
      }
      return;
    }

    final Uri uri = Uri.parse('webcal$url');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        showClubSnackBar(
          context,
          const Text('无法打开日历应用'),
        );
      }
    }
  }

  Future<void> _pickCustomBackgroundImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: false,
      );

      if (result != null) {
        String filePath = result.files.single.path ?? result.files.single.name;
        settingsStore.setCustomBackgroundImage(filePath);

        if (mounted) {
          showClubSnackBar(
            context,
            const Text('背景图片设置成功'),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showClubSnackBar(
          context,
          const Text('选择图片失败'),
        );
      }
      AppLogger.debug('选择背景图片失败: $e');
    }
  }

  void _handleIgnoreChange(CourseIgnore ignore, bool value) async {
    setState(() => ignore.isCompleted = value);
    await Future.microtask(() {
      if (value) {
        ignoreList.add(ignore.title);
      } else {
        ignoreList.remove(ignore.title);
      }

      courseStore.setIgnoreCourses(ignoreList);
      return DataService.setIgnore(ignoreList);
    });
  }

  void showCalendarGuidanceDialog(BuildContext context) {
    final httpsUrl = 'webcal$url';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加日历订阅'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('您的设备似乎没有应用可以直接处理日历订阅。请按照以下步骤手动添加:'),
              const SizedBox(height: 16),
              const Text('1. 打开您的日历应用'),
              const Text('2. 找到"添加日历"或"订阅"选项'),
              const Text('3. 选择"通过URL添加"或类似选项'),
              const Text('4. 粘贴以下链接:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        httpsUrl,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: httpsUrl));
                        if (context.mounted) {
                          showClubSnackBar(
                            context,
                            const Text('链接已复制到剪贴板'),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('注意: 不同的日历应用可能有不同的添加步骤。如果您遇到困难，请查阅您的日历应用帮助文档。'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('明白了'),
          ),
        ],
      ),
    );
  }
}

class CourseIgnoreItem extends StatelessWidget {
  final CourseIgnore ignore;
  final Function(CourseIgnore, bool) onChanged;

  const CourseIgnoreItem({
    super.key,
    required this.ignore,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(
        ignore.isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
        color: ignore.isCompleted
            ? Theme.of(context).colorScheme.primary
            : (isDark ? Colors.grey[600] : Colors.grey[400]),
      ),
      title: Text(
        ignore.title,
        style: const TextStyle(fontSize: 16),
      ),
      onTap: () => onChanged(ignore, !ignore.isCompleted),
    );
  }
}

class CourseIgnore {
  String title;
  bool isCompleted;

  CourseIgnore({required this.title, this.isCompleted = false});
}
