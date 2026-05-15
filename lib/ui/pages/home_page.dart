import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';

import 'package:ios_club_app/ui/pages/homePages/exam_card.dart';
import 'package:ios_club_app/ui/pages/homePages/schedule_widget.dart';
import 'package:ios_club_app/ui/pages/homePages/tiles_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _lastPressedTime;

  Future<bool> _handleWillPop() async {
    // 只在手机版（非平板/桌面）启用双击退出
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isMacOS = PlatformUtils.isMacOS;

    if (isTablet || isMacOS) {
      return false; // 平板和桌面不拦截
    }

    // 实现双击退出
    final now = DateTime.now();
    if (_lastPressedTime == null ||
        now.difference(_lastPressedTime!) > const Duration(seconds: 2)) {
      _lastPressedTime = now;

      // 显示提示
      showClubSnackBar(context, Text(context.l10n.doubleTapExit));
      return false; // 不退出
    }

    return true; // 退出应用
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop) {
          final shouldPop = await _handleWillPop();
          if (shouldPop && context.mounted) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: ListView(
          // 使用 ListView 替代 SingleChildScrollView + Column 以获得更好的滚动性能
          children: const [
            ScheduleWidget(),
            TilesWidget(),
            // 考试列表
            ExamCard(),
            // 待办事项
            // TodoWidget(),
          ],
        ),
      ),
    );
  }
}
