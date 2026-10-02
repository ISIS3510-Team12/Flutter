import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/ui/core/themes/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/core/routing/router_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      routerConfig: router,
      title: 'Juggle',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
    );
  }
}
