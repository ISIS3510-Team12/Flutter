import 'package:flutter_riverpod/legacy.dart';
import 'package:team12_flutter_juggle/data/repositories/group/group_repository_provider.dart';
import 'package:team12_flutter_juggle/ui/groups/view_models/groups_view_model.dart';

final groupsViewModelProvider =
    ChangeNotifierProvider<GroupsViewModel>((ref) {
  final groupRepository = ref.watch(groupRepositoryProvider);

  return GroupsViewModel(
    groupRepository: groupRepository,
  );
});