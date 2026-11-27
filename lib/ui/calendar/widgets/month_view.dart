import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:team12_flutter_juggle/ui/calendar/strategies/month_schedule_strategy.dart';
import 'package:team12_flutter_juggle/ui/calendar/view_models/calendar_view_model.dart';
import 'package:team12_flutter_juggle/ui/calendar/widgets/month_grid.dart';

class MonthView extends StatelessWidget {
  const MonthView({
    super.key,
    required this.calendar,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onToday,
    required this.onDaySelected,
  });

  final CalendarState calendar;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onToday;
  final ValueChanged<DateTime> onDaySelected;

  static const _strategy = MonthScheduleStrategy();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final month = calendar.visibleMonth;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    DateFormat('MMMM, y').format(month),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Previous month',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerLow,
                ),
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                tooltip: 'Next month',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerLow,
                ),
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right),
              ),
              const SizedBox(width: 4),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryFixed,
                  foregroundColor: theme.colorScheme.onPrimaryFixed,
                ),
                onPressed: onToday,
                child: const Text('Today'),
              ),
            ],
          ),
        ),
        Expanded(
          child: MonthGrid(
            weeks: _strategy.getWeeks(month),
            tasksByDay: _strategy.getTasksByDay(calendar.tasks, month),
            selectedDate: calendar.selectedDate,
            today: DateTime.now(),
            onDaySelected: onDaySelected,
          ),
        ),
      ],
    );
  }
}
