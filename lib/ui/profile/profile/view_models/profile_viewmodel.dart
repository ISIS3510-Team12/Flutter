import 'package:flutter/foundation.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/profile_repository.dart';
import 'package:team12_flutter_juggle/domain/models/profile/user_profile.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository {
    _load();
  }

  final ProfileRepository _profileRepository;

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  Future<void> _load() async {
    _profile = await _profileRepository.getProfile();
    notifyListeners();
  }
}
