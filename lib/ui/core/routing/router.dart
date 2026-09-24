import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/ui/core/app/app.dart';
import 'package:team12_flutter_juggle/ui/landing/widgets/landing_screen.dart';
import 'package:team12_flutter_juggle/ui/auth/signin/widgets/signin_screen.dart';
import 'package:team12_flutter_juggle/ui/auth/signup/widgets/signup_screen.dart';
import './routes.dart';

String? authRedirect(AsyncValue<User?> auth, GoRouterState state) {
  if (auth.isLoading) {
    return null;
  }

  final path = state.matchedLocation;
  final user = auth.value;
  final isPublicRoute = Routes.publicRoutes.contains(path);

  if (user == null && !isPublicRoute) {
    return Routes.landing;
  }

  if (user != null && isPublicRoute) {
    return Routes.home;
  }

  return null;
}

final appRoutes = <RouteBase>[
  GoRoute(
    path: Routes.landing,
    builder: (context, state) => const LandingScreen(),
  ),
  GoRoute(
    path: Routes.signin,
    builder: (context, state) => const SigninScreen(),
  ),
  GoRoute(
    path: Routes.signup,
    builder: (context, state) => const SignupScreen(),
  ),
  GoRoute(path: Routes.home, builder: (context, state) => const MainScreen()),
];
