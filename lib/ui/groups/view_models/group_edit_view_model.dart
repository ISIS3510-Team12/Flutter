import 'package:flutter/foundation.dart';
import 'package:team12_flutter_juggle/data/repositories/group/group_repository.dart';
import 'package:team12_flutter_juggle/domain/models/group/group_update.dart';

class GroupEditViewModel extends ChangeNotifier {
  GroupEditViewModel({
    required GroupRepository groupRepository,
  }) : _groupRepository = groupRepository;

  final GroupRepository _groupRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> updateGroup({
    required int groupId,
    required String name,
    required String description,
    required List<String> emailsToAdd,
    required List<String> userIdsToRemove,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final group = GroupUpdate(
        name: name,
        description: description,
      );

      await _groupRepository.updateGroup(
        groupId,
        group,
      );

      for (final email in emailsToAdd) {
        await _groupRepository.addMember(
          groupId,
          email,
        );
      }

      for (final userId in userIdsToRemove) {
        await _groupRepository.removeMember(
          groupId,
          userId,
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