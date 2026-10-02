class ProjectCreate {
  final String name;
  final String description;
  final DateTime deadline;
  final int groupId;

  const ProjectCreate({
    required this.name,
    required this.description,
    required this.deadline,
    required this.groupId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'deadline': deadline.toUtc().toIso8601String(),
      'group_id': groupId,
    };
  }
}