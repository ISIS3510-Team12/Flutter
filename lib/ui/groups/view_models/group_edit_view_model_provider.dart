import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';
import 'group_edit_view_model.dart';

final groupEditViewModelProvider =
    AsyncNotifierProvider.autoDispose
        .family<GroupEditViewModel, TaskGroup, int>(
  GroupEditViewModel.new,
);
