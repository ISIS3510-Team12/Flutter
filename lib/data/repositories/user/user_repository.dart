import 'package:team12_flutter_juggle/data/services/user/user_api_client.dart';
import 'package:team12_flutter_juggle/domain/models/user/user.dart';

class UserRepository {
  UserRepository(this._apiClient);

  final UserApiClient _apiClient;

  Future<List<User>> getUsers() {
    return _apiClient.fetchUsers();
  }
}