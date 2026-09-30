import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/ui/core/utils/deadline_format.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_viewmodel_provider.dart';

class CreateTaskFormState {
  const CreateTaskFormState({
    required this.groupName,
    required this.members,
    required this.projects,
    required this.candidateTasks,
    this.title = '',
    this.type = TaskType.coding,
    this.selectedMember = '',
    this.selectedProject,
    this.deadline,
    this.startTime,
    this.endTime,
    this.isPriority = false,
    this.needsHelp = false,
    this.notes = '',
    this.relatedTaskIds = const {},
  });

  final String groupName;
  final List<String> members;
  final List<String> projects;
  final List<Task> candidateTasks;
  final String title;
  final TaskType type;
  final String selectedMember;
  final String? selectedProject;
  final DateTime? deadline;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final bool isPriority;
  final bool needsHelp;
  final String notes;
  final Set<String> relatedTaskIds;

  bool get canSubmit =>
      title.isNotEmpty && selectedMember.isNotEmpty && deadline != null;

  String? get timeRangeLabel {
    if (startTime == null || endTime == null) return null;
    return '${timeOfDayLabel(startTime!)} - ${timeOfDayLabel(endTime!)}';
  }

  CreateTaskFormState copyWith({
    String? title,
    TaskType? type,
    String? selectedMember,
    String? selectedProject,
    DateTime? deadline,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? isPriority,
    bool? needsHelp,
    String? notes,
    Set<String>? relatedTaskIds,
  }) {
    return CreateTaskFormState(
      groupName: groupName,
      members: members,
      projects: projects,
      candidateTasks: candidateTasks,
      title: title ?? this.title,
      type: type ?? this.type,
      selectedMember: selectedMember ?? this.selectedMember,
      selectedProject: selectedProject ?? this.selectedProject,
      deadline: deadline ?? this.deadline,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isPriority: isPriority ?? this.isPriority,
      needsHelp: needsHelp ?? this.needsHelp,
      notes: notes ?? this.notes,
      relatedTaskIds: relatedTaskIds ?? this.relatedTaskIds,
    );
  }
}

class CreateTaskViewModel extends AsyncNotifier<CreateTaskFormState> {
  @override
  Future<CreateTaskFormState> build() async {
    final repository = ref.read(taskRepositoryProvider);
    final groupName = await repository.getCurrentGroupName();
    final members = await repository.getGroupMembers();
    final projects = await repository.getProjects();
    final candidateTasks = await repository.getTasks();
    return CreateTaskFormState(
      groupName: groupName,
      members: members,
      projects: projects,
      candidateTasks: candidateTasks,
      selectedMember: members.isEmpty ? '' : members.first,
    );
  }

  void updateTitle(String value) => _update((s) => s.copyWith(title: value));

  void updateType(TaskType value) => _update((s) => s.copyWith(type: value));

  void updateSelectedMember(String value) =>
      _update((s) => s.copyWith(selectedMember: value));

  void updateSelectedProject(String value) =>
      _update((s) => s.copyWith(selectedProject: value));

  void updateDeadline(DateTime value) =>
      _update((s) => s.copyWith(deadline: value));

  void updateStartTime(TimeOfDay value) =>
      _update((s) => s.copyWith(startTime: value));

  void updateEndTime(TimeOfDay value) =>
      _update((s) => s.copyWith(endTime: value));

  void updateIsPriority(bool value) =>
      _update((s) => s.copyWith(isPriority: value));

  void updateNeedsHelp(bool value) =>
      _update((s) => s.copyWith(needsHelp: value));

  void updateNotes(String value) => _update((s) => s.copyWith(notes: value));

  void toggleRelatedTask(String taskId) {
    final current = state.value;
    if (current == null) return;
    final relatedTaskIds = Set<String>.from(current.relatedTaskIds);
    if (!relatedTaskIds.add(taskId)) {
      relatedTaskIds.remove(taskId);
    }
    state = AsyncData(current.copyWith(relatedTaskIds: relatedTaskIds));
  }

  void _update(CreateTaskFormState Function(CreateTaskFormState) update) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(update(current));
  }

  Future<void> submit() async {
    final current = state.value;
    if (current == null || !current.canSubmit) return;
    var deadline = current.deadline!;
    if (current.startTime != null) {
      deadline = DateTime(
        deadline.year,
        deadline.month,
        deadline.day,
        current.startTime!.hour,
        current.startTime!.minute,
      );
    }
    final task = Task(
      id: '',
      title: current.title,
      description: current.notes,
      type: current.type,
      status: TaskStatus.pending,
      groupName: current.groupName,
      assignees: [current.selectedMember],
      deadline: deadline,
      isMine: true,
      isPriority: current.isPriority,
      needsHelp: current.needsHelp,
      notes: current.notes,
      projectName: current.selectedProject,
      relatedTaskIds: current.relatedTaskIds.toList(),
    );
    await ref.read(taskRepositoryProvider).createTask(task);
    ref.invalidate(tasksViewModelProvider);
  }
}
