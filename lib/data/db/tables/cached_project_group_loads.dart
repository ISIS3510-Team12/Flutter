import 'package:drift/drift.dart';

@DataClassName('CachedProjectGroupLoadRow')
class CachedProjectGroupLoads extends Table {
  TextColumn get userId => text()();
  IntColumn get groupId => integer()();
  IntColumn get loadedAtUtcMs => integer()();

  @override
  Set<Column> get primaryKey => {userId, groupId};

  @override
  bool get isStrict => true;
}