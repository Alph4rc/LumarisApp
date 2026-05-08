import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

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
    final colors = context.clubColors;
    final now = DateTime.now();

    final monthStr = DateFormat.MMM().format(weekStartDate);

    return Container(
      decoration: showGrid
          ? BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: colors.separator,
                  width: 0.5,
                ),
              ),
            )
          : null,
      height: showDate ? 60 : 44,
      child: Row(
        children: [
          // 左侧占位（对应时间轴）
          Container(
            width: 56,
            decoration: showGrid
                ? BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: colors.separator,
                        width: 0.5,
                      ),
                    ),
                  )
                : null,
            child: Center(
              child: showDate && currentWeek != null
                  ? Text(
                      monthStr,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.secondaryLabel,
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
                            color: colors.separator,
                            width: 0.5,
                          ),
                          bottom: BorderSide(
                            color: colors.separator,
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
                      DateFormat.E().format(date),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                        color: isToday
                            ? Theme.of(context).colorScheme.primary
                            : colors.label,
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
                                  ? colors.onAccent
                                  : colors.secondaryLabel,
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
