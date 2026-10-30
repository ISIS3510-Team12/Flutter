import 'package:firebase_auth/firebase_auth.dart';
import 'package:team12_flutter_juggle/ui/core/utils/format_user.dart';

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

  String get fullName => '$firstName $lastName';

  String get initial => firstName.isEmpty ? '' : firstName[0].toUpperCase();

  factory AppUser.fromFirebase(User user) {
    final name = splitDisplayName(user.displayName);
    return AppUser(
      userId: user.uid,
      email: user.email ?? '',
      firstName: name.firstName,
      lastName: name.lastName,
    );
  }
}
