import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/ui/auth/signin/widgets/signin_form.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/auth/view_models/auth_viewmodel_provider.dart';

class SigninScreen extends ConsumerWidget {
  const SigninScreen({super.key});

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
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Sign In', style: theme.textTheme.titleMedium),
        leading: BackButton(onPressed: () => context.go('/signup')),
      ),
      backgroundColor: Colors.white,
      body: SigninForm(
        isLoading: auth.isLoading,
        onSubmit: ({required String email, required String password}) {
          return ref
              .read(authViewModelProvider.notifier)
              .signIn(email: email, password: password);
        },
      ),
    );
  }
}
