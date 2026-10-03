import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'new_group_view_model.dart';

final newGroupViewModelProvider =
    AsyncNotifierProvider.autoDispose<NewGroupViewModel, void>(
  NewGroupViewModel.new,
);
