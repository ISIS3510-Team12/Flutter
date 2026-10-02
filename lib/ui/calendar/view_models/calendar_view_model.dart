import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:team12_flutter_juggle/ui/calendar/strategies/day_schedule_strategy.dart';

class CalendarViewModel extends AsyncNotifier<CalendarState> {
  late final DayScheduleStrategy _scheduleStrategy;

  @override
  Future<CalendarState> build() async {
    _scheduleStrategy = DayScheduleStrategy();

    final selectedDate = DateTime.now();

    return CalendarState(
      selectedDate: selectedDate,
      week: _getWeek(selectedDate),
      schedule: _scheduleStrategy.getSchedule(
        const [],
        selectedDate,
      ),
    );
  }

  void selectDate(DateTime date) {
    final currentState = state.value;

    if (currentState == null) {
      return;
    }

    state = AsyncData(
      currentState.copyWith(
        selectedDate: date,
        week: _getWeek(date),
        schedule: _scheduleStrategy.getSchedule(
          currentState.schedule,
          date,
        ),
      ),
    );
  }

  void previousWeek() {
    final currentState = state.value;

    if (currentState == null) {
      return;
    }

    final newDate = currentState.selectedDate.subtract(
      const Duration(days: 7),
    );

    selectDate(newDate);
  }

  void nextWeek() {
    final currentState = state.value;

    if (currentState == null) {
      return;
    }

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
  final List<dynamic> schedule;

  const CalendarState({
    required this.selectedDate,
    required this.week,
    required this.schedule,
  });

  CalendarState copyWith({
    DateTime? selectedDate,
    List<DateTime>? week,
    List<dynamic>? schedule,
  }) {
    return CalendarState(
      selectedDate: selectedDate ?? this.selectedDate,
      week: week ?? this.week,
      schedule: schedule ?? this.schedule,
    );
  }
}