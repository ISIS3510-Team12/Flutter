import 'dart:io';

import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/data/local/pending_op.dart';

class PhotoTile extends StatelessWidget {
  const PhotoTile({
    super.key,
    required this.child,
    required this.label,
    required this.onTap,
  });

  final Widget child;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: label,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink(child: child),
        ),
      ),
    );
  }
}

class PendingPhotoTile extends StatelessWidget {
  const PendingPhotoTile({
    super.key,
    required this.op,
    required this.progress,
    required this.isOnline,
    required this.onFailedTap,
  });

  final PendingOp op;
  final double? progress;
  final bool isOnline;
  final VoidCallback onFailedTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final failed = op.status == PendingOpStatus.failed;
    final value = progress;
    final message = failed
        ? 'Upload failed. Tap to fix'
        : !isOnline
        ? 'Waiting for connection'
        : value == null
        ? 'Waiting to upload'
        : '${(value * 100).round()}%';

    return PhotoTile(
      label: 'Photo being uploaded. $message',
      onTap: failed ? onFailedTap : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(op.thumbnailPath ?? op.photoPath!),
            fit: BoxFit.cover,
            cacheWidth: 400,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
          ColoredBox(color: Colors.black.withValues(alpha: 0.45)),
          MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.1,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  if (value != null && !failed) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: value,
                      color: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: 0.35),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
