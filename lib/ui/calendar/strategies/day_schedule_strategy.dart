import 'schedule_strategy.dart';

class DayScheduleStrategy<T> implements ScheduleStrategy<T> {
  @override
  List<T> getSchedule(
    List<T> items,
    DateTime selectedDate,
  ) {
    return items;
  }
}