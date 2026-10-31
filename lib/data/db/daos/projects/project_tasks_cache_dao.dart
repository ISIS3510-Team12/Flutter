
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:team12_flutter_juggle/data/db/app_database.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_project_tasks.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_project_task_loads.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';

part 'project_tasks_cache_dao.g.dart';

@DriftAccessor(
  tables: [CachedProjectTasks, CachedProjectTaskLoads],
)
class ProjectTasksCacheDao extends DatabaseAccessor<AppDatabase>
    with _$ProjectTasksCacheDaoMixin {
  ProjectTasksCacheDao({required AppDatabase db}) : super(db);

  Future<void> replaceForProject(
    String userId,
    int projectId,
    List<Task> tasks,
  ) {
    return transaction(() async {
      await (delete(cachedProjectTasks)
            ..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.projectId.equals(projectId),
            ))
          .go();

      if (tasks.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(cachedProjectTasks, [
            for (var i = 0; i < tasks.length; i++)
              CachedProjectTasksCompanion.insert(
                userId: userId,
                projectId: projectId,
                taskId: tasks[i].id,
                taskJson: jsonEncode({
                  'position': i,
                  'task': _taskToJson(tasks[i]),
                }),
              ),
          ]);
        });
      }

      await into(cachedProjectTaskLoads).insertOnConflictUpdate(
        CachedProjectTaskLoadsCompanion.insert(
          userId: userId,
          projectId: projectId,
          loadedAtUtcMs: DateTime.now().toUtc().millisecondsSinceEpoch,
        ),
      );
    });
  }

  Future<List<Task>?> findForProject(
    String userId,
    int projectId,
  ) async {
    final load = await (select(cachedProjectTaskLoads)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.projectId.equals(projectId),
          ))
        .getSingleOrNull();

    if (load == null) return null;

    final rows = await (select(cachedProjectTasks)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.projectId.equals(projectId),
          ))
        .get();

    final orderedRows = rows.toList()
      ..sort((a, b) {
        final aPosition =
            (jsonDecode(a.taskJson) as Map<String, dynamic>)['position'] as int;
        final bPosition =
            (jsonDecode(b.taskJson) as Map<String, dynamic>)['position'] as int;
        return aPosition.compareTo(bPosition);
      });

    return orderedRows.map((row) {
      final stored = jsonDecode(row.taskJson) as Map<String, dynamic>;
      return _taskFromJson(stored['task'] as Map<String, dynamic>);
    }).toList();
  }

  Future<bool> isProjectLoaded(String userId, int projectId) async {
    final load = await (select(cachedProjectTaskLoads)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.projectId.equals(projectId),
          ))
        .getSingleOrNull();

    return load != null;
  }

  Map<String, dynamic> _taskToJson(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'type': task.type.name,
      'status': task.status.name,
      'groupName': task.groupName,
      'assignees': task.assignees,
      'deadline': task.deadline.toUtc().toIso8601String(),
      'isMine': task.isMine,
      'isPriority': task.isPriority,
      'needsHelp': task.needsHelp,
      'assigneeIds': task.assigneeIds,
      'hasPhoto': task.hasPhoto,
      'groupId': task.groupId,
      'ownerId': task.ownerId,
      'projectId': task.projectId,
      'projectName': task.projectName,
      'relatedTaskIds': task.relatedTaskIds,
      'relatedTasks': task.relatedTasks.map(_taskToJson).toList(),
    };
  }

  Task _taskFromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: TaskType.values.byName(json['type'] as String),
      status: TaskStatus.values.byName(json['status'] as String),
      groupName: json['groupName'] as String,
      assignees: (json['assignees'] as List<dynamic>).cast<String>(),
      deadline: DateTime.parse(json['deadline'] as String).toLocal(),
      isMine: json['isMine'] as bool,
      isPriority: json['isPriority'] as bool,
      needsHelp: json['needsHelp'] as bool,
      assigneeIds: (json['assigneeIds'] as List<dynamic>).cast<String>(),
      hasPhoto: json['hasPhoto'] as bool,
      groupId: json['groupId'] as int?,
      ownerId: json['ownerId'] as String?,
      projectId: json['projectId'] as int?,
      projectName: json['projectName'] as String?,
      relatedTaskIds:
          (json['relatedTaskIds'] as List<dynamic>).cast<String>(),
      relatedTasks: (json['relatedTasks'] as List<dynamic>)
          .map(
            (task) => _taskFromJson(task as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
