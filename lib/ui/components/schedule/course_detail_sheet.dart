import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/ui/theme/club_smooth_corners.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

/// 课程详情弹窗组件
///
/// 简约的苹果风格设计，用于展示课程的完整信息
class CourseDetailSheet extends StatelessWidget {
  const CourseDetailSheet({
    super.key,
    required this.course,
    this.onEdit,
    this.onDelete,
  });

  final CourseModel course;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.clubColors;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop =
        isTablet && !PlatformUtils.isAndroid && !PlatformUtils.isIOS;

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: ShapeDecoration(
        color: colors.cardBackground,
        shape: ClubSmoothCorners.shape(
          isDesktop ? ClubRadii.card : ClubRadii.sheetTop,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Row(
            children: [
              Expanded(
                child: Text(
                  course.courseName,
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 22,
                    fontWeight: FontWeight.w700,
                    color: colors.label,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (course.isCustom && (onEdit != null || onDelete != null))
                _buildActionMenu(context),
            ],
          ),
          SizedBox(height: isTablet ? 24 : 20),

          // 课程信息列表
          _buildInfoRow(
            context,
            icon: CupertinoIcons.location_solid,
            label: context.l10n.classroom,
            content: course.room,
            color: colors.primary,
          ),
          SizedBox(height: isTablet ? 16 : 14),

          _buildInfoRow(
            context,
            icon: course.teachers.length > 1
                ? CupertinoIcons.person_2_fill
                : CupertinoIcons.person_fill,
            label: context.l10n.teacherLabel,
            content: course.teachers.join(', '),
            color: colors.danger,
          ),
          SizedBox(height: isTablet ? 16 : 14),

          _buildInfoRow(
            context,
            icon: CupertinoIcons.calendar,
            label: context.l10n.classTime,
            content: _formatScheduleInfo(context),
            color: colors.success,
          ),

          if (course.campus.isNotEmpty) ...[
            SizedBox(height: isTablet ? 16 : 14),
            _buildInfoRow(
              context,
              icon: CupertinoIcons.building_2_fill,
              label: context.l10n.classCampus,
              content: course.campus,
              color: colors.warning,
            ),
          ],

          if (course.credits.isNotEmpty) ...[
            SizedBox(height: isTablet ? 16 : 14),
            _buildInfoRow(
              context,
              icon: CupertinoIcons.star_fill,
              label: context.l10n.courseCredits,
              content: course.credits,
              color: colors.yellow,
            ),
          ],

          SizedBox(height: isTablet ? 24 : 20),
        ],
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context) {
    final colors = context.clubColors;
    return PopupMenuButton(
      icon: Icon(
        Icons.more_horiz,
        color: colors.secondaryLabel,
      ),
      itemBuilder: (context) => [
        if (onEdit != null)
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                const Icon(Icons.edit, size: 20),
                const SizedBox(width: 12),
                Text(context.l10n.editCourse),
              ],
            ),
          ),
        if (onDelete != null)
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 20, color: colors.danger),
                const SizedBox(width: 12),
                Text(context.l10n.deleteCourse,
                    style: TextStyle(color: colors.danger)),
              ],
            ),
          ),
      ],
      onSelected: (value) {
        Navigator.of(context).pop();
        if (value == 'edit' && onEdit != null) {
          onEdit!();
        } else if (value == 'delete' && onDelete != null) {
          onDelete!();
        }
      },
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String content,
    required Color color,
  }) {
    final colors = context.clubColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 图标容器
        Container(
          width: 36,
          height: 36,
          decoration: ShapeDecoration(
            color: color.withValues(alpha: 0.12),
            shape: ClubSmoothCorners.shape(ClubRadii.control),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(width: 14),
        // 文本内容
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.secondaryLabel,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  color: colors.label,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatScheduleInfo(BuildContext context) {
    final weekdayNames = _getWeekdayNames(context);
    return context.l10n.scheduleCourseTime(
      CourseModel.formatWeekRanges(course.weekIndexes),
      weekdayNames[course.weekday],
      course.startUnit,
      course.endUnit,
    );
  }

  List<String> _getWeekdayNames(BuildContext context) {
    final l10n = context.l10n;
    return [
      l10n.sunday,
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
      l10n.saturday,
      l10n.sunday,
    ];
  }

  /// 显示课程详情弹窗
  static Future<void> show(
    BuildContext context,
    CourseModel course, {
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    if (isTablet && !PlatformUtils.isAndroid && !PlatformUtils.isIOS) {
      // 桌面平台使用对话框
      return showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: ClubSmoothCorners.shape(ClubRadii.card),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: CourseDetailSheet(
              course: course,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ),
        ),
      );
    } else {
      // 移动平台使用底部弹窗
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CourseDetailSheet(
          course: course,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      );
    }
  }
}
