import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/core/routing/router_notifier.dart';
import 'package:go_router/go_router.dart';
import './routes.dart';
import 'router.dart';

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);
  return GoRouter(
    initialLocation: Routes.landing,
    refreshListenable: notifier,
    redirect: (_, state) {
      return notifier.redirect(state);
    },
    routes: routes,
  );
});
