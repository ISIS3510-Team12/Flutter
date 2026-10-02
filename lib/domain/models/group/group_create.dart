class GroupCreate {
  final String name;
  final String description;

  const GroupCreate({
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}