import 'dart:typed_data';

import 'package:flutter/material.dart';

class TaskPhotoViewer extends StatelessWidget {
  const TaskPhotoViewer({super.key, required this.photo});

  final Uint8List photo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.onSurface,
      appBar: AppBar(
        backgroundColor: scheme.onSurface,
        foregroundColor: scheme.surface,
        title: const Text('Evidences'),
      ),
      body: Center(
        child: InteractiveViewer(
          maxScale: 5,
          child: Image.memory(photo, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
