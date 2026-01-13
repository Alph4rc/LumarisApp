import 'dart:convert';
import 'package:home_widget/home_widget.dart';

import 'package:ios_club_app/core/models/schedule_item.dart';
import 'package:ios_club_app/core/services/data_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

class WidgetService {
  // 更新小组件数据
  @pragma('vm:entry-point')
  static Future<void> updateTodayCourses(
      List<ScheduleItem> todayCourses) async {
    final now = DateTime.now();

    final week = await DataService.getWeek();
    const a = ['日', '一', '二', '三', '四', '五', '六', '日'];
    final weekNow = week['week']!;

    // 更新小组件
    await HomeWidget.saveWidgetData<String>(
        'flutter.date', '第$weekNow周 周${a[now.weekday]}');
    await HomeWidget.saveWidgetData<String>(
        'flutter.courses', jsonEncode(todayCourses));

    AppLogger.debug('小组件数据更新完成');

    // 刷新小组件
    await HomeWidget.updateWidget(
      name: 'TodayCoursesWidgetProvider',
      androidName: 'TodayCoursesWidgetProvider',
      iOSName: 'TodayCoursesWidget',
      qualifiedAndroidName:
          'com.example.ios_club_app.TodayCoursesWidgetProvider',
    );
  }

  @pragma('vm:entry-point')
  static Future<void> updateTodayAndTomorrowCourses(
      Map<String, List<ScheduleItem>> courses) async {
    await HomeWidget.saveWidgetData<String>(
        'flutter.tomorrow.courses', jsonEncode(courses['today']));
    await HomeWidget.saveWidgetData<String>(
        'flutter.tomorrow.tomorrowCourses', jsonEncode(courses['tomorrow']));

    AppLogger.debug('小组件数据更新完成');

    // 刷新小组件
    await HomeWidget.updateWidget(
      name: 'TomorrowCoursesWidgetProvider',
      androidName: 'TomorrowCoursesWidgetProvider',
      iOSName: 'TomorrowCoursesWidget',
      qualifiedAndroidName:
          'com.example.ios_club_app.TomorrowCoursesWidgetProvider',
    );
  }
}
