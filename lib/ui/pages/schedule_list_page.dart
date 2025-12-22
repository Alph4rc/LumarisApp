import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ios_club_app/core/models/course_model.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/state/schedule_store.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/ui/components/schedule/course_card.dart';
import 'package:ios_club_app/ui/components/schedule/course_detail_sheet.dart';
import 'package:ios_club_app/ui/components/schedule/schedule_grid.dart';
import 'package:ios_club_app/ui/components/schedule/weekday_header.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';
import 'package:ios_club_app/ui/components/schedulePages/custom_course_manage_page.dart';

/// 课表列表页面
///
/// 简约的苹果风格设计，展示完整的课程表
class ScheduleListPage extends StatefulWidget {
  const ScheduleListPage({super.key});

  @override
  State<ScheduleListPage> createState() => _ScheduleListPageState();
}

class _ScheduleListPageState extends State<ScheduleListPage> {
  late PageController _pageController;
  final ScheduleStore scheduleStore = ScheduleStore.to;
  final SettingsStore settingsStore = SettingsStore.to;

  CourseCardStyle _cardStyle = CourseCardStyle.normal;
  bool _showStyleSelector = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: scheduleStore.currentPage);
    _loadPreferences();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final courseSize = prefs.getDouble('course_size') ?? 55;

    setState(() {
      _cardStyle = _determineCourseStyle(courseSize);
    });
  }

  CourseCardStyle _determineCourseStyle(double size) {
    if (size == 50) return CourseCardStyle.small;
    if (size == 60) return CourseCardStyle.large;
    return CourseCardStyle.normal;
  }

  void _jumpToPage(int page) {
    scheduleStore.jumpToPage(page);
    _pageController.jumpToPage(scheduleStore.currentPage);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformUtils.isDesktop;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          // 顶部工具栏
          _buildTopBar(context, isDesktop, isDark),
          // 课表内容
          Expanded(
            child: Obx(() {
              if (scheduleStore.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  scheduleStore.setCurrentPage(index);
                },
                itemCount: scheduleStore.allCourses.length,
                itemBuilder: (context, index) {
                  return _buildSchedulePage(context, index);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDesktop, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                // 左侧：周次导航
                if (!isDesktop) _buildWeekInfo(context, isDark),
                if (isDesktop) _buildDesktopWeekNav(context),
                const Spacer(),
                // 右侧：操作按钮
                _buildActionButtons(context, isDark),
              ],
            ),
            // 样式选择器
            if (_showStyleSelector) ...[
              const SizedBox(height: 12),
              _buildStyleSelector(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeekInfo(BuildContext context, bool isDark) {
    return Obx(() {
      final weekText = scheduleStore.currentWeek <= 0
          ? '距离开学还有${-scheduleStore.currentWeek + 1}周'
          : '当前为第${scheduleStore.currentWeek}周';

      return InkWell(
        onTap: () => _jumpToPage(scheduleStore.currentWeek),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                scheduleStore.currentPage <= 0
                    ? '全部课表'
                    : '第 ${scheduleStore.currentPage} 周',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                weekText,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDesktopWeekNav(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => _jumpToPage((scheduleStore.currentPage - 1).ceil()),
          tooltip: '上一周',
        ),
        const SizedBox(width: 8),
        Obx(() => Text(
              scheduleStore.currentPage <= 0
                  ? '全部课表'
                  : '第 ${scheduleStore.currentPage} 周'
                      '${scheduleStore.currentPage == scheduleStore.currentWeek ? " (本周)" : ""}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            )),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => _jumpToPage((_pageController.page! + 1).ceil()),
          tooltip: '下一周',
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 样式切换
        IconButton(
          icon: const Icon(Icons.palette_outlined),
          onPressed: () {
            setState(() {
              _showStyleSelector = !_showStyleSelector;
            });
          },
          tooltip: '切换样式',
        ),
        // 刷新
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _handleRefresh,
          tooltip: '刷新课表',
        ),
        // 设置
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => Get.toNamed('/ScheduleSetting'),
          tooltip: '课表设置',
        ),
      ],
    );
  }

  Widget _buildStyleSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: CupertinoSlidingSegmentedControl<CourseCardStyle>(
        groupValue: _cardStyle,
        onValueChanged: (CourseCardStyle? value) async {
          if (value != null) {
            setState(() {
              _cardStyle = value;
            });

            double height = 55;
            if (value == CourseCardStyle.small) {
              height = 50;
            } else if (value == CourseCardStyle.large) {
              height = 60;
            }

            await scheduleStore.setCourseHeight(height);
          }
        },
        children: const {
          CourseCardStyle.small: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('紧凑'),
          ),
          CourseCardStyle.normal: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('标准'),
          ),
          CourseCardStyle.large: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('宽松'),
          ),
        },
      ),
    );
  }

  Widget _buildSchedulePage(BuildContext context, int weekIndex) {
    final courses = scheduleStore.allCourses[weekIndex];
    final now = DateTime.now();
    int weekday = now.weekday;
    if (weekday == 7) weekday = 0;

    final weekStartDate = weekIndex == 0
        ? DateTime(now.year, 1, 1)
        : now.subtract(Duration(
            days: weekday + (scheduleStore.currentWeek - weekIndex) * 7));

    return Column(
      children: [
        // 星期标题栏
        WeekdayHeader(
          weekStartDate: weekStartDate,
          currentWeek: weekIndex == 0 ? null : weekIndex,
          showDate: weekIndex > 0,
          showGrid: settingsStore.showCourseGrid,
        ),
        // 课表网格
        Expanded(
          child: SingleChildScrollView(
            child: SizedBox(
              height: scheduleStore.height * 12,
              child: ScheduleGrid(
                courses: courses,
                cellHeight: scheduleStore.height,
                isYanTa: scheduleStore.isYanTa,
                cardStyle: _cardStyle,
                showGrid: settingsStore.showCourseGrid,
                onCourseTap: (course) => _showCourseDetail(course),
                onCourseLongPress: (course) {
                  if (course.isCustom) {
                    _showCourseActions(course);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleRefresh() async {
    showClubSnackBar(context, const Text('正在更新课表...'));
    await scheduleStore.refreshCourses();
    if (mounted) {
      showClubSnackBar(context, const Text('更新完成'));
    }
  }

  void _showCourseDetail(CourseModel course) {
    CourseDetailSheet.show(
      context,
      course,
      onEdit: course.isCustom ? () => _editCustomCourse(course) : null,
      onDelete: course.isCustom ? () => _deleteCustomCourse(course) : null,
    );
  }

  void _showCourseActions(CourseModel course) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('编辑课程'),
            onTap: () {
              Navigator.pop(context);
              _editCustomCourse(course);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('删除课程', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _deleteCustomCourse(course);
            },
          ),
        ],
      ),
    );
  }

  void _editCustomCourse(CourseModel course) {
    showDialog(
      context: context,
      builder: (context) => AddEditCourseDialog(
        course: course,
        onSave: (updatedCourse) async {
          await _saveUpdatedCustomCourse(updatedCourse);
          if (mounted) {
            showClubSnackBar(context, const Text('课程修改成功'));
          }
        },
      ),
    );
  }

  Future<void> _deleteCustomCourse(CourseModel course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除课程"${course.courseName}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('custom_courses');

      if (jsonString != null) {
        try {
          final jsonList = jsonDecode(jsonString) as List<dynamic>;
          final customCourses = jsonList
              .map((json) => CourseModel.fromJson(json as Map<String, dynamic>))
              .where((c) => c.isCustom && c.lessonId != course.lessonId)
              .toList();

          final updatedJsonString =
              jsonEncode(customCourses.map((c) => c.toJson()).toList());
          await prefs.setString('custom_courses', updatedJsonString);
          await scheduleStore.refreshCourses();

          if (mounted) {
            showClubSnackBar(context, const Text('课程删除成功'));
          }
        } catch (e) {
          if (mounted) {
            showClubSnackBar(context, const Text('删除失败'));
          }
        }
      }
    }
  }

  Future<void> _saveUpdatedCustomCourse(CourseModel updatedCourse) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('custom_courses');

    if (jsonString != null) {
      try {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        final customCourses = jsonList
            .map((json) => CourseModel.fromJson(json as Map<String, dynamic>))
            .where((c) => c.isCustom)
            .toList();

        final index = customCourses
            .indexWhere((c) => c.lessonId == updatedCourse.lessonId);
        if (index != -1) {
          customCourses[index] = updatedCourse;
        }

        final updatedJsonString =
            jsonEncode(customCourses.map((c) => c.toJson()).toList());
        await prefs.setString('custom_courses', updatedJsonString);
        await scheduleStore.refreshCourses();
      } catch (e) {
        // 处理错误
      }
    }
  }
}
