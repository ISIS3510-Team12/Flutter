class UserProfile {
  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.role,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String role;

  String get fullName => '$firstName $lastName';

  String get initial => firstName.isEmpty ? '' : firstName[0].toUpperCase();

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? role,
  }) {
    return UserProfile(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}
