import 'package:flutter/material.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

List<String> _getWeekdayShortNames(AppLocalizations l10n) => [
      l10n.sundayShort,
      l10n.mondayShort,
      l10n.tuesdayShort,
      l10n.wednesdayShort,
      l10n.thursdayShort,
      l10n.fridayShort,
      l10n.saturdayShort,
    ];

List<String> _getMonthShortNames(AppLocalizations l10n) => [
      l10n.janShort,
      l10n.febShort,
      l10n.marShort,
      l10n.aprShort,
      l10n.mayShort,
      l10n.junShort,
      l10n.julShort,
      l10n.augShort,
      l10n.sepShort,
      l10n.octShort,
      l10n.novShort,
      l10n.decShort,
    ];

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

    final monthStr = _getMonthShortNames(context.l10n)[weekStartDate.month - 1];

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
                      _getWeekdayShortNames(context.l10n)[date.weekday % 7],
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
                            date.day.toString(),
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
