import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/auth/view_models/auth_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/core/utils/auth_exceptions.dart';

class AuthTimeoutMessage extends ConsumerWidget {
  const AuthTimeoutMessage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(authViewModelProvider).error;
    if (error is! AuthTimeoutException) return const SizedBox.shrink();
    return Center(
      child: Text(
        error.message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}
