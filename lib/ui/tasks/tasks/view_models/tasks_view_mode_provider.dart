import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TasksViewMode { list, board }

class TasksViewModeNotifier extends Notifier<TasksViewMode> {
  @override
  TasksViewMode build() => TasksViewMode.list;

  void select(TasksViewMode mode) => state = mode;
}

final tasksViewModeProvider =
    NotifierProvider<TasksViewModeNotifier, TasksViewMode>(
      TasksViewModeNotifier.new,
    );
