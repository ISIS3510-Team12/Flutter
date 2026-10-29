import 'package:drift/drift.dart';

@DataClassName('CachedProjectRow')
@TableIndex(
  name: 'cached_projects_user_group',
  columns: {#userId, #groupId},
)
class CachedProjects extends Table {
  TextColumn get userId => text()();
  IntColumn get id => integer()();
  IntColumn get groupId => integer()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  IntColumn get deadlineUtcMs => integer()();

  @override
  Set<Column> get primaryKey => {userId, id};

  @override
  bool get isStrict => true;
}
