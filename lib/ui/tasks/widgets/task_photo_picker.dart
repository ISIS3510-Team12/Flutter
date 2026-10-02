import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

const _maxPhotoBytes = 5 * 1024 * 1024;
const _allowedExtensions = {'jpg', 'jpeg', 'png', 'webp', 'heic', 'heif'};

class TaskPhotoPicker extends StatelessWidget {
  const TaskPhotoPicker({
    super.key,
    required this.newPhotoPath,
    required this.onPicked,
    this.currentPhoto,
  });

  final String? newPhotoPath;
  final Uint8List? currentPhoto;
  final ValueChanged<String> onPicked;

  Future<void> _choose(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Symbols.photo_camera),
              title: const Text('Take a photo'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Symbols.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null || !context.mounted) return;
    final extension = picked.path.split('.').last.toLowerCase();
    final String? error;
    if (!_allowedExtensions.contains(extension)) {
      error = 'Only JPEG, PNG, WebP or HEIC photos are allowed.';
    } else if (await picked.length() > _maxPhotoBytes) {
      error = 'The photo is too large. The maximum size is 5 MB.';
    } else {
      error = null;
    }
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    onPicked(picked.path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Widget? preview = newPhotoPath != null
        ? Image.file(File(newPhotoPath!), fit: BoxFit.cover)
        : currentPhoto != null
        ? Image.memory(currentPhoto!, fit: BoxFit.cover)
        : null;
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _choose(context),
        child: SizedBox(
          width: double.infinity,
          height: preview == null ? null : 200,
          child: preview == null
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      const Icon(Symbols.upload, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        'Take or choose a photo for the task',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    preview,
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: theme.colorScheme.primaryContainer,
                        alignment: Alignment.center,
                        child: Text(
                          'Tap to retake',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
