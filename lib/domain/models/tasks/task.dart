enum TaskType { coding, design, writing, research }

enum TaskStatus { pending, inProgress, done }

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.groupName,
    required this.assignees,
    required this.deadline,
    required this.isMine,
    required this.isPriority,
    required this.needsHelp,
    this.hasPhoto = false,
    this.groupId,
    this.projectId,
    this.projectName,
    this.relatedTaskIds = const [],
  });

  final String id;
  final String title;
  final String description;
  final TaskType type;
  final TaskStatus status;
  final String groupName;
  final List<String> assignees;
  final DateTime deadline;
  final bool isMine;
  final bool isPriority;
  final bool needsHelp;
  final bool hasPhoto;
  final int? groupId;
  final int? projectId;
  final String? projectName;
  final List<String> relatedTaskIds;

  String get assigneeName => assignees.isEmpty ? '' : assignees.first;

  String get assigneeInitial =>
      assigneeName.isEmpty ? '' : assigneeName[0].toUpperCase();

  Task copyWith({
    String? title,
    String? description,
    TaskType? type,
    TaskStatus? status,
    String? groupName,
    List<String>? assignees,
    DateTime? deadline,
    bool? isMine,
    bool? isPriority,
    bool? needsHelp,
    bool? hasPhoto,
    int? projectId,
    String? projectName,
    List<String>? relatedTaskIds,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      groupName: groupName ?? this.groupName,
      assignees: assignees ?? this.assignees,
      deadline: deadline ?? this.deadline,
      isMine: isMine ?? this.isMine,
      isPriority: isPriority ?? this.isPriority,
      needsHelp: needsHelp ?? this.needsHelp,
      hasPhoto: hasPhoto ?? this.hasPhoto,
      groupId: groupId,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      relatedTaskIds: relatedTaskIds ?? this.relatedTaskIds,
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    required String groupName,
    bool isMine = true,
  }) {
    return Task(
      id: json['id'].toString(),
      title: json['title'] as String,
      description: '',
      type: taskTypeFromJson(json['task_type'] as String),
      status: taskStatusFromJson(json['status'] as String),
      groupName: groupName,
      assignees: const [],
      deadline: json['deadline'] != null
          ? _parseServerDate(json['deadline'] as String)
          : DateTime.now(),
      isMine: isMine,
      isPriority: json['is_priority'] as bool? ?? false,
      needsHelp: json['needs_help'] as bool? ?? false,
      hasPhoto: json['has_photo'] as bool? ?? false,
      groupId: json['group_id'] as int?,
      projectId: json['project_id'] as int?,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'title': title,
      'task_type': type.name,
      'is_priority': isPriority,
      'needs_help': needsHelp,
      'deadline': deadline.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() => toCreateJson();
}

DateTime _parseServerDate(String value) {
  final parsed = DateTime.parse(value);
  if (parsed.isUtc) return parsed.toLocal();
  return DateTime.utc(
    parsed.year,
    parsed.month,
    parsed.day,
    parsed.hour,
    parsed.minute,
    parsed.second,
  ).toLocal();
}

TaskType taskTypeFromJson(String value) {
  return TaskType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => TaskType.coding,
  );
}

TaskStatus taskStatusFromJson(String value) {
  switch (value) {
    case 'not started':
      return TaskStatus.pending;
    case 'in_progress':
      return TaskStatus.inProgress;
    case 'completed':
      return TaskStatus.done;
    default:
      return TaskStatus.pending;
  }
}

String taskStatusToJson(TaskStatus status) {
  switch (status) {
    case TaskStatus.pending:
      return 'not started';
    case TaskStatus.inProgress:
      return 'in_progress';
    case TaskStatus.done:
      return 'completed';
  }
}
