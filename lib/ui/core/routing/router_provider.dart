import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/core/routing/route_notifier.dart';
import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import './routes.dart';
import './router.dart';

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref, currentUserProvider);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);
  return GoRouter(
    initialLocation: Routes.landing,
    refreshListenable: notifier,
    redirect: (context, state) {
      return authRedirect(ref.watch(authStateProvider), state);
    },
    routes: appRoutes,
  );
});