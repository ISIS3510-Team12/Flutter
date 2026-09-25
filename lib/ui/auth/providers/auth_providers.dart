import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:team12_flutter_juggle/data/repositories/auth/auth_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/auth/app_user.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authState;
});

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final firebaseUser = await ref.watch(authStateProvider.future);
  if (firebaseUser == null) {
    return null;
  }
  return ref.watch(authRepositoryProvider).getCurrentUser();
});