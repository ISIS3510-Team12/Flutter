import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:team12_flutter_juggle/data/repositories/auth/auth_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/auth/app_user.dart';
import 'package:team12_flutter_juggle/ui/core/utils/format_user.dart';


final authStateProvider = StreamProvider.autoDispose<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authState;
});

final currentUserProvider = FutureProvider.autoDispose<AppUser?>((ref) async {
  final firebaseUser = await ref.watch(authStateProvider.future);
  if (firebaseUser == null) {
    return null;
  }
  final name = splitDisplayName(firebaseUser.displayName);
  return AppUser(
    userId: firebaseUser.uid,
    email: firebaseUser.email ?? '',
    firstName: name.firstName,
    lastName: name.lastName,
  );
});