import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'view_task_viewmodel.dart';

final viewTaskViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<ViewTaskViewModel, ViewTaskState, String>(
      (taskId) => ViewTaskViewModel(taskId),
    );
