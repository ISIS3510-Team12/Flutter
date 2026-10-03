import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'groups_view_model.dart';

final groupsViewModelProvider =
    AsyncNotifierProvider.autoDispose<GroupsViewModel, GroupsState>(
  GroupsViewModel.new,
);

