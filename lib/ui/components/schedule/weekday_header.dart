import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 星期标题栏组件
///
/// 简约的苹果风格设计，展示星期几和日期
class WeekdayHeader extends StatelessWidget {
  const WeekdayHeader({
    super.key,
    required this.weekStartDate,
    this.currentWeek,
    this.showDate = true,
    this.highlightToday = true,
    this.showGrid = true,
  });

  final DateTime weekStartDate;
  final int? currentWeek;
  final bool showDate;
  final bool highlightToday;
  final bool showGrid;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    int todayWeekday = now.weekday;
    if (todayWeekday == 7) todayWeekday = 0;

    final weekdays = ['日', '一', '二', '三', '四', '五', '六'];

    return Container(
      height: showDate ? 60 : 44,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[900]
            : Colors.white,
      ),
      child: Row(
        children: [
          // 左侧占位（对应时间轴）
          Container(
            width: 56,
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
              child: showDate && currentWeek != null
                  ? Text(
                      '${weekStartDate.month}月',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          // 星期几
          ...List.generate(7, (index) {
            final date = weekStartDate.add(Duration(days: index));
            final isToday = highlightToday &&
                date.year == now.year &&
                date.month == now.month &&
                date.day == now.day;

            return Expanded(
              child: Container(
                decoration: showGrid
                    ? BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                            width: 0.5,
                          ),
                          bottom: BorderSide(
                            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                            width: 0.5,
                          ),
                        ),
                      )
                    : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 星期几
                    Text(
                      weekdays[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                        color: isToday
                            ? Theme.of(context).colorScheme.primary
                            : (isDark ? Colors.grey[300] : Colors.grey[800]),
                      ),
                    ),
                    if (showDate) ...[
                      const SizedBox(height: 4),
                      // 日期
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isToday
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            DateFormat('d').format(date),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  isToday ? FontWeight.w600 : FontWeight.w400,
                              color: isToday
                                  ? Colors.white
                                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
