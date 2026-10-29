import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/ui/auth/signin/widgets/signin_form.dart';
import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/auth/view_models/auth_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/core/ui/auth_error_snackbar.dart';
import 'package:team12_flutter_juggle/ui/core/ui/offline_banner.dart';

class SigninScreen extends ConsumerWidget {
  const SigninScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listenForAuthErrors(context);
    final auth = ref.watch(authViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        title: Text('Sign In', style: theme.textTheme.titleMedium),
        leading: BackButton(onPressed: () => context.go(Routes.landing)),
      ),
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: SigninForm(
              isLoading: auth.isLoading,
              onSubmit: ({required String email, required String password}) {
                ref
                    .read(authViewModelProvider.notifier)
                    .signIn(email: email, password: password);
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
