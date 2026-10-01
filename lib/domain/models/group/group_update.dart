class GroupUpdate {
  final String name;
  final String description;
  final List<String> userIds;

  const GroupUpdate({
    required this.name,
    required this.description,
    required this.userIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'user_ids': userIds,
    };
  }

  
}