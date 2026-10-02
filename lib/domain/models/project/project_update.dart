class ProjectUpdate {
  final String? name;
  final String? description;
  final DateTime? deadline;

  const ProjectUpdate({
    this.name,
    this.description,
    this.deadline,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (deadline != null)
        'deadline': deadline!.toUtc().toIso8601String(),
    };
  }
}