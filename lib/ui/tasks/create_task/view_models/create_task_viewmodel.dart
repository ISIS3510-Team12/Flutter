import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_viewmodel_provider.dart';

class CreateTaskFormState {
  const CreateTaskFormState({
    required this.groupName,
    required this.members,
    this.title = '',
    this.type = TaskType.coding,
    this.selectedMember = '',
    this.deadline,
    this.isPriority = false,
    this.needsHelp = false,
    this.notes = '',
  });

  final String groupName;
  final List<String> members;
  final String title;
  final TaskType type;
  final String selectedMember;
  final DateTime? deadline;
  final bool isPriority;
  final bool needsHelp;
  final String notes;

  bool get canSubmit =>
      title.isNotEmpty && selectedMember.isNotEmpty && deadline != null;

  CreateTaskFormState copyWith({
    String? title,
    TaskType? type,
    String? selectedMember,
    DateTime? deadline,
    bool? isPriority,
    bool? needsHelp,
    String? notes,
  }) {
    return CreateTaskFormState(
      groupName: groupName,
      members: members,
      title: title ?? this.title,
      type: type ?? this.type,
      selectedMember: selectedMember ?? this.selectedMember,
      deadline: deadline ?? this.deadline,
      isPriority: isPriority ?? this.isPriority,
      needsHelp: needsHelp ?? this.needsHelp,
      notes: notes ?? this.notes,
    );
  }
}

class CreateTaskViewModel extends AsyncNotifier<CreateTaskFormState> {
  @override
  Future<CreateTaskFormState> build() async {
    final repository = ref.read(taskRepositoryProvider);
    final groupName = await repository.getCurrentGroupName();
    final members = await repository.getGroupMembers();
    return CreateTaskFormState(
      groupName: groupName,
      members: members,
      selectedMember: members.isEmpty ? '' : members.first,
    );
  }

  void updateTitle(String value) => _update((s) => s.copyWith(title: value));

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

  void _update(CreateTaskFormState Function(CreateTaskFormState) update) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(update(current));
  }

  Future<void> submit() async {
    final current = state.value;
    if (current == null || !current.canSubmit) return;
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: current.title,
      description: current.notes,
      type: current.type,
      status: TaskStatus.pending,
      groupName: current.groupName,
      assignees: [current.selectedMember],
      deadline: current.deadline!,
      isMine: true,
      isPriority: current.isPriority,
      needsHelp: current.needsHelp,
      notes: current.notes,
    );
    await ref.read(taskRepositoryProvider).createTask(task);
    ref.invalidate(tasksViewModelProvider);
  }
}
