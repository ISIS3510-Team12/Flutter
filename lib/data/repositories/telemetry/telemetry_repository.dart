import 'package:dio/dio.dart';

class TelemetryRepository {
  TelemetryRepository(this._dio);

  final Dio _dio;

  Future<bool> registerScreenLoad({
    required String screen,
    required Duration loadTime,
  }) async {
    try {
      await _dio.post<void>(
        '/telemetry/screen-load',
        data: {
          'screen': screen,
          'load_time_ms': loadTime.inMicroseconds / 1000,
        },
      );
      return true;
    } on DioException {
      return false;
    }
  }
}
