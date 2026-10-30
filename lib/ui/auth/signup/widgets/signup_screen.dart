import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/ui/auth/signup/widgets/signup_form.dart';
import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/auth/view_models/auth_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/core/ui/auth_error_snackbar.dart';
import 'package:team12_flutter_juggle/ui/core/ui/offline_banner.dart';

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listenForAuthErrors(context);
    final auth = ref.watch(authViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: theme.canvasColor,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        title: Text('Sign Up', style: theme.textTheme.titleMedium),
        leading: BackButton(
          onPressed: () {
            context.go(Routes.signin);
          },
        ),
      ),
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: SignupForm(
              isLoading: auth.isLoading,
              onSubmit:
                  ({
                    required String firstName,
                    required String lastName,
                    required String email,
                    required String password,
                  }) {
                    ref
                        .read(authViewModelProvider.notifier)
                        .signUp(
                          firstName: firstName,
                          lastName: lastName,
                          email: email,
                          password: password,
                        );
                  },
              onGoogleSignIn: () {
                ref.read(authViewModelProvider.notifier).signInWithGoogle();
              },
            ),
          ),
        ],
      ),
    );
  }
}
