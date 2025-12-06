import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ios_club_app/models/course_model.dart';
import 'package:ios_club_app/pageModels/schedule_item.dart';
import 'package:ios_club_app/services/time_service.dart';
import 'package:ios_club_app/stores/schedule_store.dart';
import 'package:ios_club_app/widgets/empty_widget.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/stores/settings_store.dart';
import 'package:ios_club_app/pageModels/course_color_manager.dart';

import 'package:ios_club_app/system_services/notification_service.dart';
import '../club_card.dart';
import '../club_modal_bottom_sheet.dart';

class ScheduleWidget extends StatefulWidget {
  const ScheduleWidget({super.key});

  @override
  State<StatefulWidget> createState() => _ScheduleWidgetState();
}

class _ScheduleWidgetState extends State<ScheduleWidget> {
  final List<ScheduleItem> scheduleItems = [];
  final List<CourseModel> courses = [];
  late bool isRemind = false;
  late ScheduleStore scheduleStore;

  @override
  void initState() {
    super.initState();
    // 使用 Get.find 获取已经在其他地方初始化的 ScheduleStore 实例
    scheduleStore = Get.find<ScheduleStore>();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      courses.addAll(scheduleStore.getTodayCourses());

      if (!mounted) return;

      setState(() {
        // 使用SettingsStore中的isRemind值
        isRemind = SettingsStore.to.isRemind;
        changeScheduleItems(courses);
      });
    } catch (e) {
      debugPrint('初始化失败: $e');
      // 可添加错误处理逻辑（如显示错误提示）
    }
  }

  void changeScheduleItems(List<CourseModel> a) {
    final weekdayName = ['日', '一', '二', '三', '四', '五', '六', '日'];

    scheduleItems.clear();
    scheduleItems.addAll(a.map((course) {
      final time = TimeService.getStartAndEnd(course);
      return ScheduleItem(
        title: course.courseName,
        time:
            '第${course.startUnit}节 ~ 第${course.endUnit}节 | ${time.start}~${time.end}',
        location: course.room,
        teacher: course.teachers.join(','),
        description:
            '${course.weekIndexes.first}-${course.weekIndexes.last}周 每周${weekdayName[course.weekday]} 第${course.startUnit}节 ~ 第${course.endUnit}节',
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 判断是否为平板布局（宽度大于600）
    final isTablet = screenWidth > 600;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Obx(() => Text(
                  '${scheduleStore.showTomorrow ? '明' : '今'}日课表',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (alertContext) => StatefulBuilder(
                          // 使用 StatefulBuilder 包装 AlertDialog
                          builder: (context, setStateDialog) => AlertDialog(
                              title: const Text('设置'),
                              content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                        title: const Text('显示明天的课表'),
                                        trailing: Obx(() => CupertinoSwitch(
                                            value: scheduleStore.isShowTomorrow,
                                            onChanged: (value) async {
                                              await scheduleStore
                                                  .toggleShowTomorrow();
                                              _initializeData(); // 重新加载数据
                                            }))),
                                    if (!kIsWeb &&
                                        (Platform.isIOS || Platform.isAndroid))
                                      ListTile(
                                        title: const Text('课程通知'),
                                        trailing: Obx(() => CupertinoSwitch(
                                              value: SettingsStore.to.isRemind,
                                              onChanged: (bool value) async {
                                                await SettingsStore.to
                                                    .setIsRemind(value);
                                                if (value && context.mounted) {
                                                  await NotificationService.set(
                                                      context);
                                                }
                                              },
                                            )),
                                      )
                                  ]))));
                })
          ]),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: ClubCard(
            child: Obx(() {
              // 使用 Obx 监听 ScheduleStore 中的变化
              final todayCourses = scheduleStore.getTodayCourses();
              // 创建临时列表而不是直接修改状态
              final tempScheduleItems = _generateScheduleItems(todayCourses);

              return tempScheduleItems.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: EmptyWidget(
                          title:
                              '${scheduleStore.showTomorrow ? '明' : '今'}天没有课了',
                          icon: Icons.school,
                          subtitle: '好好休息会儿吧，学一天累死个人'))
                  : Column(
                      children: tempScheduleItems
                          .map((x) => _buildScheduleItem(x, isTablet))
                          .toList(),
                    );
            }),
          ),
        ),
      ],
    );
  }

  List<ScheduleItem> _generateScheduleItems(List<CourseModel> courses) {
    final weekdayName = ['日', '一', '二', '三', '四', '五', '六', '日'];
    final items = <ScheduleItem>[];

    for (var course in courses) {
      final time = TimeService.getStartAndEnd(course);

      items.add(ScheduleItem(
        title: course.courseName,
        time:
            '第${course.startUnit}-${course.endUnit}节 ${time.start}-${time.end}',
        location: course.room,
        teacher: course.teachers.join(','),
        description:
            '${CourseModel.formatWeekRanges(course.weekIndexes)}周 每周${weekdayName[course.weekday]} 第${course.startUnit}-${course.endUnit}节',
      ));
    }
    return items;
  }

  Widget _buildScheduleItem(ScheduleItem item, bool isTablet) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (isTablet) {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      content: buildCourse(item, isTablet),
                    ));
          } else {
            showClubModalBottomSheet(
              context,
              buildCourse(item, isTablet),
            );
          }
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
                  borderRadius: BorderRadius.circular(3),
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
                        const Icon(
                          Icons.access_time,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.time,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(item.location,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          course.title,
          style: TextStyle(
            fontSize: isTablet ? 24 : 22,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
        SizedBox(height: isTablet ? 16 : 14),
        Row(
          children: [
            Icon(
              CupertinoIcons.placemark_fill,
              color: CupertinoColors.systemBlue,
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
              color: CupertinoColors.systemRed,
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
              color: CupertinoColors.systemGreen,
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
