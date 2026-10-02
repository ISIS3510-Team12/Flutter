import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'all_tasks_viewmodel.dart';

final allTasksViewModelProvider =
    AsyncNotifierProvider.autoDispose<AllTasksViewModel, AllTasksState>(
      AllTasksViewModel.new,
    );
