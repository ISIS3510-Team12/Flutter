class GroupCreate {
  final String name;
  final String description;
  final List<String> userIds;

  const GroupCreate({
    required this.name,
    required this.description,
    this.userIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'user_ids': userIds,
    };
  }
}