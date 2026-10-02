class Project {
  final int id;
  final String name;
  final String description;
  final DateTime deadline;
  final int groupId;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.deadline,
    required this.groupId,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      groupId: json['group_id'] as int,
    );
  }
}