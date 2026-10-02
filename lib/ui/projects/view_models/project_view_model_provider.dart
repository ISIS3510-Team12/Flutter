import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:team12_flutter_juggle/domain/models/project/project.dart';
import 'package:team12_flutter_juggle/ui/projects/view_models/project_view_model.dart';

final projectDetailViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<ProjectDetailViewModel, ProjectDetailState, int>(
      (projectId) => ProjectDetailViewModel(projectId),
    );

final projectCreateViewModelProvider =
    AsyncNotifierProvider.autoDispose<ProjectCreateViewModel, Project?>(
      ProjectCreateViewModel.new,
    );
