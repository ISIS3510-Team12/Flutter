import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';

import 'schedule_strategy.dart';

class DayScheduleStrategy implements ScheduleStrategy<Task> {
  @override
  List<Task> getSchedule(
    List<Task> items,
    DateTime selectedDate,
  ) {
    return items.where((task) {
      final deadline = task.deadline;

      return deadline.year == selectedDate.year &&
          deadline.month == selectedDate.month &&
          deadline.day == selectedDate.day;
    }).toList();
  }
}