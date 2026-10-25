import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';

class TasksOverview {
  const TasksOverview({required this.dueToday, required this.urgentCount});

  final List<Task> dueToday;
  final int urgentCount;
}

final tasksOverviewProvider = FutureProvider.autoDispose<TasksOverview>((
  ref,
) async {
  final tasks = await ref.watch(taskRepositoryProvider).getAllTasks(mine: true);
  final now = DateTime.now();
  final pending = tasks.where((task) => task.status != TaskStatus.done).toList()
    ..sort((a, b) => a.deadline.compareTo(b.deadline));

  final dueToday = pending
      .where(
        (task) =>
            task.deadline.year == now.year &&
            task.deadline.month == now.month &&
            task.deadline.day == now.day,
      )
      .toList();
  final urgentCount = pending.where((task) => task.isPriority).length;
  return TasksOverview(dueToday: dueToday, urgentCount: urgentCount);
});
