import 'package:dio/dio.dart';
import 'package:team12_flutter_juggle/domain/models/profile/user_location.dart';

class LocationRepository {
  LocationRepository(this._dio);

  final Dio _dio;

  Future<UserLocation?> getLocation() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/users/me/location',
      );
      return UserLocation.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw Exception('Failed to load location: $e');
    }
  }

  Future<UserLocation> saveLocation(UserLocation location) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/users/me/location',
        data: location.toJson(),
      );
      return UserLocation.fromJson(response.data!);
    } catch (e) {
      throw Exception('Failed to save location: $e');
    }
  }

  Future<void> deleteLocation() async {
    try {
      await _dio.delete<void>('/users/me/location');
    } catch (e) {
      throw Exception('Failed to delete location: $e');
    }
  }
}
