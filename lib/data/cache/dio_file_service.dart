import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class DioFileService extends FileService {
  DioFileService(this._dio, {required this.validity});

  final Dio _dio;
  final Duration validity;

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final response = await _dio.get<ResponseBody>(
      url,
      options: Options(
        responseType: ResponseType.stream,
        headers: headers,
        validateStatus: (_) => true,
      ),
    );
    return _DioFileResponse(response, DateTime.now().add(validity));
  }
}

class _DioFileResponse implements FileServiceResponse {
  _DioFileResponse(this._response, this.validTill);

  final Response<ResponseBody> _response;

  @override
  final DateTime validTill;

  @override
  Stream<List<int>> get content => _response.data!.stream;

  @override
  int? get contentLength {
    final length = _response.data!.contentLength;
    return length < 0 ? null : length;
  }

  @override
  int get statusCode => _response.statusCode ?? 500;

  @override
  String? get eTag => _response.headers.value('etag');

  @override
  String get fileExtension {
    final type = _response.headers.value(Headers.contentTypeHeader) ?? '';
    return switch (type.split(';').first) {
      'image/png' => '.png',
      'image/webp' => '.webp',
      'image/heic' => '.heic',
      'image/heif' => '.heif',
      _ => '.jpg',
    };
  }
}
