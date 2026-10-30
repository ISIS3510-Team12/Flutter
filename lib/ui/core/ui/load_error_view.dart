import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/ui/core/utils/network_exceptions.dart';

class LoadErrorView extends StatelessWidget {
  const LoadErrorView({
    super.key,
    required this.error,
    required this.offlineMessage,
    required this.genericMessage,
    required this.onRetry,
  });

  final Object error;
  final String offlineMessage;
  final String genericMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = switch (error) {
      NetworkUnavailableException() => offlineMessage,
      ServiceUnavailableException() =>
        'The service is not responding right now. Try again in a moment.',
      _ => genericMessage,
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
