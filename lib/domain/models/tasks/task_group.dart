class TaskGroup {
  const TaskGroup({
    required this.id,
    required this.name,
    required this.pendingCount,
  });

  final int id;
  final String name;
  final int pendingCount;

  factory TaskGroup.fromJson(Map<String, dynamic> json) {
    return TaskGroup(
      id: json['id'] as int,
      name: json['name'] as String,
      pendingCount: json['pending_task_count'] as int? ?? 0,
    );
  }
}
