import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/ui/auth/signup/widgets/signup_form.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/auth/view_models/auth_viewmodel_provider.dart';

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authViewModelProvider);
    final theme = Theme.of(context);

    ref.listen(authViewModelProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: theme.canvasColor,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Sign Up', style: theme.textTheme.titleMedium),
        leading: BackButton(
          onPressed: () {
            context.go('/');
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SignupForm(
        isLoading: auth.isLoading,
        onSubmit:
            ({
              required String firstName,
              required String lastName,
              required String email,
              required String password,
            }) {
              return ref
                  .read(authViewModelProvider.notifier)
                  .signUp(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    password: password,
                  );
            },
        onGoogleSignIn: () {
          return ref.read(authViewModelProvider.notifier).signInWithGoogle();
        },
      ),
    );
  }
}
