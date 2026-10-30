import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/db/app_database_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/auth/auth_repository.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/utils/auth_exceptions.dart';

class AuthViewModel extends AsyncNotifier<void> {
  AuthViewModel(this._repositoryProvider);

  final Provider<AuthRepository> _repositoryProvider;

  AuthRepository get _repository => ref.read(_repositoryProvider);

  @override
  FutureOr<void> build() {}

  Future<void> signIn({required String email, required String password}) =>
      _run(() => _repository.signIn(email: email, password: password));

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) => _run(
    () => _repository.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    ),
  );

  Future<void> signInWithGoogle() => _run(_repository.signInWithGoogle);

  Future<void> signOut() => _run(() async {
    await ref.read(appDatabaseProvider).clearCache();
    await _repository.signOut();
  });

  Future<void> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    try {
      await action();
      if (ref.mounted) state = const AsyncData(null);
    } on AuthCancelledException {
      if (ref.mounted) state = const AsyncData(null);
    } catch (error, stack) {
      if (ref.mounted) state = AsyncError(_mapError(error), stack);
    }
  }

  Object _mapError(Object error) {
    if (error is NetworkAuthException) return error;
    if (!ref.read(isOnlineProvider)) return const NetworkAuthException();
    return error;
  }
}
