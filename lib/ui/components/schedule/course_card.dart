import 'package:flutter/material.dart';
import 'package:ios_club_app/core/models/course_color_manager.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';

/// 课程卡片组件
///
/// 简约的苹果风格设计，用于课表中展示单个课程信息
class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.height,
    this.onTap,
    this.onLongPress,
    this.style = CourseCardStyle.normal,
  });

  final CourseModel course;
  final double height;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final CourseCardStyle style;

  @override
  Widget build(BuildContext context) {
    final courseColor = CourseColorManager.generateSoftColor(course.courseName);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // 根据样式调整字体大小增量
    final double addNum = _getFontSizeAdd();
    final double baseFontSize = isTablet ? 12 : 10;
    final double padding = isTablet ? 8 : 4;

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: courseColor,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 课程名称
                Text(
                  course.courseName,
                  style: TextStyle(
                    fontSize: baseFontSize + addNum,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 3,
                ),
                // 上课地点
                Text(
                  course.room,
                  style: TextStyle(
                    fontSize: (isTablet ? 10 : 9) + addNum,
                    overflow: TextOverflow.ellipsis,
                    color: Colors.white70,
                  ),
                  maxLines: 2,
                ),
                // 教师信息
                Text(
                  course.teachers.join(', '),
                  style: TextStyle(
                    fontSize: (isTablet ? 10 : 8) + addNum,
                    overflow: TextOverflow.ellipsis,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getFontSizeAdd() {
    switch (style) {
      case CourseCardStyle.small:
        return 0.4;
      case CourseCardStyle.large:
        return 1.3;
      case CourseCardStyle.normal:
        return 0.9;
    }
  }
}

/// 课程卡片样式枚举
enum CourseCardStyle {
  small,
  normal,
  large,
}
