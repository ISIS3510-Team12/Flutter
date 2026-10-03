import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:team12_flutter_juggle/data/repositories/groups/group_repository_provider.dart';

class NewGroupViewModel extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> createGroup({
    required String name,
    required String description,
    required List<String> selectedUserIds,
  }) async {
    final repository = ref.read(groupRepositoryProvider);

    final result = await AsyncValue.guard(() async {
      await repository.createGroup(
        name,
        description: description,
        userIds: selectedUserIds,
      );
    });

    if (!ref.mounted) {
      return false;
    }

    state = result;

    return result.hasValue;
  }
}
