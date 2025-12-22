import 'package:flutter/material.dart';
import 'package:ios_club_app/core/services/time_service.dart';

/// 时间轴列组件
///
/// 简约的苹果风格设计，展示课程节次和对应的时间
class TimelineColumn extends StatelessWidget {
  const TimelineColumn({
    super.key,
    required this.periodCount,
    required this.cellHeight,
    this.isYanTa = false,
    this.showGrid = true,
  });

  final int periodCount;
  final double cellHeight;
  final bool isYanTa;
  final bool showGrid;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 56,
      child: Column(
        children: List.generate(periodCount, (index) {
          final period = index + 1;
          final timeInfo = _getTimeInfo(period);

          return Container(
            height: cellHeight,
            decoration: showGrid
                ? BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                        width: 0.5,
                      ),
                    ),
                  )
                : null,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 节次
                  Text(
                    '$period',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[300] : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 2),
                  // 开始时间
                  Text(
                    timeInfo.start,
                    style: TextStyle(
                      fontSize: 9,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                  // 结束时间
                  Text(
                    timeInfo.end,
                    style: TextStyle(
                      fontSize: 9,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  ({String start, String end}) _getTimeInfo(int period) {
    final now = DateTime.now();
    final isSummer = now.month >= 5 && now.month < 10;

    String startTime = '';
    String endTime = '';

    // 确保索引在有效范围内
    if (period < TimeService.CanTangTimeStart.length) {
      // 默认使用草堂时间
      startTime = TimeService.CanTangTimeStart[period];
      endTime = TimeService.CanTangTimeEnd[period];

      // 根据季节选择雁塔时间
      if (isYanTa) {
        if (isSummer) {
          if (period < TimeService.YanTaXiaStart.length) {
            startTime = TimeService.YanTaXiaStart[period];
            endTime = TimeService.YanTaXiaEnd[period];
          }
        } else {
          if (period < TimeService.YanTaDongStart.length) {
            startTime = TimeService.YanTaDongStart[period];
            endTime = TimeService.YanTaDongEnd[period];
          }
        }
      }
    }

    return (start: startTime, end: endTime);
  }
}
