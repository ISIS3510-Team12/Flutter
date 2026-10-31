import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<bool> showShakeResetDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            dialogContext.pop(false);
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            dialogContext.pop(true);
          },
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<bool> showShakeClearDialog({required BuildContext context}) {
  return showShakeResetDialog(
    context: context,
    title: 'Clear form?',
    message:
        'Do you want to clear all the information entered '
        'in this form? This action cannot be undone.',
    confirmLabel: 'Clear form',
  );
}

Future<bool> showShakeDiscardDialog({
  required BuildContext context,
  required String entity,
}) {
  return showShakeResetDialog(
    context: context,
    title: 'Discard changes?',
    message:
        'Do you want to discard your changes and restore '
        'the $entity information to its original values?',
    confirmLabel: 'Discard changes',
  );
}
