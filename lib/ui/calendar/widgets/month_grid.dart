import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';

class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.weeks,
    required this.tasksByDay,
    required this.selectedDate,
    required this.today,
    required this.onDaySelected,
  });

  final List<List<DateTime?>> weeks;
  final Map<int, List<Task>> tasksByDay;
  final DateTime selectedDate;
  final DateTime today;
  final ValueChanged<DateTime> onDaySelected;

  static const _weekdays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
  static const _minRowHeight = 96.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  for (final weekday in _weekdays)
                    Expanded(
                      child: Text(
                        weekday,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final rowHeight = max(
                    _minRowHeight,
                    constraints.maxHeight / weeks.length,
                  );
                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      for (final week in weeks)
                        Container(
                          height: rowHeight,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final day in week)
                                Expanded(
                                  child: day == null
                                      ? const SizedBox.shrink()
                                      : _DayCell(
                                          day: day,
                                          tasks:
                                              tasksByDay[day.day] ?? const [],
                                          isToday: DateUtils.isSameDay(
                                            day,
                                            today,
                                          ),
                                          isSelected: DateUtils.isSameDay(
                                            day,
                                            selectedDate,
                                          ),
                                          onTap: () => onDaySelected(day),
                                        ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.tasks,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime day;
  final List<Task> tasks;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  static const _maxChips = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hidden = tasks.length - _maxChips;
    final count = tasks.length == 1 ? '1 task' : '${tasks.length} tasks';

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${DateFormat('MMMM d').format(day)}, $count',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        child: ClipRect(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(1, 3, 1, 0),
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isToday
                        ? colors.primary
                        : isSelected
                        ? colors.primaryFixed
                        : Colors.transparent,
                  ),
                  child: Text(
                    '${day.day}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isToday
                          ? colors.onPrimary
                          : isSelected
                          ? colors.onPrimaryFixed
                          : colors.onSurface,
                    ),
                  ),
                ),
                for (final task in tasks.take(_maxChips))
                  Container(
                    width: double.infinity,
                    height: 15,
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: colors.primaryFixed,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      task.title,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        height: 1.2,
                        color: colors.onPrimaryFixed,
                      ),
                    ),
                  ),
                if (hidden > 0)
                  Text(
                    '+$hidden',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: colors.outline,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
