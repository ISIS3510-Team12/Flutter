import 'package:team12_flutter_juggle/domain/models/profile/user_profile.dart';

// TODO: replace with real HTTP calls to the backend
class ProfileApiClient {
  UserProfile? _remoteProfile = const UserProfile(
    id: 'u-1',
    firstName: 'Victoria',
    lastName: 'G',
    username: 'VictoriaG',
    email: 'victoria.g@test.com',
    role: 'Creative student',
  );

  Future<UserProfile> fetchProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _remoteProfile!;
  }

  Future<UserProfile> updateProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _remoteProfile = profile;
    return profile;
  }
}
