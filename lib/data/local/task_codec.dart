import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';

Map<String, dynamic> taskToJson(Task task) => {
  'id': task.id,
  'title': task.title,
  'description': task.description,
  'type': task.type.name,
  'status': task.status.name,
  'groupName': task.groupName,
  'assignees': task.assignees,
  'assigneeIds': task.assigneeIds,
  'deadline': task.deadline.toUtc().toIso8601String(),
  'isMine': task.isMine,
  'isPriority': task.isPriority,
  'needsHelp': task.needsHelp,
  'hasPhoto': task.hasPhoto,
  'groupId': task.groupId,
  'ownerId': task.ownerId,
  'projectId': task.projectId,
  'projectName': task.projectName,
  'relatedTaskIds': task.relatedTaskIds,
  'relatedTasks': [
    for (final related in task.relatedTasks) taskToJson(related),
  ],
};

Task taskFromJson(Map<String, dynamic> json) {
  return Task(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    type: TaskType.values.byName(json['type'] as String),
    status: TaskStatus.values.byName(json['status'] as String),
    groupName: json['groupName'] as String? ?? '',
    assignees: List<String>.from(json['assignees'] as List),
    assigneeIds: List<String>.from(json['assigneeIds'] as List),
    deadline: DateTime.parse(json['deadline'] as String).toLocal(),
    isMine: json['isMine'] as bool,
    isPriority: json['isPriority'] as bool,
    needsHelp: json['needsHelp'] as bool,
    hasPhoto: json['hasPhoto'] as bool? ?? false,
    groupId: json['groupId'] as int?,
    ownerId: json['ownerId'] as String?,
    projectId: json['projectId'] as int?,
    projectName: json['projectName'] as String?,
    relatedTaskIds: List<String>.from(json['relatedTaskIds'] as List),
    relatedTasks: [
      for (final related in json['relatedTasks'] as List)
        taskFromJson(related as Map<String, dynamic>),
    ],
  );
}
