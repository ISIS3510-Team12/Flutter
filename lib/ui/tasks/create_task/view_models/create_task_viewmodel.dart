import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/db/daos/groups/groups_cache_dao.dart';
import 'package:team12_flutter_juggle/data/db/daos/groups/groups_cache_dao_provider.dart';
import 'package:team12_flutter_juggle/data/db/daos/projects/projects_cache_dao.dart';
import 'package:team12_flutter_juggle/data/db/daos/projects/projects_cache_dao_provider.dart';
import 'package:team12_flutter_juggle/data/db/daos/tasks/tasks_cache_dao.dart';
import 'package:team12_flutter_juggle/data/db/daos/tasks/tasks_cache_dao_provider.dart';
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
import 'package:team12_flutter_juggle/ui/home/view_models/next_task_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/drafts/form_draft_store.dart';
import 'package:team12_flutter_juggle/ui/core/network/network_first.dart';
import 'package:team12_flutter_juggle/ui/core/network/parallel_wait.dart';
import 'package:team12_flutter_juggle/ui/core/sync/sync_providers.dart';
import 'package:team12_flutter_juggle/ui/core/utils/network_exceptions.dart';
import 'package:team12_flutter_juggle/ui/core/utils/photo_upload_exception.dart';
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
    @Default(false) bool fromCache,
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
      group != null &&
      title.trim().isNotEmpty &&
      deadline != null &&
      time != null;

  TaskDraft toDraft() => TaskDraft(
    title: title,
    type: type,
    selectedMemberIds: selectedMemberIds,
    projectId: selectedProjectId,
    deadline: deadline,
    time: time,
    isPriority: isPriority,
    needsHelp: needsHelp,
    relatedTaskIds: relatedTaskIds,
    relatedQuery: relatedQuery,
    photoPath: photoPath,
  );

  CreateTaskFormState withDraft(TaskDraft draft, {required bool keepPhoto}) {
    final memberIds = members.map((member) => member.id).toSet();
    final taskIds = candidateTasks.map((task) => task.id).toSet();
    return copyWith(
      title: draft.title,
      type: draft.type,
      selectedMemberIds: {
        ?lockedMemberId,
        ...draft.selectedMemberIds.where(memberIds.contains),
      },
      selectedProject: projectOptions
          .where((project) => project.id == draft.projectId)
          .map((project) => project.name)
          .firstOrNull,
      deadline: draft.deadline,
      time: draft.time,
      isPriority: draft.isPriority,
      needsHelp: draft.needsHelp,
      relatedTaskIds: draft.relatedTaskIds.where(taskIds.contains).toSet(),
      relatedQuery: draft.relatedQuery,
      photoPath: keepPhoto ? draft.photoPath : null,
    );
  }
}

enum CreateTaskResult { created, queued, failed }

typedef _GroupData = ({
  List<Project> projects,
  List<Task> candidates,
  bool fromCache,
});

class CreateTaskViewModel extends AsyncNotifier<CreateTaskFormState> {
  String? _userId;

  bool _isOnline() => ref.read(isOnlineProvider);

  GroupsCacheDao get _groupsCache => ref.read(groupsCacheDaoProvider);

  ProjectsCacheDao get _projectsCache => ref.read(projectsCacheDaoProvider);

  TasksCacheDao get _tasksCache => ref.read(tasksCacheDaoProvider);

  FormDraftStore get _drafts => ref.read(formDraftStoreProvider);

  TaskDraft? _draftFor(TaskGroup? group) =>
      group == null ? null : _drafts.taskDraft(group.id);

  void _clearDraftFor(TaskGroup? group) {
    if (group != null) _drafts.clearTaskDraft(group.id);
  }

  Future<CreateTaskFormState> _applyDraft(
    CreateTaskFormState base,
    TaskDraft draft,
  ) async {
    final photoPath = draft.photoPath;
    final photoExists = photoPath != null && await File(photoPath).exists();
    return base.withDraft(draft, keepPhoto: photoExists);
  }

  void _emit(CreateTaskFormState next) {
    state = AsyncData(next);
    if (next.group case final group?) {
      _drafts.saveTaskDraft(group.id, next.toDraft());
    }
  }

  Future<_GroupData> _groupData(String userId, TaskGroup group) async {
    final online = _isOnline();
    final (projects, candidates) = await waitBoth(
      networkFirst(
        isOnline: online,
        fetch: () =>
            ref.read(projectRepositoryProvider).getGroupProjects(group.id),
        save: (projects) =>
            _projectsCache.replaceForGroup(userId, group.id, projects),
        fallback: () => _projectsCache.findForGroup(userId, group.id),
      ),
      networkFirst<List<Task>>(
        isOnline: online,
        fetch: () => ref.read(taskRepositoryProvider).getGroupTasks(group),
        save: (tasks) => _tasksCache.replaceForGroup(userId, group.id, tasks),
        fallback: () async =>
            await _tasksCache.findPendingForGroup(userId, group.id) ?? [],
      ),
    );
    return (
      projects: projects.value,
      candidates: candidates.value,
      fromCache: projects.fromCache || candidates.fromCache,
    );
  }

