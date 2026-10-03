import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';

class RouterNotifier extends ChangeNotifier {
  
  RouterNotifier(Ref ref) {
    ref.listen<AsyncValue<User?>>(
      authStateProvider,
      (_, next) {
        _authState = next;
        notifyListeners();
      },
      fireImmediately: true,
    );
  }

  AsyncValue<User?> _authState = const AsyncValue.loading();

  String? redirect(GoRouterState state) {
    if (_authState.isLoading) {
      return null;
    }

    final signedIn = _authState.value != null;
    final isPublicRoute = Routes.publicRoutes.contains(state.matchedLocation);

    if (!signedIn && !isPublicRoute) {
      return Routes.landing;
    }

    if (signedIn && isPublicRoute) {
      return Routes.home;
    }

    return null;
  }
}


