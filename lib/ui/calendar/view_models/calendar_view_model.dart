import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/calendar/calendar_preferences_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/calendar/calendar_view_mode.dart';
import 'package:team12_flutter_juggle/ui/core/utils/network_exceptions.dart';
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

    final isOnline = ref.watch(isOnlineProvider);
    final cache = ref.read(tasksCacheDaoProvider);
    final previous = state.value;
    final viewMode =
        previous?.viewMode ??
        await ref
            .read(calendarPreferencesRepositoryProvider)
            .getViewMode(user.userId);
    final selectedDate = previous?.selectedDate ?? DateTime.now();
    final saved = await cache.findMine(user.userId);

    var tasks = saved;
    if (saved.isEmpty) {
      if (!isOnline) throw const NetworkUnavailableException();
      tasks = await _fetchAndSave(ref, user.userId);
    } else if (isOnline) {
      final buildRef = ref;
      Future(() => _revalidate(buildRef, user.userId));
    }

    return CalendarState(
      selectedDate: selectedDate,
      visibleMonth:
          previous?.visibleMonth ??
          DateTime(selectedDate.year, selectedDate.month),
      viewMode: viewMode,
      week: _getWeek(selectedDate),
      tasks: tasks,
      schedule: _scheduleStrategy.getSchedule(tasks, selectedDate),
      fromCache: saved.isNotEmpty,
      isRefreshing: saved.isNotEmpty && isOnline,
    );
  }

  Future<List<Task>> _fetchAndSave(Ref buildRef, String userId) async {
    final cache = buildRef.read(tasksCacheDaoProvider);
    final tasks = await buildRef
        .read(taskRepositoryProvider)
        .getAllTasks(mine: true);
    if (buildRef.mounted) {
      await saveQuietly(() => cache.replaceForUser(userId, tasks));
    }
    return tasks;
  }

  Future<void> _revalidate(Ref buildRef, String userId) async {
    if (!buildRef.mounted) return;
    try {
      final tasks = await _fetchAndSave(buildRef, userId);
      if (!buildRef.mounted) return;
      final current = state.value;
      if (current == null) return;
      state = AsyncData(
        current.copyWith(
          tasks: tasks,
          schedule: _scheduleStrategy.getSchedule(tasks, current.selectedDate),
          fromCache: false,
          isRefreshing: false,
          refreshFailed: false,
        ),
      );
    } catch (error) {
      debugPrint('Calendar revalidation failed: $error');
      if (!buildRef.mounted) return;
      final current = state.value;
      if (current == null) return;
      state = AsyncData(
        current.copyWith(isRefreshing: false, refreshFailed: true),
      );
    }
  }

  Future<void> changeViewMode(CalendarViewMode mode) async {
    final currentState = state.value;
    if (currentState == null || currentState.viewMode == mode) return;

    final selected = currentState.selectedDate;
    state = AsyncData(
      currentState.copyWith(
        viewMode: mode,
        visibleMonth: DateTime(selected.year, selected.month),
      ),
    );

    final user = await ref.read(currentUserProvider.future);
    if (user == null || !ref.mounted) return;
    await saveQuietly(
      () => ref
          .read(calendarPreferencesRepositoryProvider)
          .saveViewMode(user.userId, mode),
    );
  }

  void previousMonth() => _moveMonth(-1);

  void nextMonth() => _moveMonth(1);

  void goToToday() => selectDate(DateTime.now());

  void _moveMonth(int offset) {
    final currentState = state.value;
    if (currentState == null) return;

    final month = currentState.visibleMonth;
    state = AsyncData(
      currentState.copyWith(
        visibleMonth: DateTime(month.year, month.month + offset),
      ),
    );
  }

  void selectDate(DateTime date) {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncData(
      currentState.copyWith(
        selectedDate: date,
        visibleMonth: DateTime(date.year, date.month),
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
    required DateTime visibleMonth,
    required CalendarViewMode viewMode,
    required List<DateTime> week,
    required List<Task> tasks,
    required List<Task> schedule,
    @Default(false) bool fromCache,
    @Default(false) bool isRefreshing,
    @Default(false) bool refreshFailed,
  }) = _CalendarState;
}
