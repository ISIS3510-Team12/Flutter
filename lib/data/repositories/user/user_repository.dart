import 'package:dio/dio.dart';
import 'package:team12_flutter_juggle/domain/models/user/user.dart';

class UserRepository {
  UserRepository(this._dio);

  final Dio _dio;

  Future<List<User>> getUsers() async {
    final response = await _dio.get<List<dynamic>>(
      '/users/',
    );

    return response.data!
        .map(
          (json) => User.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}