import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/db/daos/tasks/tasks_cache_dao_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/network/network_first.dart';
import 'package:team12_flutter_juggle/ui/calendar/strategies/day_schedule_strategy.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';

part 'calendar_view_model.freezed.dart';

class CalendarViewModel extends AsyncNotifier<CalendarState> {
  final DayScheduleStrategy _scheduleStrategy = DayScheduleStrategy();

  @override
  Future<CalendarState> build() async {
    final user = await ref.watch(currentUserProvider.future);
    if (user == null) throw StateError('User is not logged in');

    final taskRepository = ref.watch(taskRepositoryProvider);
    final cache = ref.read(tasksCacheDaoProvider);
    final selectedDate = state.value?.selectedDate ?? DateTime.now();

    final read = await networkFirst(
      isOnline: ref.watch(isOnlineProvider),
      fetch: () => taskRepository.getAllTasks(mine: true),
      save: (tasks) => cache.replaceForUser(user.userId, tasks),
      fallback: () async {
        final saved = await cache.findMine(user.userId);
        return saved.isEmpty ? null : saved;
      },
    );

    return CalendarState(
      selectedDate: selectedDate,
      week: _getWeek(selectedDate),
      tasks: read.value,
      schedule: _scheduleStrategy.getSchedule(
        read.value,
        selectedDate,
      ),
      fromCache: read.fromCache,
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

@freezed
abstract class CalendarState with _$CalendarState {
  const factory CalendarState({
    required DateTime selectedDate,
    required List<DateTime> week,
    required List<Task> tasks,
    required List<Task> schedule,
    @Default(false) bool fromCache,
  }) = _CalendarState;
}
