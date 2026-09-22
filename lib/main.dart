import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/ui/core/app/app.dart';
import 'package:team12_flutter_juggle/ui/core/app/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const App());
}
