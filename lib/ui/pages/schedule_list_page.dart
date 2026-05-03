import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/models/course_color_manager.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/core/utils/image_helper.dart';

import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/schedule_store.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/components/club_modal_bottom_sheet.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/ui/components/schedule/course_card.dart';
import 'package:ios_club_app/ui/components/schedule/course_detail_sheet.dart';
import 'package:ios_club_app/ui/components/schedule/schedule_grid.dart';
import 'package:ios_club_app/ui/components/schedule/weekday_header.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';
import 'package:ios_club_app/ui/pages/schedulePages/custom_course_manage_page.dart';

// 条件导入 dart:io，仅在非 Web 环境中使用
// import 'dart:io' if (dart.library.html) 'dart:html' as io;

/// 课表列表页面
///
/// 简约的苹果风格设计，展示完整的课程表
class ScheduleListPage extends ConsumerStatefulWidget {
  const ScheduleListPage({super.key});

  @override
  ConsumerState<ScheduleListPage> createState() => _ScheduleListPageState();
}

class _ScheduleListPageState extends ConsumerState<ScheduleListPage> {
  late PageController _pageController;

  CourseCardStyle _cardStyle = CourseCardStyle.normal;
  bool _showStyleSelector = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: ref.read(scheduleStoreProvider).currentPage,
    );
    _loadPreferences();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = PrefsService.instance;
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
    final scheduleStore = ref.read(scheduleStoreProvider.notifier);
    scheduleStore.jumpToPage(page);
    _pageController.jumpToPage(ref.read(scheduleStoreProvider).currentPage);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformUtils.isDesktop;
    final systemIsDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsStoreProvider);
    final scheduleState = ref.watch(scheduleStoreProvider);

    return Scaffold(
      body: Builder(builder: (context) {
        final hasCustomBackground = settings.scheduleBackground == 'custom' &&
            settings.customBackgroundImage.isNotEmpty;

        // 有自定义背景时，根据背景亮暗决定字体颜色（异步计算后自动更新）
        // 未计算完成前回退到系统主题
        final isDark = hasCustomBackground
            ? (settings.customBackgroundIsDark ?? systemIsDark)
            : systemIsDark;

        final content = Column(
          children: [
            // 顶部工具栏
            _buildTopBar(context, isDesktop, isDark),
            // 课表内容
            Expanded(
              child: Builder(builder: (context) {
                if (scheduleState.isLoading) {
                  return const Center(
                    child: LoadingStateView(
                      title: '正在加载课表',
                      subtitle: '正在读取课程、偏好设置和背景配置',
                    ),
                  );
                }

                return PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    ref
                        .read(scheduleStoreProvider.notifier)
                        .setCurrentPage(index);
                  },
                  itemCount: scheduleState.allCourses.length,
                  itemBuilder: (context, index) {
                    return _buildSchedulePage(context, index);
                  },
                );
              }),
            ),
          ],
        );

        return hasCustomBackground
            ? Stack(
                fit: StackFit.expand,
                children: [
                  _buildBackgroundImage(settings.customBackgroundImage),
                  content,
                ],
              )
            : content;
      }),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDesktop, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    );
  }

  Widget _buildWeekInfo(BuildContext context, bool isDark) {
    final scheduleState = ref.watch(scheduleStoreProvider);
    final colors = context.clubColors;
    return Builder(builder: (context) {
      final weekText = scheduleState.currentWeek <= 0
          ? '距离开学还有${-scheduleState.currentWeek + 1}周'
          : '当前为第${scheduleState.currentWeek}周';

      return InkWell(
        onTap: () => _jumpToPage(scheduleState.currentWeek),
        borderRadius: ClubRadii.control,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                scheduleState.currentPage <= 0
                    ? '全部课表'
                    : '第 ${scheduleState.currentPage} 周',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: colors.label,
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
    final scheduleState = ref.watch(scheduleStoreProvider);
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => _jumpToPage((scheduleState.currentPage - 1).ceil()),
          tooltip: '上一周',
        ),
        const SizedBox(width: 8),
        Text(
          scheduleState.currentPage <= 0
              ? '全部课表'
              : '第 ${scheduleState.currentPage} 周'
                  '${scheduleState.currentPage == scheduleState.currentWeek ? " (本周)" : ""}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
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
          onPressed: () => AppRouter.push(AppRoutes.scheduleSetting),
          tooltip: '课表设置',
        ),
      ],
    );
  }

  Widget _buildStyleSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: ClubRadii.navigation,
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

            await ref
                .read(scheduleStoreProvider.notifier)
                .setCourseHeight(height);
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
    final scheduleState = ref.watch(scheduleStoreProvider);
    final settings = ref.watch(settingsStoreProvider);
    final courses = scheduleState.allCourses[weekIndex];
    final now = DateTime.now();
    int weekday = now.weekday;
    if (weekday == 7) weekday = 0;

    final weekStartDate = weekIndex == 0
        ? DateTime(now.year, 1, 1)
        : now.subtract(Duration(
            days: weekday + (scheduleState.currentWeek - weekIndex) * 7));

    return Builder(builder: (context) {
      final scheduleContent = Column(
        children: [
          // 星期标题栏
          WeekdayHeader(
            weekStartDate: weekStartDate,
            currentWeek: weekIndex == 0 ? null : weekIndex,
            showDate: weekIndex > 0,
            showGrid: settings.showCourseGrid,
          ),
          // 课表网格
          Expanded(
            child: SingleChildScrollView(
              child: SizedBox(
                height: scheduleState.height * 12,
                child: ScheduleGrid(
                  courses: courses,
                  cellHeight: scheduleState.height,
                  isYanTa: scheduleState.isYanTa,
                  cardStyle: _cardStyle,
                  showGrid: settings.showCourseGrid,
                  onCourseTap: (course) => _showCourseDetail(course),
                  onCourseLongPress: (course) {
                    if (course.isCustom) {
                      _showCourseActions(course);
                    }
                  },
                  onConflictCourseTap: (courses) =>
                      _showConflictCourseSelector(courses),
                ),
              ),
            ),
          ),
        ],
      );

      return scheduleContent;
    });
  }

  /// 构建背景图片
  Widget _buildBackgroundImage(String imagePath) {
    // 检查是否为网络图片
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Theme.of(context).scaffoldBackgroundColor,
          );
        },
      );
    }

    // 本地文件图片（使用 image_helper 处理平台差异）
    return getLocalImage(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
        );
      },
    );
  }

  Future<void> _handleRefresh() async {
    showClubSnackBar(context, const Text('正在更新课表...'));
    try {
      await ref.read(scheduleStoreProvider.notifier).refreshCourses();
      if (mounted) {
        showClubSnackBar(context, const Text('更新完成'));
      }
    } on TimeoutException {
      if (mounted) {
        showClubSnackBar(
          context,
          const Text('更新超时，请检查网络连接后重试'),
        );
      }
    } catch (e) {
      if (mounted) {
        showClubSnackBar(
          context,
          Text('更新失败: ${e.toString()}'),
        );
      }
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

  /// 显示冲突课程选择列表
  void _showConflictCourseSelector(List<CourseModel> courses) {
    showClubModalBottomSheet(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '选择要查看的课程',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...courses.map((course) => ClubListTile(
                leading: Container(
                  width: 8,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        CourseColorManager.generateSoftColor(course.courseName),
                    borderRadius: ClubRadii.xsBorder,
                  ),
                ),
                title: Text(
                  course.courseName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '${course.room} · 第${course.startUnit}-${course.endUnit}节',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showCourseDetail(course);
                },
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showCourseActions(CourseModel course) {
    final colors = context.clubColors;

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClubListTile(
            leading: const Icon(Icons.edit),
            title: const Text('编辑课程'),
            onTap: () {
              Navigator.pop(context);
              _editCustomCourse(course);
            },
          ),
          ClubListTile(
            leading: Icon(Icons.delete, color: colors.danger),
            title: Text('删除课程', style: TextStyle(color: colors.danger)),
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
          if (mounted && context.mounted) {
            showClubSnackBar(context, const Text('课程修改成功'));
          }
        },
      ),
    );
  }

  Future<void> _deleteCustomCourse(CourseModel course) async {
    final colors = context.clubColors;

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
            style: TextButton.styleFrom(foregroundColor: colors.danger),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = PrefsService.instance;
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
          await ref.read(scheduleStoreProvider.notifier).refreshCourses();

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
    final prefs = PrefsService.instance;
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
        await ref.read(scheduleStoreProvider.notifier).refreshCourses();
      } catch (e) {
        // 处理错误
      }
    }
  }
}
