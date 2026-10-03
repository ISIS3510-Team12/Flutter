import 'package:dio/dio.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_settings.dart';

class SettingsRepository {
  SettingsRepository(this._dio);

  final Dio _dio;

  Future<AppSettings> getSettings() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/users/preferences',
      );
      return AppSettings(
        soundAndVibrationEnabled: response.data!['push_enabled'] as bool,
      );
    } on DioException {
      return const AppSettings(soundAndVibrationEnabled: true);
    }
  }

  Future<void> updateSettings(AppSettings settings) async {
    try {
      await _dio.patch<Map<String, dynamic>>(
        '/users/preferences',
        data: {'push_enabled': settings.soundAndVibrationEnabled},
      );
    } catch (e) {
      throw Exception('Failed to update settings: $e');
    }
  }
}
