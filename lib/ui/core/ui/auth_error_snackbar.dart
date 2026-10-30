import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/auth/view_models/auth_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/utils/auth_exceptions.dart';

extension AuthErrorListener on WidgetRef {
  void listenForAuthErrors(BuildContext context) {
    listen(authViewModelProvider, (_, next) {
      if (next case AsyncError(:final error)) {
        if (error is NetworkAuthException && !read(isOnlineProvider)) {
          return;
        }
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(_messageFor(error))));
      }
    });
  }

  String _messageFor(Object error) {
    if (error is AuthException) return error.message;
    return 'Something went wrong. Please try again.';
  }
}
