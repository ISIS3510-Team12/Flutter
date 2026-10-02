import 'package:dio/dio.dart';
import 'package:team12_flutter_juggle/domain/models/auth/app_user.dart';

class UserRepository {
  UserRepository(this._dio);

  final Dio _dio;

  Future<AppUser> getCurrentUser() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/users/current_user',
    );
    return AppUser.fromJson(response.data!);
  }

  Future<void> createUser({
    required String firstName,
    required String lastName,
  }) async {
    await _dio.post<void>(
      '/users/create_user',
      data: {'first_name': firstName, 'last_name': lastName},
    );
  }
}
