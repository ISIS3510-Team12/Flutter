class GroupUser {
  final String userId;
  final String firstName;
  final String lastName;

  const GroupUser({
    required this.userId,
    required this.firstName,
    required this.lastName,
  });

  factory GroupUser.fromJson(Map<String, dynamic> json) {
    return GroupUser(
      userId: json['user_id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
    );
  }
}