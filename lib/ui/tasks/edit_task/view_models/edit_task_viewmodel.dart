import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/view_task/view_models/view_task_viewmodel_provider.dart';

class EditTaskFormState {
  const EditTaskFormState({
    required this.task,
    required this.members,
    required this.type,
    required this.selectedMember,
    required this.deadline,
    required this.isPriority,
    required this.needsHelp,
    required this.notes,
  });

  final Task task;
  final List<String> members;
  final TaskType type;
  final String selectedMember;
  final DateTime deadline;
  final bool isPriority;
  final bool needsHelp;
  final String notes;

  EditTaskFormState copyWith({
    TaskType? type,
    String? selectedMember,
    DateTime? deadline,
    bool? isPriority,
    bool? needsHelp,
    String? notes,
  }) {
    return EditTaskFormState(
      task: task,
      members: members,
      type: type ?? this.type,
      selectedMember: selectedMember ?? this.selectedMember,
      deadline: deadline ?? this.deadline,
      isPriority: isPriority ?? this.isPriority,
      needsHelp: needsHelp ?? this.needsHelp,
      notes: notes ?? this.notes,
    );
  }
}

class EditTaskViewModel extends AsyncNotifier<EditTaskFormState> {
  EditTaskViewModel(this.taskId);

  final String taskId;

  @override
  Future<EditTaskFormState> build() async {
    final repository = ref.read(taskRepositoryProvider);
    final task = await repository.getTask(taskId);
    final members = await repository.getGroupMembers();
    return EditTaskFormState(
      task: task,
      members: members,
      type: task.type,
      selectedMember: task.assigneeName,
      deadline: task.deadline,
      isPriority: task.isPriority,
      needsHelp: task.needsHelp,
      notes: task.notes,
    );
  }

  void updateType(TaskType value) => _update((s) => s.copyWith(type: value));

  void updateSelectedMember(String value) =>
      _update((s) => s.copyWith(selectedMember: value));

  void updateDeadline(DateTime value) =>
      _update((s) => s.copyWith(deadline: value));

  void updateIsPriority(bool value) =>
      _update((s) => s.copyWith(isPriority: value));

  void updateNeedsHelp(bool value) =>
      _update((s) => s.copyWith(needsHelp: value));

  void updateNotes(String value) => _update((s) => s.copyWith(notes: value));

  void _update(EditTaskFormState Function(EditTaskFormState) update) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(update(current));
  }

  Future<void> submit() async {
    final current = state.value;
    if (current == null) return;
    final updated = current.task.copyWith(
      type: current.type,
      assignees: [current.selectedMember],
      deadline: current.deadline,
      isPriority: current.isPriority,
      needsHelp: current.needsHelp,
      notes: current.notes,
    );
    await ref.read(taskRepositoryProvider).updateTask(updated);
    ref.invalidate(tasksViewModelProvider);
    ref.invalidate(viewTaskViewModelProvider(taskId));
  }
}
