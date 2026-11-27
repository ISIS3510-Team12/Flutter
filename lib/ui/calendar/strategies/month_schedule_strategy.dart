import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';

import 'schedule_strategy.dart';

class MonthScheduleStrategy implements ScheduleStrategy<Task> {
  const MonthScheduleStrategy();

  @override
  List<Task> getSchedule(List<Task> items, DateTime selectedDate) {
    return items.where((task) {
      final deadline = task.deadline;
      return deadline.year == selectedDate.year &&
          deadline.month == selectedDate.month;
    }).toList()..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  Map<int, List<Task>> getTasksByDay(List<Task> items, DateTime month) {
    final byDay = <int, List<Task>>{};
    for (final task in getSchedule(items, month)) {
      byDay.putIfAbsent(task.deadline.day, () => []).add(task);
    }
    return byDay;
  }

  List<List<DateTime?>> getWeeks(DateTime month) {
    final leading = DateTime(month.year, month.month).weekday % 7;
    final days = DateTime(month.year, month.month + 1, 0).day;
    final weeks = ((leading + days) / 7).ceil();
    return List.generate(weeks, (week) {
      return List.generate(7, (column) {
        final day = week * 7 + column - leading + 1;
        return day < 1 || day > days
            ? null
            : DateTime(month.year, month.month, day);
      });
    });
  }
}
