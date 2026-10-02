import 'package:flutter_riverpod/legacy.dart';

import 'package:team12_flutter_juggle/data/repositories/group/group_repository_provider.dart';
import 'package:team12_flutter_juggle/ui/groups/view_models/new_group_view_model.dart';

final newGroupViewModelProvider =
    ChangeNotifierProvider<NewGroupViewModel>((ref) {
  final groupRepository = ref.watch(groupRepositoryProvider);

  return NewGroupViewModel(
    groupRepository: groupRepository,
  );
});