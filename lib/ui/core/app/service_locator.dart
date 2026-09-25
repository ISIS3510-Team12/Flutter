import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './firebase_options.dart';

Future<void> setupDependencies() async {
  await dotenv.load(fileName: '.env');

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  await GoogleSignIn.instance.initialize();
}

final googleSignInProvider = Provider((ref) => GoogleSignIn.instance);
final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);

