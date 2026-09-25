import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:team12_flutter_juggle/domain/models/auth/app_user.dart';

class AuthRepository {
  AuthRepository({
    required FirebaseAuth firebaseAuth,
    required Dio dio,
    required GoogleSignIn googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _dio = dio,
       _googleSignIn = googleSignIn;

  final FirebaseAuth _firebaseAuth;
  final Dio _dio;
  final GoogleSignIn _googleSignIn;

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
          data: {'first_name': firstName, 'last_name': lastName},
        );
      } catch (e) {
        throw Exception('Failed to create user profile: $e');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to sign up: ${e.message}');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      GoogleSignInAccount? gUser;

      gUser = await _googleSignIn.authenticate();

      final gAuth = gUser.authentication;

      final credential = GoogleAuthProvider.credential(idToken: gAuth.idToken);

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      try {
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          await _dio.post(
            '/users/create_user',
            data: {
              'first_name': userCredential.user?.displayName?.split(' ').first ?? '',
              'last_name': userCredential.user?.displayName?.split(' ').last ?? '',
            },
          );
        }
      } catch (e) {
        throw Exception('Failed to create user profile: $e');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception('Failed to sign in with Google: ${e.message}');
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
