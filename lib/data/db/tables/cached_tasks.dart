import 'package:drift/drift.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';

@DataClassName('CachedTaskRow')
@TableIndex(
  name: 'cached_tasks_user_deadline',
  columns: {#userId, #deadlineUtcMs},
)
@TableIndex(
  name: 'cached_tasks_user_group',
  columns: {#userId, #groupId},
)
class CachedTasks extends Table {
  static final assigneesConverter = TypeConverter.json2<List<String>>(
    fromJson: (json) => List<String>.from(json as List),
    toJson: (list) => list,
  );

  TextColumn get userId => text()();
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get groupName => text()();
  IntColumn get groupId => integer().nullable()();
  TextColumn get assignees => text().map(CachedTasks.assigneesConverter)();
  TextColumn get type => textEnum<TaskType>()();
  TextColumn get status => textEnum<TaskStatus>()();
  IntColumn get deadlineUtcMs => integer()();
  BoolColumn get isMine => boolean()();
  BoolColumn get isPriority => boolean()();
  BoolColumn get needsHelp => boolean()();

  @override
  Set<Column> get primaryKey => {userId, id};

  @override
  bool get isStrict => true;
}
