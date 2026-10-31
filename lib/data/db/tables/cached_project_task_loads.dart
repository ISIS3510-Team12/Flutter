import 'package:drift/drift.dart';

@DataClassName('CachedProjectTaskLoadRow')
class CachedProjectTaskLoads extends Table {
  TextColumn get userId => text()();
  IntColumn get projectId => integer()();
  IntColumn get loadedAtUtcMs => integer()();

  @override
  Set<Column> get primaryKey => {userId, projectId};

  @override
  bool get isStrict => true;
}