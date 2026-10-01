import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/view_task/view_models/view_task_viewmodel_provider.dart';

class EditTaskFormState {
  const EditTaskFormState({
    required this.task,
    required this.groups,
    required this.group,
    required this.projects,
    required this.selectedProject,
    required this.members,
    required this.type,
    required this.selectedMember,
    required this.deadline,
    required this.time,
    required this.isPriority,
    required this.needsHelp,
    required this.currentPhoto,
    this.newPhotoPath,
  });

  final Task task;
  final List<TaskGroup> groups;
  final TaskGroup? group;
  final List<String> projects;
  final String? selectedProject;
  final List<String> members;
  final TaskType type;
  final String selectedMember;
  final DateTime deadline;
  final TimeOfDay time;
  final bool isPriority;
  final bool needsHelp;
  final Uint8List? currentPhoto;
  final String? newPhotoPath;

  EditTaskFormState copyWith({
    TaskGroup? group,
    List<String>? projects,
    String? selectedProject,
    bool clearProject = false,
    TaskType? type,
    String? selectedMember,
    DateTime? deadline,
    TimeOfDay? time,
    bool? isPriority,
    bool? needsHelp,
    String? newPhotoPath,
  }) {
    return EditTaskFormState(
      task: task,
      groups: groups,
      group: group ?? this.group,
      projects: projects ?? this.projects,
      selectedProject: clearProject
          ? null
          : selectedProject ?? this.selectedProject,
      members: members,
      type: type ?? this.type,
      selectedMember: selectedMember ?? this.selectedMember,
      deadline: deadline ?? this.deadline,
      time: time ?? this.time,
      isPriority: isPriority ?? this.isPriority,
      needsHelp: needsHelp ?? this.needsHelp,
      currentPhoto: currentPhoto,
      newPhotoPath: newPhotoPath ?? this.newPhotoPath,
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
    final photo = task.hasPhoto ? await repository.getTaskPhoto(taskId) : null;
    final groups = await repository.getTaskGroups();
    TaskGroup? group;
    for (final candidate in groups) {
      if (candidate.id == task.groupId) group = candidate;
    }
    group ??= groups.isEmpty ? null : groups.first;
    final projects = group == null
        ? <String>[]
        : await repository.getProjects(group);
    return EditTaskFormState(
      task: task,
      groups: groups,
      group: group,
      projects: projects,
      selectedProject: repository.projectNameFor(task.projectId),
      members: members,
      type: task.type,
      selectedMember: task.assigneeName,
      deadline: task.deadline,
      time: TimeOfDay.fromDateTime(task.deadline),
      isPriority: task.isPriority,
      needsHelp: task.needsHelp,
      currentPhoto: photo,
    );
  }

  Future<void> updateGroup(TaskGroup group) async {
    final current = state.value;
    if (current == null || current.group?.id == group.id) return;
    final projects = await ref.read(taskRepositoryProvider).getProjects(group);
    state = AsyncData(
      current.copyWith(group: group, projects: projects, clearProject: true),
    );
  }

  void updateSelectedProject(String value) =>
      _update((s) => s.copyWith(selectedProject: value));

  void updateType(TaskType value) => _update((s) => s.copyWith(type: value));

  void updateSelectedMember(String value) =>
      _update((s) => s.copyWith(selectedMember: value));

  void updateDeadline(DateTime value) =>
      _update((s) => s.copyWith(deadline: value));

  void updateTime(TimeOfDay value) => _update((s) => s.copyWith(time: value));

  void updateIsPriority(bool value) =>
      _update((s) => s.copyWith(isPriority: value));

  void updateNeedsHelp(bool value) =>
      _update((s) => s.copyWith(needsHelp: value));

  void updatePhotoPath(String value) =>
      _update((s) => s.copyWith(newPhotoPath: value));

  void _update(EditTaskFormState Function(EditTaskFormState) update) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(update(current));
  }

  Future<void> submit() async {
    final current = state.value;
    if (current == null) return;
    final date = current.deadline;
    final updated = current.task.copyWith(
      type: current.type,
      assignees: [current.selectedMember],
      projectName: current.selectedProject,
      deadline: DateTime(
        date.year,
        date.month,
        date.day,
        current.time.hour,
        current.time.minute,
      ),
      isPriority: current.isPriority,
      needsHelp: current.needsHelp,
    );
    final repository = ref.read(taskRepositoryProvider);
    await repository.updateTask(updated);
    final photoPath = current.newPhotoPath;
    if (photoPath != null) {
      await repository.uploadTaskPhoto(taskId, photoPath);
    }
    ref.invalidate(tasksViewModelProvider);
    ref.invalidate(viewTaskViewModelProvider(taskId));
  }
}
