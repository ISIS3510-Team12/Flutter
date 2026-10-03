import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/domain/models/user/user.dart';

import 'group_users_view_model.dart';

final groupUsersViewModelProvider =
    AsyncNotifierProvider.autoDispose<
      GroupUsersViewModel,
      List<User>
    >(
      GroupUsersViewModel.new,
    );