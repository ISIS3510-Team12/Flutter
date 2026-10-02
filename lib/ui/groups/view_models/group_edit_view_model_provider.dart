import 'package:flutter_riverpod/legacy.dart';

import 'package:team12_flutter_juggle/data/repositories/group/group_repository_provider.dart';
import 'package:team12_flutter_juggle/ui/groups/view_models/group_edit_view_model.dart';

final groupEditViewModelProvider =
    ChangeNotifierProvider<GroupEditViewModel>((ref) {
  final groupRepository = ref.watch(groupRepositoryProvider);

  return GroupEditViewModel(
    groupRepository: groupRepository,
  );
});