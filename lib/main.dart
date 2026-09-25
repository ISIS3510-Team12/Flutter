import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/ui/core/app/app.dart';
import 'package:team12_flutter_juggle/ui/core/app/service_locator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const ProviderScope(child: App()));
}
