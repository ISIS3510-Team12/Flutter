import 'package:drift/drift.dart';

@DataClassName('CachedGroupListLoadRow')
class CachedGroupListLoads extends Table {
  TextColumn get userId => text()();

  IntColumn get loadedAtUtcMs => integer()();

  @override
  Set<Column> get primaryKey => {userId};

  @override
  bool get isStrict => true;
}
