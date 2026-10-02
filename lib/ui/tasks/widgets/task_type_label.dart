import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';

String taskTypeLabel(TaskType type) {
  switch (type) {
    case TaskType.coding:
      return 'Coding';
    case TaskType.design:
      return 'Design';
    case TaskType.writing:
      return 'Writing';
    case TaskType.research:
      return 'Research';
  }
}
