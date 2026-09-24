import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/auth/auth_repository.dart';

class AuthViewModel extends AsyncNotifier<void> {
  AuthViewModel(this._authRepository);

  final Provider<AuthRepository> _authRepository;

  AuthRepository get repository => ref.watch(_authRepository);

  @override
  FutureOr<void> build() {}

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.signIn(email: email, password: password);
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.signOut();
    });
  }
}



