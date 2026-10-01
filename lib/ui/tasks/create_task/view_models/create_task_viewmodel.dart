import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_viewmodel_provider.dart';

class CreateTaskFormState {
  const CreateTaskFormState({
    required this.groups,
    required this.group,
    required this.members,
    required this.projects,
    required this.candidateTasks,
    this.title = '',
    this.type = TaskType.coding,
    this.selectedMember = '',
    this.selectedProject,
    this.deadline,
    this.time,
    this.isPriority = false,
    this.needsHelp = false,
    this.relatedTaskIds = const {},
    this.relatedQuery = '',
    this.photoPath,
  });

  final List<TaskGroup> groups;
  final TaskGroup? group;
  final List<String> members;
  final List<String> projects;
  final List<Task> candidateTasks;
  final String title;
  final TaskType type;
  final String selectedMember;
  final String? selectedProject;
  final DateTime? deadline;
  final TimeOfDay? time;
  final bool isPriority;
  final bool needsHelp;
  final Set<String> relatedTaskIds;
  final String relatedQuery;
  final String? photoPath;

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

  bool get canSubmit =>
      title.isNotEmpty &&
      selectedMember.isNotEmpty &&
      deadline != null &&
      time != null;

  CreateTaskFormState copyWith({
    TaskGroup? group,
    List<String>? projects,
    bool clearProject = false,
    String? title,
    TaskType? type,
    String? selectedMember,
    String? selectedProject,
    DateTime? deadline,
    TimeOfDay? time,
    bool? isPriority,
    bool? needsHelp,
    Set<String>? relatedTaskIds,
    String? relatedQuery,
    String? photoPath,
  }) {
    return CreateTaskFormState(
      groups: groups,
      group: group ?? this.group,
      members: members,
      projects: projects ?? this.projects,
      candidateTasks: candidateTasks,
      title: title ?? this.title,
      type: type ?? this.type,
      selectedMember: selectedMember ?? this.selectedMember,
      selectedProject: clearProject
          ? null
          : selectedProject ?? this.selectedProject,
      deadline: deadline ?? this.deadline,
      time: time ?? this.time,
      isPriority: isPriority ?? this.isPriority,
      needsHelp: needsHelp ?? this.needsHelp,
      relatedTaskIds: relatedTaskIds ?? this.relatedTaskIds,
      relatedQuery: relatedQuery ?? this.relatedQuery,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}

class CreateTaskViewModel extends AsyncNotifier<CreateTaskFormState> {
  @override
  Future<CreateTaskFormState> build() async {
    final repository = ref.read(taskRepositoryProvider);
    final groups = await repository.getTaskGroups();
    final group = groups.isEmpty ? null : groups.first;
    final members = await repository.getGroupMembers();
    final projects = group == null
        ? <String>[]
        : await repository.getProjects(group);
    final candidateTasks = await repository.getTasks();
    return CreateTaskFormState(
      groups: groups,
      group: group,
      members: members,
      projects: projects,
      candidateTasks: candidateTasks,
      selectedMember: members.isEmpty ? '' : members.first,
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

  void updateTitle(String value) => _update((s) => s.copyWith(title: value));

  void updateType(TaskType value) => _update((s) => s.copyWith(type: value));

  void updateSelectedMember(String value) =>
      _update((s) => s.copyWith(selectedMember: value));

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
    final task = Task(
      id: '',
      title: current.title,
      description: '',
      type: current.type,
      status: TaskStatus.pending,
      groupName: current.groupName,
      assignees: [current.selectedMember],
      deadline: deadline,
      isMine: true,
      isPriority: current.isPriority,
      needsHelp: current.needsHelp,
      projectName: current.selectedProject,
      relatedTaskIds: current.relatedTaskIds.toList(),
    );
    final repository = ref.read(taskRepositoryProvider);
    final created = await repository.createTask(task);
    final photoPath = current.photoPath;
    if (photoPath != null) {
      await repository.uploadTaskPhoto(created.id, photoPath);
    }
    ref.invalidate(tasksViewModelProvider);
  }
}
