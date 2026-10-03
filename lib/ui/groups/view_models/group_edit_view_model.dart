import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:team12_flutter_juggle/data/repositories/groups/group_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';

class GroupEditViewModel extends AsyncNotifier<TaskGroup> {
  GroupEditViewModel(this.groupId);

  final int groupId;

  @override
  Future<TaskGroup> build() async {
    final repository = ref.watch(groupRepositoryProvider);

    return repository.getGroup(groupId);
  }

  Future<bool> updateGroup({
    required String name,
    required String description,
    required List<String> emailsToAdd,
    required List<String> userIdsToRemove,
  }) async {
    final repository = ref.read(groupRepositoryProvider);

    final result = await AsyncValue.guard(() async {
      await repository.updateGroup(
        groupId,
        name: name,
        description: description,
      );

      for (final email in emailsToAdd) {
        await repository.addMember(
          groupId,
          email,
        );
      }

      return repository.getGroup(groupId);
    });

    if (!ref.mounted) {
      return false;
    }

    state = result;

    return result.hasValue;
  }
}
