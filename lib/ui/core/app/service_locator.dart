import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './firebase_options.dart';

Future<void> setupServiceLocator() async {
  setupDependencies();
}

Future<void> setupDependencies() async {

  // Load environment variables from the .env file
  await dotenv.load(
    fileName: '.env',
  );

  
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
