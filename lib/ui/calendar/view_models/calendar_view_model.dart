import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/ui/calendar/strategies/day_schedule_strategy.dart';

class CalendarViewModel extends AsyncNotifier<CalendarState> {
  final DayScheduleStrategy _scheduleStrategy = DayScheduleStrategy();

  @override
  Future<CalendarState> build() async {
    final taskRepository = ref.watch(taskRepositoryProvider);

    final selectedDate = DateTime.now();
    final tasks = await taskRepository.getAllTasks();

    return CalendarState(
      selectedDate: selectedDate,
      week: _getWeek(selectedDate),
      tasks: tasks,
      schedule: _scheduleStrategy.getSchedule(
        tasks,
        selectedDate,
      ),
    );
  }

  void selectDate(DateTime date) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncData(
      currentState.copyWith(
        selectedDate: date,
        week: _getWeek(date),
        schedule: _scheduleStrategy.getSchedule(
          currentState.tasks,
          date,
        ),
      ),
    );
  }

  void previousWeek() {
    final currentState = state.value;
    if (currentState == null) return;

    final newDate = currentState.selectedDate.subtract(
      const Duration(days: 7),
    );

    selectDate(newDate);
  }

  void nextWeek() {
    final currentState = state.value;
    if (currentState == null) return;

    final newDate = currentState.selectedDate.add(
      const Duration(days: 7),
    );

    selectDate(newDate);
  }

  List<DateTime> _getWeek(DateTime date) {
    final startOfWeek = date.subtract(
      Duration(days: date.weekday - 1),
    );

    return List.generate(
      7,
      (index) => DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day + index,
      ),
    );
  }
}

class CalendarState {
  final DateTime selectedDate;
  final List<DateTime> week;
  final List<Task> tasks;
  final List<Task> schedule;

  const CalendarState({
    required this.selectedDate,
    required this.week,
    required this.tasks,
    required this.schedule,
  });

  CalendarState copyWith({
    DateTime? selectedDate,
    List<DateTime>? week,
    List<Task>? tasks,
    List<Task>? schedule,
  }) {
    return CalendarState(
      selectedDate: selectedDate ?? this.selectedDate,
      week: week ?? this.week,
      tasks: tasks ?? this.tasks,
      schedule: schedule ?? this.schedule,
    );
  }
}