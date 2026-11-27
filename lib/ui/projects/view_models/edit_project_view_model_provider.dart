import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:team12_flutter_juggle/domain/models/project/project.dart';
import 'package:team12_flutter_juggle/ui/projects/view_models/project_view_model.dart';
import 'package:team12_flutter_juggle/ui/projects/view_models/edit_project_view_model.dart';

final projectDetailViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<ProjectDetailViewModel, ProjectDetailState, int>(
  (projectId) => ProjectDetailViewModel(projectId),
);

final projectCreateViewModelProvider =
    AsyncNotifierProvider.autoDispose<ProjectCreateViewModel, Project?>(
  ProjectCreateViewModel.new,
);

final editProjectViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<
        EditProjectViewModel,
        EditProjectState,
        ({int projectId, int groupId})>(
  (args) => EditProjectViewModel(
    projectId: args.projectId,
    groupId: args.groupId,
  ),
);
