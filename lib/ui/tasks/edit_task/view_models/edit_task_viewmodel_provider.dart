import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'edit_task_viewmodel.dart';

final editTaskViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<EditTaskViewModel, EditTaskFormState, String>(
      (taskId) => EditTaskViewModel(taskId),
    );
