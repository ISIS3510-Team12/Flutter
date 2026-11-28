import 'package:team12_flutter_juggle/domain/models/shared/server_date.dart';

class ProjectPhoto {
  const ProjectPhoto({
    required this.id,
    required this.projectId,
    required this.uploaderId,
    required this.uploaderName,
    required this.createdAt,
    this.caption,
  });

  factory ProjectPhoto.fromJson(Map<String, dynamic> json) {
    return ProjectPhoto(
      id: json['id'] as int,
      projectId: json['project_id'] as int,
      uploaderId: json['uploader_id'] as String,
      uploaderName: json['uploader_name'] as String,
      createdAt: parseServerDate(json['created_at'] as String),
      caption: json['caption'] as String?,
    );
  }

  final int id;
  final int projectId;
  final String uploaderId;
  final String uploaderName;
  final DateTime createdAt;
  final String? caption;
}
