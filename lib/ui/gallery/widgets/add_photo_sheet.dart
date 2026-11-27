import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

typedef PhotoPicker = Future<List<String>> Function(ImageSource source);

Future<List<String>> pickPhotos(ImageSource source) async {
  final picker = ImagePicker();
  if (source == ImageSource.camera) {
    final photo = await picker.pickImage(source: source);
    return [?photo?.path];
  }
  final photos = await picker.pickMultiImage();
  return [for (final photo in photos) photo.path];
}

Future<ImageSource?> showAddPhotoSheet(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    builder: (sheetContext) {
      Widget option({
        required IconData icon,
        required String title,
        required String subtitle,
        required ImageSource source,
      }) => ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: () => Navigator.of(sheetContext).pop(source),
      );

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Add photo',
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
            option(
              icon: Symbols.photo_camera,
              title: 'Take photo',
              subtitle: 'Use the camera',
              source: ImageSource.camera,
            ),
            option(
              icon: Symbols.photo_library,
              title: 'Choose from gallery',
              subtitle: 'Select one or more photos',
              source: ImageSource.gallery,
            ),
          ],
        ),
      );
    },
  );
}
