import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';

class SelectedTaskGroupId extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int groupId) => state = groupId;

  TaskGroup? resolve(List<TaskGroup> groups) {
    if (groups.isEmpty) return null;
    return groups.firstWhere(
      (group) => group.id == state,
      orElse: () => groups.firstWhere(
        (group) => group.isPersonal,
        orElse: () => groups.first,
      ),
    );
  }
}

final selectedTaskGroupIdProvider = NotifierProvider<SelectedTaskGroupId, int?>(
  SelectedTaskGroupId.new,
);
