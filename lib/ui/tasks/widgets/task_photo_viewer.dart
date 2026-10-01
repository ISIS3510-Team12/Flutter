import 'dart:typed_data';

import 'package:flutter/material.dart';

class TaskPhotoViewer extends StatelessWidget {
  const TaskPhotoViewer({super.key, required this.photo});

  final Uint8List photo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
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
