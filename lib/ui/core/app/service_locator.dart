import 'package:clock/clock.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import './dev_config.dart';
import './firebase_options.dart';

const bool useDevConfig = true;

Future<void> _connectDevConfig() async {
  await FirebaseAuth.instance.useAuthEmulator(
    DevConfig.host,
    DevConfig.authPort,
  );
}

Future<void> setupDependencies() async {
  if (!dotenv.isInitialized) {
    await dotenv.load(fileName: '.env');
  }

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (useDevConfig) await _connectDevConfig();
  }

  await GoogleSignIn.instance.initialize();
}

final googleSignInProvider = Provider((ref) => GoogleSignIn.instance);
final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);
final clockProvider = Provider<Clock>((ref) => const Clock());
