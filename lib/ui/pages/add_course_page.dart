import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/core/models/course_model.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final CourseStore _courseStore = CourseStore.to;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // 表单字段
  String _courseName = '';
  String _teacher = '';
  String _room = '';
  int _weekday = 0; // 0=周一, 1=周二, ..., 6=周日
  int _startUnit = 1;
  int _endUnit = 2;
  String _weekRange = '';

  // 星期几选项
  final List<String> _weekdayOptions = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  // 节次选项
  final List<int> _unitOptions = List.generate(12, (index) => index + 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: ClubAppBar(
        title: '添加课程',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 课程名称
              TextFormField(
                decoration: InputDecoration(
                  labelText: '课程名称',
                  hintText: '请输入课程名称',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入课程名称';
                  }
                  return null;
                },
                onSaved: (value) {
                  _courseName = value!;
                },
              ),
              SizedBox(height: 16),

              // 教师
              TextFormField(
                decoration: InputDecoration(
                  labelText: '教师',
                  hintText: '请输入教师姓名',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) {
                  _teacher = value ?? '';
                },
              ),
              SizedBox(height: 16),

              // 地点
              TextFormField(
                decoration: InputDecoration(
                  labelText: '地点',
                  hintText: '请输入上课地点',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) {
                  _room = value ?? '';
                },
              ),
              SizedBox(height: 16),

              // 星期几
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: '星期几',
                  border: OutlineInputBorder(),
                ),
                value: _weekday,
                items: _weekdayOptions.asMap().entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return '请选择星期几';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _weekday = value!;
                  });
                },
              ),
              SizedBox(height: 16),

              // 开始节次
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: '开始节次',
                  border: OutlineInputBorder(),
                ),
                value: _startUnit,
                items: _unitOptions.map((unit) {
                  return DropdownMenuItem<int>(
                    value: unit,
                    child: Text('第 $unit 节'),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return '请选择开始节次';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _startUnit = value!;
                    if (_endUnit < _startUnit) {
                      _endUnit = _startUnit;
                    }
                  });
                },
              ),
              SizedBox(height: 16),

              // 结束节次
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: '结束节次',
                  border: OutlineInputBorder(),
                ),
                value: _endUnit,
                items: _unitOptions.where((unit) => unit >= _startUnit).map((unit) {
                  return DropdownMenuItem<int>(
                    value: unit,
                    child: Text('第 $unit 节'),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return '请选择结束节次';
                  }
                  if (value < _startUnit) {
                    return '结束节次不能小于开始节次';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _endUnit = value!;
                  });
                },
              ),
              SizedBox(height: 16),

              // 周次范围
              TextFormField(
                decoration: InputDecoration(
                  labelText: '周次范围',
                  hintText: '例如：1-16, 1,3,5-7',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入周次范围';
                  }
                  // 简单的周次格式验证
                  if (!RegExp(r'^\d+(?:-\d+)?(?:,\s*\d+(?:-\d+)?)*$').hasMatch(value)) {
                    return '周次格式不正确，例如：1-16 或 1,3,5-7';
                  }
                  return null;
                },
                onSaved: (value) {
                  _weekRange = value!;
                },
              ),
              SizedBox(height: 32),

              // 提交按钮
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: _submitForm,
                  child: Text('添加课程'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 解析周次范围字符串为周次索引列表
  List<int> _parseWeekRange(String weekRange) {
    final List<int> weekIndexes = [];
    final parts = weekRange.split(',');
    
    for (var part in parts) {
      part = part.trim();
      if (part.contains('-')) {
        // 处理范围，如1-16
        final rangeParts = part.split('-');
        if (rangeParts.length == 2) {
          final start = int.tryParse(rangeParts[0].trim());
          final end = int.tryParse(rangeParts[1].trim());
          if (start != null && end != null && start <= end) {
            for (int i = start; i <= end; i++) {
              weekIndexes.add(i);
            }
          }
        }
      } else {
        // 处理单个周次，如1,3,5
        final week = int.tryParse(part);
        if (week != null) {
          weekIndexes.add(week);
        }
      }
    }
    
    // 去重并排序
    final Set<int> uniqueWeeks = Set.from(weekIndexes);
    final sortedWeeks = uniqueWeeks.toList()..sort();
    
    return sortedWeeks;
  }

  // 提交表单
  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      
      // 解析周次范围
      final weekIndexes = _parseWeekRange(_weekRange);
      
      // 创建课程模型
      final course = CourseModel(
        courseName: _courseName,
        teachers: _teacher.isNotEmpty ? [_teacher] : [],
        room: _room,
        weekday: _weekday,
        startUnit: _startUnit,
        endUnit: _endUnit,
        weekIndexes: weekIndexes,
        // 自定义课程可以使用随机生成的lessonId
        lessonId: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      );
      
      try {
        // 添加课程到本地存储
        await _courseStore.addCustomCourse(course);
        
        // 显示成功提示
        if (mounted) {
          showClubSnackBar(
            context,
            const Text('课程添加成功！'),
          );
        }
        
        // 返回上一页
        Get.back();
      } catch (e) {
        // 显示错误提示
        if (mounted) {
          showClubSnackBar(
            context,
            Text('课程添加失败：$e'),
          );
        }
      }
    }
  }
}