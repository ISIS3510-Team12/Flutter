import 'package:team12_flutter_juggle/data/services/profile/profile_api_client.dart';
import 'package:team12_flutter_juggle/domain/models/profile/user_profile.dart';

class ProfileRepository {
  ProfileRepository(this._apiClient);

  final ProfileApiClient _apiClient;

  UserProfile? _cachedProfile;

  Future<UserProfile> getProfile({bool forceRefresh = false}) async {
    if (_cachedProfile != null && !forceRefresh) {
      return _cachedProfile!;
    }
    _cachedProfile = await _apiClient.fetchProfile();
    return _cachedProfile!;
  }

  Future<UserProfile> updateProfile(UserProfile profile) async {
    _cachedProfile = await _apiClient.updateProfile(profile);
    return _cachedProfile!;
  }
}
