class AppUser {
  const AppUser({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      userId: json['user_id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String
    );
  }
}
