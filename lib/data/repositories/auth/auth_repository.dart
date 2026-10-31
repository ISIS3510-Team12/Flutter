import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:team12_flutter_juggle/domain/models/auth/app_user.dart';
import 'package:team12_flutter_juggle/ui/core/utils/auth_exceptions.dart';

const signInTimeout = Duration(seconds: 20);
const googleSignInTimeout = Duration(seconds: 60);

class AuthRepository {
  AuthRepository({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _googleSignIn = googleSignIn;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  Future<void>? _pendingSignUp;

  Stream<AppUser?> get authState => _firebaseAuth
      .userChanges()
      .asyncMap((user) async {
        final pending = _pendingSignUp;
        if (pending == null) return user;
        await pending;
        return _firebaseAuth.currentUser;
      })
      .map((user) => user == null ? null : AppUser.fromFirebase(user));

  Future<void> signIn({required String email, required String password}) =>
      _guard('sign in', () async {
        try {
          await _firebaseAuth
              .signInWithEmailAndPassword(email: email, password: password)
              .timeout(signInTimeout);
        } on TimeoutException {
          throw const AuthTimeoutException();
        }
      });

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final signUp = _guard('sign up', () async {
      final UserCredential credential;
      try {
        credential = await _firebaseAuth
            .createUserWithEmailAndPassword(email: email, password: password)
            .timeout(signInTimeout);
      } on TimeoutException {
        throw const AuthTimeoutException();
      }
      final user = credential.user;
      if (user == null) return;
      await user.updateDisplayName('$firstName $lastName'.trim());
      await user.getIdToken(true);
    });

    _pendingSignUp = signUp.catchError((Object _) {});
    try {
      await signUp;
    } finally {
      _pendingSignUp = null;
    }
  }

  Future<void> signInWithGoogle() => _guard('sign in with Google', () async {
    try {
      await _googleSignIn.signOut();
      final account = await _googleSignIn.authenticate().timeout(
        googleSignInTimeout,
      );
      final credential = GoogleAuthProvider.credential(
        idToken: account.authentication.idToken,
      );
      await _firebaseAuth
          .signInWithCredential(credential)
          .timeout(signInTimeout);
    } on TimeoutException {
      throw const AuthTimeoutException();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthCancelledException();
      }
      throw AuthException(
        'Failed to sign in with Google: ${e.description}',
        code: e.code.name,
      );
    }
  });

  Future<void> signOut() async {
    await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
  }

  Future<T> _guard<T>(String action, Future<T> Function() run) async {
    try {
      return await run();
    } on FirebaseAuthException catch (e) {
      if (isNetworkFailure(e)) {
        throw const NetworkAuthException();
      }
      throw AuthException('Failed to $action: ${e.message}', code: e.code);
    }
  }
}
