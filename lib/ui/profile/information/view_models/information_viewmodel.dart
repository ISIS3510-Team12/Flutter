import 'package:flutter/foundation.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/profile_repository.dart';
import 'package:team12_flutter_juggle/domain/models/profile/user_profile.dart';

class InformationViewModel extends ChangeNotifier {
  InformationViewModel({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository {
    _load();
  }

  final ProfileRepository _profileRepository;
  UserProfile? _profile;

  bool isLoading = true;

  String firstName = '';
  String lastName = '';
  String username = '';
  String email = '';

  String get initial => firstName.isEmpty ? '' : firstName[0].toUpperCase();

  void updateFirstName(String value) {
    firstName = value;
    notifyListeners();
  }

  void updateLastName(String value) {
    lastName = value;
    notifyListeners();
  }

  Future<void> _load() async {
    _profile = await _profileRepository.getProfile();
    firstName = _profile!.firstName;
    lastName = _profile!.lastName;
    username = _profile!.username;
    email = _profile!.email;
    isLoading = false;
    notifyListeners();
  }
}
