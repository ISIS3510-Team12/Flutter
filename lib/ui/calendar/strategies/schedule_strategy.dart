abstract class ScheduleStrategy<T> {
  List<T> getSchedule(
    List<T> items,
    DateTime selectedDate,
  );
}