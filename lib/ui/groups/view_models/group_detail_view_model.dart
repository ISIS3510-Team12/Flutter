import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:team12_flutter_juggle/data/repositories/group/group_repository_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/project/project_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/group/group.dart';
import 'package:team12_flutter_juggle/domain/models/project/project.dart';

class GroupDetailViewModel extends AsyncNotifier<GroupDetailState> {
  GroupDetailViewModel(this.groupId);

  final int groupId;

  @override
  Future<GroupDetailState> build() async {
    final groupRepository = ref.watch(groupRepositoryProvider);
    final projectRepository = ref.watch(projectRepositoryProvider);

    final group = await groupRepository.getGroup(groupId);
    final projects = await projectRepository.getProjectsByGroup(groupId);

    if (!ref.mounted) {
      throw StateError('Group detail provider was disposed.');
    }

    return GroupDetailState(
      group: group,
      projects: projects,
    );
  }
}

class GroupDetailState {
  const GroupDetailState({
    required this.group,
    required this.projects,
  });

  final Group group;
  final List<Project> projects;
}