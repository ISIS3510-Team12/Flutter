import 'package:flutter/foundation.dart';
import 'package:team12_flutter_juggle/data/repositories/group/group_repository.dart';
import 'package:team12_flutter_juggle/domain/models/group/group_create.dart';

class NewGroupViewModel extends ChangeNotifier {
  NewGroupViewModel({
    required GroupRepository groupRepository,
  }) : _groupRepository = groupRepository;

  final GroupRepository _groupRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> createGroup({
    required String name,
    required String description,
    required List<String> selectedEmails,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final group = GroupCreate(
        name: name,
        description: description,
      );

      final createdGroup = await _groupRepository.createGroup(group);

      for (final email in selectedEmails) {
        await _groupRepository.addMember(
          createdGroup.id,
          email,
        );
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}