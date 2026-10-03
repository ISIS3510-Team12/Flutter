import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tasks_viewmodel.dart';

final tasksViewModelProvider =
    AsyncNotifierProvider.autoDispose<TasksViewModel, TasksState>(
      TasksViewModel.new,
    );
