import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/ui/core/utils/deadline_format.dart';

class TasksOverview {
  const TasksOverview({required this.dueTodayCount, required this.upcoming});

  final int dueTodayCount;
  final List<Task> upcoming;

  List<Map<String, dynamic>> get upcomingItems => [
    for (final task in upcoming)
      {
        'title': task.title,
        'icon': task.isPriority ? Icons.priority_high : Icons.task_alt,
        'description': deadlineText(task.deadline),
        'group': task.groupName.isEmpty ? null : task.groupName,
      },
  ];
}

final tasksOverviewProvider = FutureProvider.autoDispose<TasksOverview>((
  ref,
) async {
  final tasks = await ref.watch(taskRepositoryProvider).getAllTasks(mine: true);
  final now = DateTime.now();
  final pending = tasks.where((task) => task.status != TaskStatus.done).toList()
    ..sort((a, b) => a.deadline.compareTo(b.deadline));
  final dueTodayCount = pending
      .where(
        (task) =>
            task.deadline.year == now.year &&
            task.deadline.month == now.month &&
            task.deadline.day == now.day,
      )
      .length;
  final upcoming = pending
      .where((task) => !task.deadline.isBefore(now))
      .take(5)
      .toList();
  return TasksOverview(dueTodayCount: dueTodayCount, upcoming: upcoming);
});
