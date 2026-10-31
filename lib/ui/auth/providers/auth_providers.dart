import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/auth/auth_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/auth/app_user.dart';


final authStateProvider = StreamProvider.autoDispose<AppUser?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authState;
});

final currentUserProvider = FutureProvider.autoDispose<AppUser?>((ref) async {
  return ref.watch(authStateProvider.future);
});