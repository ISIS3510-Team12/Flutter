import 'package:team12_flutter_juggle/ui/core/network/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/core/app/service_locator.dart';
import './auth_repository.dart';

final authRepositoryProvider = Provider((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final dio = ref.watch(dioProvider);
  final googleSignIn = ref.watch(googleSignInProvider);
  return AuthRepository(firebaseAuth: firebaseAuth, dio: dio, googleSignIn: googleSignIn);
});

