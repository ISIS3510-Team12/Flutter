import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:team12_flutter_juggle/data/repositories/user/user_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/user/user.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';

class GroupUsersViewModel extends AsyncNotifier<List<User>> {
  @override
  Future<List<User>> build() async {
    final currentUser = await ref.watch(currentUserProvider.future);
    final userRepository = ref.watch(userRepositoryProvider);

    final users = await userRepository.getUsers();

    return users
        .where(
          (user) => user.userId != currentUser?.userId,
        )
        .toList();
  }
}
