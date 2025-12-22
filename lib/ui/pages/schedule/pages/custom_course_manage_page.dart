import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ios_club_app/core/models/course_model.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';

/// 自定义课程管理页面
///
/// 提供自定义课程的增删改查功能
class CustomCourseManagePage extends StatefulWidget {
  const CustomCourseManagePage({super.key});

  @override
  State<CustomCourseManagePage> createState() => _CustomCourseManagePageState();
}

class _CustomCourseManagePageState extends State<CustomCourseManagePage> {
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

    final prefs = await SharedPreferences.getInstance();
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
    final prefs = await SharedPreferences.getInstance();
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
                    borderRadius: BorderRadius.circular(12),
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
                    borderRadius: BorderRadius.circular(12),
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
    await CourseStore.to.loadCourses();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDarkMode ? Colors.grey[900] : Colors.grey[50];
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: const Text(
          '自定义课程管理',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        backgroundColor: surfaceColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleSpacing: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ],
                ),
              )
            : customCourses.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
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
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '点击右下角按钮添加新课程',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          '${customCourses.length} 门课程',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: customCourses.length,
                            itemBuilder: (context, index) {
                              final course = customCourses[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 15,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => _showEditCourseDialog(course),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
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
                                                  letterSpacing: -0.3,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue
                                                          .withValues(
                                                              alpha: 0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.location_on,
                                                          size: 14,
                                                          color:
                                                              Colors.blue[700],
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          course.room.isEmpty
                                                              ? '无地点'
                                                              : course.room,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .blue[700],
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green
                                                          .withValues(
                                                              alpha: 0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.schedule,
                                                          size: 14,
                                                          color:
                                                              Colors.green[700],
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          _formatCourseTime(
                                                              course),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .green[700],
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        PopupMenuButton<String>(
                                          icon: Icon(
                                            Icons.more_horiz,
                                            color: isDarkMode
                                                ? Colors.grey[400]
                                                : Colors.grey[600],
                                          ),
                                          color: cardColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              _showEditCourseDialog(course);
                                            } else if (value == 'delete') {
                                              _deleteCourse(course);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.edit,
                                                    size: 18,
                                                    color: isDarkMode
                                                        ? Colors.blue[300]
                                                        : Colors.blue[600],
                                                  ),
                                                  const SizedBox(width: 12),
                                                  const Text('编辑'),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.delete,
                                                    size: 18,
                                                    color: Colors.red[600],
                                                  ),
                                                  const SizedBox(width: 12),
                                                  const Text('删除'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showAddCourseDialog,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.add, size: 20),
          label: const Text(
            '添加课程',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;
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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.course == null ? '添加自定义课程' : '编辑自定义课程',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.grey[700]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: isDarkMode
                                ? Colors.grey[300]
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.course == null ? '填写课程信息以添加新的自定义课程' : '修改课程信息',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildModernTextField(
                      '课程名称 *',
                      _courseNameController,
                      '请输入课程名称',
                      Icons.book,
                    ),
                    const SizedBox(height: 20),

                    _buildModernTextField(
                      '上课地点',
                      _roomController,
                      '请输入上课地点',
                      Icons.location_on,
                    ),
                    const SizedBox(height: 20),

                    _buildModernTextField(
                      '授课教师',
                      _teacherController,
                      '多个教师用逗号分隔',
                      Icons.person,
                    ),
                    const SizedBox(height: 20),

                    _buildModernTextField(
                      '学分',
                      _creditsController,
                      '请输入学分',
                      Icons.school,
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
                        color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.grey[600]!
                              : Colors.grey[300]!,
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
                                  color: isDarkMode
                                      ? Colors.grey[700]!
                                      : Colors.grey[100]!,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDarkMode
                                        ? Colors.grey[600]!
                                        : Colors.grey[300]!,
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
                                  color: isDarkMode
                                      ? Colors.grey[700]!
                                      : Colors.grey[100]!,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDarkMode
                                        ? Colors.grey[600]!
                                        : Colors.grey[300]!,
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
                                  : isDarkMode
                                      ? Colors.grey[700]
                                      : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : isDarkMode
                                        ? Colors.grey[600]!
                                        : Colors.grey[300]!,
                              ),
                            ),
                            child: Text(
                              '$week周',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : isDarkMode
                                        ? Colors.grey[300]
                                        : Colors.grey[700],
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '取消',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '保存',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildModernTextField(
    String label,
    TextEditingController controller,
    String hint,
    IconData icon,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
            ),
            prefixIcon: Icon(
              icon,
              size: 20,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
            ),
            filled: true,
            fillColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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
