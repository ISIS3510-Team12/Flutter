import 'package:dio/dio.dart';
import 'package:team12_flutter_juggle/domain/models/gallery/project_photo.dart';
import 'package:team12_flutter_juggle/ui/core/utils/network_exceptions.dart';
import 'package:team12_flutter_juggle/ui/core/utils/photo_upload_exception.dart';

String projectPhotoPath(int projectId, int photoId, {bool thumbnail = false}) {
  final variant = thumbnail ? 'thumb' : 'full';
  return '/projects/$projectId/photos/$photoId?variant=$variant';
}

class GalleryRepository {
  GalleryRepository(this._dio);

  final Dio _dio;

  Future<List<ProjectPhoto>> getPhotos(int projectId) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/projects/$projectId/photos',
      );
      return [
        for (final json in response.data!)
          ProjectPhoto.fromJson(json as Map<String, dynamic>),
      ];
    } catch (e) {
      throw repositoryError('load project photos', e);
    }
  }

  Future<void> uploadPhoto({
    required int projectId,
    required String clientUploadId,
    required String path,
    String? thumbnailPath,
    void Function(double progress)? onProgress,
  }) async {
    try {
      await _dio.post<void>(
        '/projects/$projectId/photos',
        data: FormData.fromMap({
          'client_upload_id': clientUploadId,
          'file': await _file(path),
          if (thumbnailPath != null) 'thumbnail': await _file(thumbnailPath),
        }),
        options: Options(receiveTimeout: const Duration(seconds: 30)),
        onSendProgress: (sent, total) {
          if (total > 0) onProgress?.call(sent / total);
        },
      );
    } on DioException catch (e) {
      switch (e.response?.statusCode) {
        case 413:
          throw const PhotoUploadException(
            'The photo is too large. The maximum size is 5 MB.',
          );
        case 415:
          throw const PhotoUploadException(
            'Only JPEG, PNG, WebP or HEIC photos are allowed.',
          );
        default:
          throw repositoryError('upload project photo', e);
      }
    } catch (e) {
      throw repositoryError('upload project photo', e);
    }
  }

  Future<void> deletePhoto(int projectId, int photoId) async {
    try {
      await _dio.delete<void>('/projects/$projectId/photos/$photoId');
    } catch (e) {
      throw repositoryError('delete project photo', e);
    }
  }

  Future<MultipartFile> _file(String path) {
    final extension = path.split('.').last.toLowerCase();
    final subtype = switch (extension) {
      'png' => 'png',
      'webp' => 'webp',
      'heic' => 'heic',
      'heif' => 'heif',
      _ => 'jpeg',
    };
    return MultipartFile.fromFile(
      path,
      filename: 'photo.$extension',
      contentType: DioMediaType('image', subtype),
    );
  }
}
