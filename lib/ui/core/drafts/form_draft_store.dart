import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';

@immutable
final class GroupDraft {
  const GroupDraft({
    this.name = '',
    this.description = '',
    this.selectedUserIds = const {},
    this.searchQuery = '',
  });

  final String name;
  final String description;
  final Set<String> selectedUserIds;
  final String searchQuery;
}

@immutable
final class ProjectDraft {
  const ProjectDraft({this.name = '', this.description = '', this.deadline});

  final String name;
  final String description;
  final DateTime? deadline;
}

@immutable
final class TaskDraft {
  const TaskDraft({
    this.title = '',
    this.type = TaskType.coding,
    this.selectedMemberIds = const {},
    this.projectId,
    this.deadline,
    this.time,
    this.isPriority = false,
    this.needsHelp = false,
    this.relatedTaskIds = const {},
    this.relatedQuery = '',
    this.photoPath,
  });

  final String title;
  final TaskType type;
  final Set<String> selectedMemberIds;
  final int? projectId;
  final DateTime? deadline;
  final TimeOfDay? time;
  final bool isPriority;
  final bool needsHelp;
  final Set<String> relatedTaskIds;
  final String relatedQuery;
  final String? photoPath;
}

final class FormDraftStore {
  String? _userId;
  GroupDraft? _group;
  final Map<int, ProjectDraft> _projects = {};
  final Map<int, TaskDraft> _tasks = {};
  int? _lastTaskGroupId;

  void switchUser(String? userId) {
    if (userId == _userId) return;
    _userId = userId;
    _group = null;
    _projects.clear();
    _tasks.clear();
    _lastTaskGroupId = null;
  }

  GroupDraft? get groupDraft => _group;

  void saveGroupDraft(GroupDraft draft) => _group = draft;

  void clearGroupDraft() => _group = null;

  ProjectDraft? projectDraft(int groupId) => _projects[groupId];

  void saveProjectDraft(int groupId, ProjectDraft draft) =>
      _projects[groupId] = draft;

  void clearProjectDraft(int groupId) => _projects.remove(groupId);

  int? get lastTaskGroupId => _lastTaskGroupId;

  TaskDraft? taskDraft(int groupId) => _tasks[groupId];

  void saveTaskDraft(int groupId, TaskDraft draft) {
    _tasks[groupId] = draft;
    _lastTaskGroupId = groupId;
  }

  void clearTaskDraft(int groupId) => _tasks.remove(groupId);
}

final formDraftStoreProvider = Provider<FormDraftStore>((ref) {
  final store = FormDraftStore();
  ref.listen(
    authStateProvider.select((auth) => auth.value?.userId),
    (_, userId) => store.switchUser(userId),
    fireImmediately: true,
  );
  return store;
});
