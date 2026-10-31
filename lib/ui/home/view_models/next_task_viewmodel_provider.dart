import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/home/view_models/next_task_viewmodel.dart';

final nextTaskViewModelProvider =
    AsyncNotifierProvider<NextTaskViewModel, NextTaskState>(
      NextTaskViewModel.new,
      retry: (retryCount, error) => null,
    );
