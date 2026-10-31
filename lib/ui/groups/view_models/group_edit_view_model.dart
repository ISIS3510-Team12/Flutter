import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:team12_flutter_juggle/data/db/daos/groups/groups_cache_dao_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/groups/group_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/network/network_first.dart';

class GroupEditViewModel extends AsyncNotifier<TaskGroup> {
  Object? lastFailure;

  GroupEditViewModel(this.groupId);

  final int groupId;

  @override
  Future<TaskGroup> build() async {
    final user = await ref.watch(currentUserProvider.future);

    if (user == null) {
      throw StateError('No authenticated user found.');
    }

    final isOnline = ref.watch(isOnlineProvider);
    final repository = ref.watch(groupRepositoryProvider);
    final cache = ref.watch(groupsCacheDaoProvider);

    final result = await networkFirst<TaskGroup>(
      isOnline: isOnline,
      fetch: () => repository.getGroup(groupId),
      save: (group) => cache.save(user.userId, group),
      fallback: () => cache.watchGroup(user.userId, groupId).first,
    );

    return result.value;
  }

  Future<bool> updateGroup({
    required String name,
    required String description,
    required List<String> emailsToAdd,
    required List<String> userIdsToRemove,
  }) async {
    if (!ref.read(isOnlineProvider)) {
      return false;
    }

    // Prevent simultaneous updates.
    if (state.isLoading) {
      return false;
    }

    final user = await ref.read(currentUserProvider.future);

    if (!ref.mounted || user == null) {
      return false;
    }

    final repository = ref.read(groupRepositoryProvider);
    final cache = ref.read(groupsCacheDaoProvider);

    // Preserve the current group while indicating that an update is running.
    final previousGroup = state.value;

    if (previousGroup == null) {
      return false;
    }

    state = const AsyncLoading<TaskGroup>();

    final result = await AsyncValue.guard(() async {
      await repository.updateGroup(
        groupId,
        name: name,
        description: description,
      );

      for (final email in emailsToAdd) {
        await repository.addMember(groupId, email);
      }

      for (final userId in userIdsToRemove) {
        await repository.removeMember(groupId, userId);
      }

      final updatedGroup = await repository.getGroup(groupId);

      await saveQuietly(() => cache.save(user.userId, updatedGroup));

      return updatedGroup;
    });

    if (!ref.mounted) {
      return false;
    }

    lastFailure = result.error;

    if (result.hasError) {
      // Restore the previous state and preserve the form.
      state = AsyncData(previousGroup);
      return false;
    }

    state = result;

    return true;
  }
}
