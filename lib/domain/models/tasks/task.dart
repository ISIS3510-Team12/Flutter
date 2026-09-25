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
    required this.notes,
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
  final String notes;

  String get assigneeName => assignees.isEmpty ? '' : assignees.first;

  String get assigneeInitial =>
      assigneeName.isEmpty ? '' : assigneeName[0].toUpperCase();
}
