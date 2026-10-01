import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_member.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_overview_provider.dart';
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
    required this.selectedMemberIds,
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
  final List<TaskMember> members;
  final TaskType type;
  final Set<String> selectedMemberIds;
  final DateTime deadline;
  final TimeOfDay time;
  final bool isPriority;
  final bool needsHelp;
  final Uint8List? currentPhoto;
  final String? newPhotoPath;

  EditTaskFormState copyWith({
    TaskGroup? group,
    List<TaskMember>? members,
    List<String>? projects,
    String? selectedProject,
    bool clearProject = false,
    TaskType? type,
    Set<String>? selectedMemberIds,
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
      members: members ?? this.members,
      type: type ?? this.type,
      selectedMemberIds: selectedMemberIds ?? this.selectedMemberIds,
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
    final repository = ref.watch(taskRepositoryProvider);
    final currentUser = ref.watch(currentUserProvider.future);
    final task = await repository.getTask(taskId);
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
    final me = (await currentUser)!;
    final members = membersWithYou(group, me);
    return EditTaskFormState(
      task: task,
      groups: groups,
      group: group,
      projects: projects,
      selectedProject: repository.projectNameFor(task.projectId),
      members: members,
      type: task.type,
      selectedMemberIds: task.assigneeIds.toSet(),
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
    final repository = ref.read(taskRepositoryProvider);
    final result = await AsyncValue.guard(() async {
      final projects = await repository.getProjects(group);
      final you = current.members.first;
      final members = [
        you,
        ...group.members.where((member) => member.id != you.id),
      ];
      final memberIds = members.map((member) => member.id).toSet();
      return current.copyWith(
        group: group,
        projects: projects,
        clearProject: true,
        members: members,
        selectedMemberIds: current.selectedMemberIds
            .where(memberIds.contains)
            .toSet(),
      );
    });
    if (!ref.mounted) return;
    state = result;
  }

  void updateSelectedProject(String value) =>
      _update((s) => s.copyWith(selectedProject: value));

  void updateType(TaskType value) => _update((s) => s.copyWith(type: value));

  void toggleMember(String memberId) {
    final current = state.value;
    if (current == null) return;
    final selected = Set<String>.from(current.selectedMemberIds);
    if (!selected.add(memberId)) selected.remove(memberId);
    state = AsyncData(current.copyWith(selectedMemberIds: selected));
  }

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
    final selectedMembers = current.members
        .where((member) => current.selectedMemberIds.contains(member.id))
        .toList();
    final date = current.deadline;
    final updated = current.task.copyWith(
      type: current.type,
      assignees: selectedMembers.map((member) => member.name).toList(),
      assigneeIds: selectedMembers.map((member) => member.id).toList(),
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
    try {
      final photoPath = current.newPhotoPath;
      if (photoPath != null) {
        await repository.uploadTaskPhoto(taskId, photoPath);
      }
    } finally {
      if (ref.mounted) {
        ref.invalidate(tasksViewModelProvider);
        ref.invalidate(tasksOverviewProvider);
        ref.invalidate(viewTaskViewModelProvider(taskId));
      }
    }
  }
}
