import 'package:team12_flutter_juggle/data/local/pending_op.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';

sealed class TaskListEntry {
  const TaskListEntry();

  Task get task;
}

class SyncedTaskEntry extends TaskListEntry {
  const SyncedTaskEntry(this.task);

  @override
  final Task task;
}

class PendingTaskEntry extends TaskListEntry {
  PendingTaskEntry(this.op) : task = op.task;

  final PendingOp op;

  @override
  final Task task;
}
