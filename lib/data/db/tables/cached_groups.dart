import 'package:drift/drift.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_member.dart';

@DataClassName('CachedGroupRow')
class CachedGroups extends Table {
  static final membersConverter = TypeConverter.json2<List<TaskMember>>(
    fromJson: (json) => [
      for (final member in json as List)
        TaskMember(
          id: member['id'] as String,
          name: member['name'] as String,
          initial: member['initial'] as String,
        ),
    ],
    toJson: (members) => [
      for (final member in members)
        {'id': member.id, 'name': member.name, 'initial': member.initial},
    ],
  );

  TextColumn get userId => text()();
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  IntColumn get pendingCount => integer()();
  TextColumn get members => text().map(CachedGroups.membersConverter)();

  @override
  Set<Column> get primaryKey => {userId, id};

  @override
  bool get isStrict => true;
}
