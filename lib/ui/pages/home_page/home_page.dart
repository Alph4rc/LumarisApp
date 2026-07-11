import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/features/basic/models/school.dart';
import 'package:ios_club_app/state/school_store.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';
import 'package:ios_club_app/state/user_store.dart';

import 'package:ios_club_app/ui/pages/home_page/exam_card.dart';
import 'package:ios_club_app/ui/pages/home_page/schedule_widget.dart';
import 'package:ios_club_app/ui/pages/home_page/tiles_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
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
    final userState = ref.watch(userStoreProvider);
    final isLogin = userState.isLogin;
    final school = ref.watch(schoolStoreProvider).school;
    final canExamSchedule = school?.supports(Feature.examSchedule) ?? true;

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
          children: [
            const ScheduleWidget(),
            if (isLogin) const TilesWidget(),
            if (isLogin && canExamSchedule) const ExamCard(),
          ],
        ),
      ),
    );
  }
}
