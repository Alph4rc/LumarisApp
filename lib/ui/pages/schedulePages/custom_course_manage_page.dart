import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';

import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';

/// 自定义课程管理页面
///
/// 提供自定义课程的增删改查功能
class CustomCourseManagePage extends ConsumerStatefulWidget {
  const CustomCourseManagePage({super.key});

  @override
  ConsumerState<CustomCourseManagePage> createState() =>
      _CustomCourseManagePageState();
}

class _CustomCourseManagePageState
    extends ConsumerState<CustomCourseManagePage> {
  late List<CourseModel> customCourses;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomCourses();
  }

  Future<void> _loadCustomCourses() async {
    setState(() {
      isLoading = true;
    });

    final prefs = PrefsService.instance;
    final String? jsonString = prefs.getString('custom_courses');

    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        customCourses = jsonList
            .map((json) => CourseModel.fromJson(json))
            .where((course) => course.isCustom)
            .toList();
      } catch (e) {
        customCourses = [];
      }
    } else {
      customCourses = [];
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveCustomCourses() async {
    final prefs = PrefsService.instance;
    final jsonString =
        jsonEncode(customCourses.map((course) => course.toJson()).toList());
    await prefs.setString('custom_courses', jsonString);
  }

  void _showAddCourseDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEditCourseDialog(
        onSave: (course) async {
          setState(() {
            customCourses.add(course);
          });
          await _saveCustomCourses();
          await _refreshCourseStore();
          if (mounted) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('课程添加成功'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: ClubRadii.navigation,
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditCourseDialog(CourseModel course) {
    showDialog(
      context: context,
      builder: (context) => AddEditCourseDialog(
        course: course,
        onSave: (updatedCourse) async {
          setState(() {
            final index =
                customCourses.indexWhere((c) => c.lessonId == course.lessonId);
            if (index != -1) {
              customCourses[index] = updatedCourse;
            }
          });
          await _saveCustomCourses();
          await _refreshCourseStore();
          if (mounted) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('课程修改成功'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: ClubRadii.navigation,
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _deleteCourse(CourseModel course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除课程"${course.courseName}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        customCourses.removeWhere((c) => c.lessonId == course.lessonId);
      });
      await _saveCustomCourses();
      await _refreshCourseStore();
      if (mounted) {
        showClubSnackBar(context, const Text('课程删除成功'));
      }
    }
  }

  Future<void> _refreshCourseStore() async {
    // 刷新CourseStore以包含最新的自定义课程
    await ref.read(courseStoreProvider.notifier).loadCourses();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.clubColors;
    final cardColor = colors.cardBackground;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
        appBar: ClubAppBar(
          titleWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '自定义课程',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (customCourses.isNotEmpty)
                Text(
                  '${customCourses.length} 门课程',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.secondaryLabel,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddCourseDialog,
              tooltip: '添加课程',
            ),
          ],
        ),
        body: isLoading
            ? const Center(
                child: LoadingStateView(
                  title: '正在读取自定义课程',
                  subtitle: '正在整理本地保存的课程配置',
                ),
              )
            : customCourses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: ClubRadii.card,
                          ),
                          child: Icon(
                            Icons.event_available,
                            size: 48,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          '暂无自定义课程',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '点击右上角 + 号添加课程',
                          style: TextStyle(
                            fontSize: 15,
                            color: colors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: customCourses.length,
                    itemBuilder: (context, index) {
                      final course = customCourses[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: ClubRadii.navigation,
                          boxShadow: [
                            BoxShadow(
                              color: colors.shadowColor.withValues(alpha: 0.8),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: ClubRadii.navigation,
                            onTap: () => _showEditCourseDialog(course),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          course.courseName,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            _buildInfoChip(
                                              Icons.location_on_outlined,
                                              course.room.isEmpty
                                                  ? '无地点'
                                                  : course.room,
                                              colors.primary,
                                            ),
                                            _buildInfoChip(
                                              Icons.schedule_outlined,
                                              _formatCourseTime(course),
                                              colors.success,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    icon: Icon(
                                      Icons.more_horiz,
                                      color: colors.secondaryLabel,
                                    ),
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        backgroundColor: cardColor,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: ClubRadii.sheetTop,
                                        ),
                                        builder: (context) => SafeArea(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ClubListTile(
                                                leading: Icon(
                                                  Icons.edit_outlined,
                                                  color: colors.primary,
                                                ),
                                                title: const Text('编辑课程'),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  _showEditCourseDialog(course);
                                                },
                                              ),
                                              ClubListTile(
                                                leading: Icon(
                                                  Icons.delete_outline,
                                                  color: colors.danger,
                                                ),
                                                title: const Text('删除课程'),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  _deleteCourse(course);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ));
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: ClubRadii.control,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCourseTime(CourseModel course) {
    final weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return '${weekdays[course.weekday]} 第${course.startUnit}-${course.endUnit}节';
  }
}

/// 添加/编辑课程对话框
class AddEditCourseDialog extends StatefulWidget {
  final CourseModel? course;
  final Function(CourseModel) onSave;

  const AddEditCourseDialog({
    super.key,
    this.course,
    required this.onSave,
  });

  @override
  State<AddEditCourseDialog> createState() => _AddEditCourseDialogState();
}

class _AddEditCourseDialogState extends State<AddEditCourseDialog> {
  late TextEditingController _courseNameController;
  late TextEditingController _roomController;
  late TextEditingController _teacherController;
  late TextEditingController _creditsController;
  late int _selectedWeekday;
  late int _startUnit;
  late int _endUnit;
  late List<int> _selectedWeeks;

  final List<String> _weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
  final List<int> _availableWeeks = List.generate(20, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    _courseNameController =
        TextEditingController(text: widget.course?.courseName ?? '');
    _roomController = TextEditingController(text: widget.course?.room ?? '');
    _teacherController =
        TextEditingController(text: widget.course?.teachers.join(', ') ?? '');
    _creditsController =
        TextEditingController(text: widget.course?.credits ?? '');
    _selectedWeekday = widget.course?.weekday ?? 1;
    _startUnit = widget.course?.startUnit ?? 1;
    _endUnit = widget.course?.endUnit ?? 2;
    _selectedWeeks =
        widget.course != null && widget.course!.weekIndexes.isNotEmpty
            ? List.from(widget.course!.weekIndexes)
            : [
                1,
                2,
                3,
                4,
                5,
                6,
                7,
                8,
                9,
                10,
                11,
                12,
                13,
                14,
                15,
                16,
                17,
                18,
                19,
                20
              ];
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _roomController.dispose();
    _teacherController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  void _save() {
    if (_courseNameController.text.trim().isEmpty) {
      showClubSnackBar(context, const Text('请输入课程名称'));
      return;
    }

    final course = CourseModel(
      weekIndexes: _selectedWeeks,
      teachers: _teacherController.text
          .trim()
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      room: _roomController.text.trim(),
      courseName: _courseNameController.text.trim(),
      courseCode: 'CUSTOM_${DateTime.now().millisecondsSinceEpoch}',
      weekday: _selectedWeekday,
      startUnit: _startUnit,
      endUnit: _endUnit,
      credits: _creditsController.text.trim(),
      lessonId: widget.course?.lessonId ??
          'CUSTOM_${DateTime.now().millisecondsSinceEpoch}',
      campus: '',
      isCustom: true,
    );

    widget.onSave(course);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.clubColors;
    final cardColor = colors.cardBackground;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: ClubRadii.panel,
          boxShadow: [
            BoxShadow(
              color: colors.shadowColor.withValues(alpha: 0.9),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                border: Border(
                  bottom: BorderSide(
                    color: colors.separator,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.course == null ? '添加课程' : '编辑课程',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    iconSize: 20,
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      '课程名称',
                      _courseNameController,
                      '请输入课程名称',
                      Icons.book_outlined,
                      required: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      '上课地点',
                      _roomController,
                      '请输入上课地点',
                      Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      '授课教师',
                      _teacherController,
                      '多个教师用逗号分隔',
                      Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      '学分',
                      _creditsController,
                      '请输入学分',
                      Icons.school_outlined,
                    ),
                    const SizedBox(height: 20),

                    // Weekday selector
                    Text(
                      '星期几',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: colors.surfaceRaised,
                        borderRadius: ClubRadii.navigation,
                        border: Border.all(
                          color: colors.borderStrong,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedWeekday,
                          isExpanded: true,
                          items: List.generate(7, (index) {
                            return DropdownMenuItem(
                              value: index,
                              child: Text(_weekdays[index]),
                            );
                          }),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedWeekday = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Time selector
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '开始节次',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: colors.surfaceRaised,
                                  borderRadius: ClubRadii.navigation,
                                  border: Border.all(
                                    color: colors.borderStrong,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _startUnit,
                                    isExpanded: true,
                                    items: List.generate(12, (index) {
                                      return DropdownMenuItem(
                                        value: index + 1,
                                        child: Text('第${index + 1}节'),
                                      );
                                    }),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _startUnit = value;
                                          if (_startUnit > _endUnit) {
                                            _endUnit = _startUnit;
                                          }
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '结束节次',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: colors.surfaceRaised,
                                  borderRadius: ClubRadii.navigation,
                                  border: Border.all(
                                    color: colors.borderStrong,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _endUnit,
                                    isExpanded: true,
                                    items: List.generate(12, (index) {
                                      return DropdownMenuItem(
                                        value: index + 1,
                                        child: Text('第${index + 1}节'),
                                      );
                                    }),
                                    onChanged: (value) {
                                      if (value != null &&
                                          value >= _startUnit) {
                                        setState(() {
                                          _endUnit = value;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Week selector
                    Text(
                      '上课周次',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableWeeks.map((week) {
                        final isSelected = _selectedWeeks.contains(week);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedWeeks.remove(week);
                              } else {
                                _selectedWeeks.add(week);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor
                                  : colors.surfaceMuted,
                              borderRadius: ClubRadii.card,
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : colors.borderStrong,
                              ),
                            ),
                            child: Text(
                              '$week周',
                              style: TextStyle(
                                color: isSelected
                                    ? colors.onAccent
                                    : colors.secondaryLabel,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                border: Border(
                  top: BorderSide(
                    color: colors.separator,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      '取消',
                      style: TextStyle(
                        color: colors.secondaryLabel,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: colors.onAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: ClubRadii.control,
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '保存',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool required = false,
  }) {
    final colors = context.clubColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: colors.danger,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: colors.tertiaryLabel,
            ),
            prefixIcon: Icon(
              icon,
              size: 20,
              color: colors.tertiaryLabel,
            ),
            filled: true,
            fillColor: colors.surfaceRaised,
            border: OutlineInputBorder(
              borderRadius: ClubRadii.control,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: ClubRadii.control,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: ClubRadii.control,
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
