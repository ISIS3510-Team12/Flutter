import 'package:drift/drift.dart';

@DataClassName('CachedProjectTaskRow')
@TableIndex(
  name: 'cached_project_tasks_user_project',
  columns: {#userId, #projectId},
)
class CachedProjectTasks extends Table {
  TextColumn get userId => text()();
  IntColumn get projectId => integer()();
  TextColumn get taskId => text()();
  TextColumn get taskJson => text()();

  @override
  Set<Column> get primaryKey => {userId, projectId, taskId};

  @override
  bool get isStrict => true;
}