  @override
  Future<CreateTaskFormState> build() async {
    final selectedGroup = ref.read(selectedTaskGroupIdProvider.notifier);
    final groupRepository = ref.watch(groupRepositoryProvider);
    final me = (await ref.watch(currentUserProvider.future))!;
    final userId = _userId = me.userId;
    final groups = await networkFirst(
      isOnline: _isOnline(),
      fetch: groupRepository.getGroups,
      save: (groups) => _groupsCache.replaceForUser(userId, groups),
      fallback: () => _groupsCache.findAll(userId),
    );
    final lastGroupId = _drafts.lastTaskGroupId;
    final group = groups.value
            .where((group) => group.id == lastGroupId)
            .firstOrNull ??
        selectedGroup.resolve(groups.value);
    final members = membersWithYou(group, me);
    final data = group == null ? null : await _groupData(userId, group);
    final loaded = CreateTaskFormState(
      groups: groups.value,
      group: group,
      members: members,
      projectOptions: data?.projects ?? const [],
      candidateTasks: data?.candidates ?? const [],
      selectedMemberIds: {me.userId},
      fromCache: groups.fromCache || (data?.fromCache ?? false),
    );
    final draft = _draftFor(group);
    return draft == null ? loaded : _applyDraft(loaded, draft);
  }

  Future<bool> updateGroup(TaskGroup group) async {
    final current = state.value;
    final userId = _userId;
    if (current == null || current.group?.id == group.id) return true;
    if (userId == null) return false;
    try {
      final data = await _groupData(userId, group);
      if (!ref.mounted) return true;
      final moved = _moveToGroup(current, group, data);
      final draft = _draftFor(group);
      if (draft == null) {
        _clearDraftFor(current.group);
        _emit(moved);
        return true;
      }
      final restored = await _applyDraft(moved, draft);
      if (ref.mounted) _emit(restored);
      return true;
    } catch (_) {
      return false;
    }
  }

  CreateTaskFormState _moveToGroup(
    CreateTaskFormState current,
    TaskGroup group,
    _GroupData data,
  ) {
    final you = current.members.first;
    final members = [
      you,
      ...group.members.where((member) => member.id != you.id),
    ];
    final memberIds = members.map((member) => member.id).toSet();
    return current.copyWith(
      group: group,
      projectOptions: data.projects,
      candidateTasks: data.candidates,
      relatedTaskIds: const {},
      selectedProject: null,
      members: members,
      selectedMemberIds: current.selectedMemberIds
          .where(memberIds.contains)
          .toSet(),
      fromCache: data.fromCache,
    );
  }

  void updateTitle(String value) => _update((s) => s.copyWith(title: value));

  void updateType(TaskType value) => _update((s) => s.copyWith(type: value));

  void toggleMember(String memberId) {
    final current = state.value;
    if (current == null) return;
    if (memberId == current.lockedMemberId) return;
    final selected = Set<String>.from(current.selectedMemberIds);
    if (!selected.add(memberId)) selected.remove(memberId);
    _emit(current.copyWith(selectedMemberIds: selected));
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
    _emit(current.copyWith(relatedTaskIds: relatedTaskIds));
  }

  void _update(CreateTaskFormState Function(CreateTaskFormState) update) {
    final current = state.value;
    if (current == null) return;
    _emit(update(current));
  }

  void resetForm() {
    final current = state.value;
    if (current == null) return;

    final lockedMemberId = current.lockedMemberId;

    _clearDraftFor(current.group);
    state = AsyncData(
      CreateTaskFormState(
        groups: current.groups,
        group: current.group,
        members: current.members,
        projectOptions: current.projectOptions,
        candidateTasks: current.candidateTasks,
        selectedMemberIds: {?lockedMemberId},
        fromCache: current.fromCache,
      ),
    );
  }

  Future<CreateTaskResult> submit() async {
    final current = state.value;
    final group = current?.group;
    if (current == null || group == null || !current.canSubmit) {
      return CreateTaskResult.failed;
    }
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
      groupId: group.id,
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
    final sync = ref.read(outboxSyncServiceProvider);
    final drafts = _drafts;
    if (!_isOnline()) {
      await sync.enqueueCreate(task, photoPath: current.photoPath);
      drafts.clearTaskDraft(group.id);
      return CreateTaskResult.queued;
    }
    final Task created;
    try {
      created = await repository.createTask(task);
    } catch (error) {
      if (!isOfflineFailure(error)) return CreateTaskResult.failed;
      await sync.enqueueCreate(
        task,
        photoPath: current.photoPath,
        verifyFirst: true,
      );
      drafts.clearTaskDraft(group.id);
      return CreateTaskResult.queued;
    }
    drafts.clearTaskDraft(group.id);
    selectedGroup.select(group.id);
    try {
      final photoPath = current.photoPath;
      if (photoPath != null) {
        await repository.uploadTaskPhoto(created.id, photoPath);
      }
    } on Exception catch (error) {
      if (isOfflineFailure(error)) {
        throw const PhotoUploadException(
          'The photo could not be uploaded. Check your connection.',
        );
      }
      rethrow;
    } finally {
      if (ref.mounted) {
        ref.invalidate(tasksViewModelProvider);
        ref.invalidate(tasksOverviewProvider);
        ref.invalidate(calendarViewModelProvider);
        ref.invalidate(homeViewModelProvider);
        ref.read(nextTaskViewModelProvider.notifier).refresh();
      }
    }
    return CreateTaskResult.created;
  }
}
