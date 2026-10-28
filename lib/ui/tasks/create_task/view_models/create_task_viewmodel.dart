import 'dart:async';

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
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/selected_task_group_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_overview_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_viewmodel_provider.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_task_viewmodel.freezed.dart';

@freezed
abstract class CreateTaskFormState with _$CreateTaskFormState {
  const CreateTaskFormState._();

  const factory CreateTaskFormState({
    required List<TaskGroup> groups,
    required TaskGroup? group,
    required List<TaskMember> members,
    required List<Project> projectOptions,
    required List<Task> candidateTasks,
    @Default('') String title,
    @Default(TaskType.coding) TaskType type,
    @Default({}) Set<String> selectedMemberIds,
    String? selectedProject,
    DateTime? deadline,
    TimeOfDay? time,
    @Default(false) bool isPriority,
    @Default(false) bool needsHelp,
    @Default({}) Set<String> relatedTaskIds,
    @Default('') String relatedQuery,
    String? photoPath,
  }) = _CreateTaskFormState;

  List<String> get projects =>
      projectOptions.map((project) => project.name).toList();

  int? get selectedProjectId => projectOptions
      .where((project) => project.name == selectedProject)
      .map((project) => project.id)
      .firstOrNull;

  List<Task> get filteredCandidates {
    final query = relatedQuery.trim().toLowerCase();
    return candidateTasks
        .where(
          (task) =>
              task.status != TaskStatus.done &&
              (query.isEmpty || task.title.toLowerCase().contains(query)),
        )
        .toList();
  }

  String get groupName => group?.name ?? 'No group';

  String? get lockedMemberId => members.isEmpty ? null : members.first.id;

  bool get canSubmit =>
      group != null && title.trim().isNotEmpty && deadline != null && time != null;
}

class CreateTaskViewModel extends AsyncNotifier<CreateTaskFormState> {
  @override
  Future<CreateTaskFormState> build() async {
    final repository = ref.watch(taskRepositoryProvider);
    final selectedGroup = ref.read(selectedTaskGroupIdProvider.notifier);
    final currentUser = ref.watch(currentUserProvider.future);
    final groups = await ref.watch(groupRepositoryProvider).getGroups();
    final group = selectedGroup.resolve(groups);
    final me = (await currentUser)!;
    final members = membersWithYou(group, me);
    final projects = group == null
        ? <Project>[]
        : await ref.watch(projectRepositoryProvider).getGroupProjects(group.id);
    final candidateTasks = group == null
        ? <Task>[]
        : await repository.getGroupTasks(group);
    return CreateTaskFormState(
      groups: groups,
      group: group,
      members: members,
      projectOptions: projects,
      candidateTasks: candidateTasks,
      selectedMemberIds: {me.userId},
    );
  }

  Future<void> updateGroup(TaskGroup group) async {
    final current = state.value;
    if (current == null || current.group?.id == group.id) return;
    final repository = ref.read(taskRepositoryProvider);
    final result = await AsyncValue.guard(() async {
      final projects = await ref
          .read(projectRepositoryProvider)
          .getGroupProjects(group.id);
      final candidateTasks = await repository.getGroupTasks(group);
      final you = current.members.first;
      final members = [
        you,
        ...group.members.where((member) => member.id != you.id),
      ];
      final memberIds = members.map((member) => member.id).toSet();
      return current.copyWith(
        group: group,
        projectOptions: projects,
        candidateTasks: candidateTasks,
        relatedTaskIds: const {},
        selectedProject: null,
        members: members,
        selectedMemberIds: current.selectedMemberIds
            .where(memberIds.contains)
            .toSet(),
      );
    });
    if (!ref.mounted) return;
    state = result;
  }

  void updateTitle(String value) => _update((s) => s.copyWith(title: value));

  void updateType(TaskType value) => _update((s) => s.copyWith(type: value));

  void toggleMember(String memberId) {
    final current = state.value;
    if (current == null) return;
    if (memberId == current.lockedMemberId) return;
    final selected = Set<String>.from(current.selectedMemberIds);
    if (!selected.add(memberId)) selected.remove(memberId);
    state = AsyncData(current.copyWith(selectedMemberIds: selected));
  }

  void updateSelectedProject(String value) =>
      _update((s) => s.copyWith(selectedProject: value));

  void updateDeadline(DateTime value) =>
      _update((s) => s.copyWith(deadline: value));

  void updateTime(TimeOfDay value) => _update((s) => s.copyWith(time: value));

  void updateIsPriority(bool value) =>
      _update((s) => s.copyWith(isPriority: value));

  void updateNeedsHelp(bool value) =>
      _update((s) => s.copyWith(needsHelp: value));

  void updatePhotoPath(String value) =>
      _update((s) => s.copyWith(photoPath: value));

  void updateRelatedQuery(String value) =>
      _update((s) => s.copyWith(relatedQuery: value));

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
    final date = current.deadline!;
    final time = current.time!;
    final deadline = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    final selectedMembers = current.members
        .where((member) => current.selectedMemberIds.contains(member.id))
        .toList();
    final task = Task(
      id: '',
      title: current.title.trim(),
      description: '',
      type: current.type,
      status: TaskStatus.pending,
      groupName: current.groupName,
      groupId: current.group?.id,
      assignees: selectedMembers.map((member) => member.name).toList(),
      assigneeIds: selectedMembers.map((member) => member.id).toList(),
      deadline: deadline,
      isMine: true,
      isPriority: current.isPriority,
      needsHelp: current.needsHelp,
      projectId: current.selectedProjectId,
      projectName: current.selectedProject,
      relatedTaskIds: current.relatedTaskIds.toList(),
    );
    final repository = ref.read(taskRepositoryProvider);
    final selectedGroup = ref.read(selectedTaskGroupIdProvider.notifier);
    final created = await repository.createTask(task);
    final group = current.group;
    if (group != null) selectedGroup.select(group.id);
    try {
      final photoPath = current.photoPath;
      if (photoPath != null) {
        await repository.uploadTaskPhoto(created.id, photoPath);
      }
    } finally {
      if (ref.mounted) {
        ref.invalidate(tasksViewModelProvider);
        ref.invalidate(tasksOverviewProvider);
        ref.invalidate(calendarViewModelProvider);
        ref.invalidate(homeViewModelProvider);
      }
    }
  }
}
