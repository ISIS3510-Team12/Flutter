import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:team12_flutter_juggle/ui/core/utils/auth_exceptions.dart';
import 'package:team12_flutter_juggle/ui/core/utils/format_user.dart';


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

  Stream<User?> get authState => _firebaseAuth.userChanges();

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException('Failed to sign in: ${e.message}', code: e.code);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(
        '$firstName $lastName'.trim(),
      );
      await createAppUser(firstName: firstName, lastName: lastName);
    } on FirebaseAuthException catch (e) {
      throw AuthException('Failed to sign up: ${e.message}', code: e.code);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        final name = splitDisplayName(userCredential.user?.displayName);
        await createAppUser(
          firstName: name.firstName,
          lastName: name.lastName,
        );
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        'Failed to sign in with Google: ${e.message}',
        code: e.code,
      );
    }
  }

  Future<void> createAppUser({
    required String firstName,
    required String lastName,
  }) async {
    try {
      await _dio.post(
        '/users/create_user',
        data: {'first_name': firstName, 'last_name': lastName},
      );
    } on DioException catch (e) {
      throw AuthException(
        'Failed to create user profile: ${e.message}',
        code: e.response?.statusCode?.toString(),
      );
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

}
