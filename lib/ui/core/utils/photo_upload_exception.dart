class PhotoUploadException implements Exception {
  const PhotoUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}
