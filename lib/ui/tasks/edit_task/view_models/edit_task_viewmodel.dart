import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/groups/group_repository_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/project/project_repository_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/project/project.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_member.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/ui/calendar/view_models/calendar_view_model_provider.dart';
import 'package:team12_flutter_juggle/ui/home/view_models/home_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_overview_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/view_task/view_models/view_task_viewmodel_provider.dart';

class EditTaskFormState {
  const EditTaskFormState({
    required this.task,
    required this.group,
    required this.projectOptions,
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
  final TaskGroup? group;
  final List<Project> projectOptions;
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

  List<String> get projects =>
      projectOptions.map((project) => project.name).toList();

  String? get lockedMemberId => task.ownerId;

  int? get selectedProjectId => projectOptions
      .where((project) => project.name == selectedProject)
      .map((project) => project.id)
      .firstOrNull;

  EditTaskFormState copyWith({
    String? selectedProject,
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
      group: group,
      projectOptions: projectOptions,
      selectedProject: selectedProject ?? this.selectedProject,
      members: members,
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
    final groups = await ref.watch(groupRepositoryProvider).getGroups();
    TaskGroup? group;
    for (final candidate in groups) {
      if (candidate.id == task.groupId) group = candidate;
    }
    group ??= groups.isEmpty ? null : groups.first;
    final projects = group == null
        ? <Project>[]
        : await ref.watch(projectRepositoryProvider).getGroupProjects(group.id);
    final me = (await currentUser)!;
    final members = membersWithYou(group, me);
    return EditTaskFormState(
      task: task,
      group: group,
      projectOptions: projects,
      selectedProject: projects
          .where((project) => project.id == task.projectId)
          .map((project) => project.name)
          .firstOrNull,
      members: members,
      type: task.type,
      selectedMemberIds: {...task.assigneeIds, ?task.ownerId},
      deadline: task.deadline,
      time: TimeOfDay.fromDateTime(task.deadline),
      isPriority: task.isPriority,
      needsHelp: task.needsHelp,
      currentPhoto: photo,
    );
  }

  void updateSelectedProject(String value) =>
      _update((s) => s.copyWith(selectedProject: value));

  void updateType(TaskType value) => _update((s) => s.copyWith(type: value));

  void toggleMember(String memberId) {
    final current = state.value;
    if (current == null) return;
    if (memberId == current.lockedMemberId) return;
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
      projectId: current.selectedProjectId,
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
        ref.invalidate(calendarViewModelProvider);
        ref.invalidate(homeViewModelProvider);
        ref.invalidate(viewTaskViewModelProvider(taskId));
      }
    }
  }
}
