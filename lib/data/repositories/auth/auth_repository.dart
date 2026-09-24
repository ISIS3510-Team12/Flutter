import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:team12_flutter_juggle/domain/models/auth/app_user.dart';

class AuthRepository {
  AuthRepository({required FirebaseAuth firebaseAuth, required Dio dio})
    : _firebaseAuth = firebaseAuth,
      _dio = dio;

  final FirebaseAuth _firebaseAuth;
  final Dio _dio;

  Stream<User?> get authState => _firebaseAuth.authStateChanges();

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to sign in: ${e.message}');
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      try {
        await _dio.post(
          '/users/create_user',
          data: {
            'first_name': firstName,
            'last_name': lastName,
          },
        );
      } catch (e) {
        throw Exception('Failed to create user profile: $e');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to sign up: ${e.message}');
    }
  }

  Future<AppUser> getCurrentUser() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/users/current_user',
    );
    return AppUser.fromJson(response.data!);
  }

  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }
}

