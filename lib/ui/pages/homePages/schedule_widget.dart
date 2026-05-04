import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/core/models/schedule_item.dart';
import 'package:ios_club_app/core/services/time_service.dart';
import 'package:ios_club_app/core/utils/animations/animations.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/state/schedule_store.dart';
import 'package:ios_club_app/ui/components/empty_widget.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/core/services/course_color_manager.dart';

import 'package:ios_club_app/features/system/notifications/notification_service.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/components/platform_dialog.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/components/schedule/course_detail_sheet.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

class ScheduleWidget extends ConsumerStatefulWidget {
  const ScheduleWidget({super.key});

  @override
  ConsumerState<ScheduleWidget> createState() => _ScheduleWidgetState();
}

class _ScheduleWidgetState extends ConsumerState<ScheduleWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scheduleState = ref.watch(scheduleStoreProvider);
    final scheduleStore = ref.read(scheduleStoreProvider.notifier);
    // 判断是否为平板布局（宽度大于600）
    final isTablet = screenWidth > 600;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              '${scheduleState.showTomorrow ? '明' : '今'}日课表',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  PlatformDialog.showCustomDialog<void>(
                    context,
                    title: '设置',
                    content: Consumer(builder: (context, ref, child) {
                      final settings = ref.watch(settingsStoreProvider);
                      final scheduleStore =
                          ref.read(scheduleStoreProvider.notifier);
                      final settingsStore =
                          ref.read(settingsStoreProvider.notifier);

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClubListTile(
                            title: const Text('显示明天的课表'),
                            trailing: CupertinoSwitch(
                              value: settings.isShowTomorrow,
                              onChanged: (value) async {
                                await scheduleStore.toggleShowTomorrow();
                              },
                            ),
                          ),
                          if (PlatformUtils.isIOS || PlatformUtils.isAndroid)
                            ClubListTile(
                              title: const Text('课程通知'),
                              trailing: CupertinoSwitch(
                                value: settings.isRemind,
                                onChanged: (bool value) async {
                                  await settingsStore.setIsRemind(value);
                                  if (value && context.mounted) {
                                    await NotificationService.set(context);
                                  }
                                },
                              ),
                            ),
                        ],
                      );
                    }),
                  );
                })
          ]),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: AnimatedCard(
            child: ClubCard(
              child: Builder(builder: (context) {
                final todayCourses = scheduleStore.getTodayCourses();

                return todayCourses.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: EmptyWidget(
                            title: '今天没有课了',
                            icon: Icons.school,
                            subtitle: '好好休息会儿吧，学一天累死个人'))
                    : Column(
                        children: todayCourses.asMap().entries.map((entry) {
                          final index = entry.key;
                          final course = entry.value;
                          final weekdayName = [
                            '日',
                            '一',
                            '二',
                            '三',
                            '四',
                            '五',
                            '六',
                            '日'
                          ];
                          final time = TimeService.getStartAndEnd(course);
                          final item = ScheduleItem(
                            title: course.courseName,
                            time:
                                '第${course.startUnit}-${course.endUnit}节 ${time.start}-${time.end}',
                            location: course.room,
                            teacher: course.teachers.join(','),
                            description:
                                '${CourseModel.formatWeekRanges(course.weekIndexes)}周 每周${weekdayName[course.weekday]} 第${course.startUnit}-${course.endUnit}节',
                          );
                          return AnimatedListItem(
                            index: index,
                            child: _buildScheduleItem(course, item, isTablet),
                          );
                        }).toList(),
                      );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleItem(
      CourseModel course, ScheduleItem item, bool isTablet) {
    final colors = context.clubColors;
    return Material(
      borderRadius: ClubRadii.card,
      color: Colors.transparent,
      child: InkWell(
        borderRadius: ClubRadii.card,
        onTap: () {
          CourseDetailSheet.show(context, course);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              const SizedBox(width: 20),
              Container(
                width: 5,
                height: 52,
                decoration: BoxDecoration(
                  color: CourseColorManager.generateSoftColor(item.title),
                  borderRadius: ClubRadii.xsBorder,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 18,
                          color: colors.secondaryLabel,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.time,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: colors.secondaryLabel,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 18,
                          color: colors.secondaryLabel,
                        ),
                        const SizedBox(width: 6),
                        Text(item.location,
                            style: TextStyle(
                              fontSize: 15,
                              color: colors.secondaryLabel,
                              fontWeight: FontWeight.w400,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCourse(ScheduleItem course, bool isTablet) {
    final colors = context.clubColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          course.title,
          style: TextStyle(
            fontSize: isTablet ? 24 : 22,
            fontWeight: FontWeight.w600,
            color: colors.label,
          ),
        ),
        SizedBox(height: isTablet ? 16 : 14),
        Row(
          children: [
            Icon(
              CupertinoIcons.placemark_fill,
              color: colors.primary,
              size: isTablet ? 22 : 20,
            ),
            SizedBox(width: isTablet ? 12 : 10),
            Expanded(
              child: Text(
                course.location,
                style: TextStyle(
                  fontSize: isTablet ? 19 : 17,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 2,
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 16 : 14),
        Row(
          children: [
            Icon(
              CupertinoIcons.person_2_fill,
              color: colors.danger,
              size: isTablet ? 22 : 20,
            ),
            SizedBox(width: isTablet ? 12 : 10),
            Expanded(
              child: Text(
                course.teacher,
                style: TextStyle(
                  fontSize: isTablet ? 19 : 17,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 2,
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 16 : 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              CupertinoIcons.calendar,
              color: colors.success,
              size: isTablet ? 22 : 20,
            ),
            SizedBox(width: isTablet ? 12 : 10),
            Expanded(
              child: Text(
                course.description,
                style: TextStyle(
                  fontSize: isTablet ? 19 : 17,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
