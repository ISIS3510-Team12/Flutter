import 'package:flutter/foundation.dart';
import 'package:team12_flutter_juggle/data/repositories/group/group_repository.dart';
import 'package:team12_flutter_juggle/domain/models/group/group.dart';

class GroupsViewModel extends ChangeNotifier {
  GroupsViewModel({
    required GroupRepository groupRepository,
  }) : _groupRepository = groupRepository {
    loadGroups();
  }

  final GroupRepository _groupRepository;

  List<Group> _groups = [];
  List<Group> get groups => _groups;

  List<Group> _filteredGroups = [];
  List<Group> get filteredGroups => _filteredGroups;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  Future<void> loadGroups() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _groups = await _groupRepository.getGroups();
      _filteredGroups = List.from(_groups);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  void onQueryChange(String query) {
    final normalizedQuery = query.toLowerCase().trim();

    if (normalizedQuery.isEmpty) {
      _filteredGroups = List.from(_groups);
    } else {
      _filteredGroups = _groups
          .where(
            (group) =>
                group.name
                    .toLowerCase()
                    .contains(normalizedQuery),
          )
          .toList();
    }

    notifyListeners();
  }
}