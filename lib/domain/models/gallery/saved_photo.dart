import 'package:team12_flutter_juggle/domain/models/gallery/project_photo.dart';

class SavedPhoto {
  const SavedPhoto({
    required this.photo,
    required this.projectName,
    required this.savedAt,
    required this.filePath,
  });

  final ProjectPhoto photo;
  final String projectName;
  final DateTime savedAt;
  final String filePath;
}
