import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'create_task_viewmodel.dart';

final createTaskViewModelProvider =
    AsyncNotifierProvider.autoDispose<CreateTaskViewModel, CreateTaskFormState>(
      CreateTaskViewModel.new,
    );
