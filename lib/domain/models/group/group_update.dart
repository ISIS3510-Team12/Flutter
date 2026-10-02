class GroupUpdate {
  final String name;
  final String description;

  const GroupUpdate({
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