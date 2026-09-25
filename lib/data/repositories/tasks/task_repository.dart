import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';

class TaskRepository {
  final List<Task> _tasks = [
    Task(
      id: 't-1',
      title: 'Do the design of the app',
      description: 'Design the main screens of the app in Figma.',
      type: TaskType.design,
      status: TaskStatus.inProgress,
      groupName: 'App Devs',
      assignees: const ['Cristian'],
      deadline: DateTime.now().add(const Duration(hours: 12)),
      isMine: true,
      isPriority: true,
      needsHelp: false,
      notes: '',
    ),
    Task(
      id: 't-2',
      title: 'Get a 5/5 (hopefully)',
      description: 'Finish the project with a perfect grade.',
      type: TaskType.writing,
      status: TaskStatus.pending,
      groupName: 'App Devs',
      assignees: const ['Cristian'],
      deadline: DateTime.now().add(const Duration(hours: 12)),
      isMine: true,
      isPriority: false,
      needsHelp: false,
      notes: '',
    ),
    Task(
      id: 't-3',
      title: 'Finish the figma',
      description: 'Create the figma for small class exercise and upcoming MS for sprint 2.',
      type: TaskType.design,
      status: TaskStatus.inProgress,
      groupName: 'App Devs',
      assignees: const ['Diego'],
      deadline: DateTime.now().add(const Duration(days: 1, hours: 12)),
      isMine: false,
      isPriority: true,
      needsHelp: true,
      notes: '',
    ),
    Task(
      id: 't-4',
      title: 'Learn how to Figma',
      description: 'Watch the tutorials shared in the group chat.',
      type: TaskType.design,
      status: TaskStatus.pending,
      groupName: 'App Devs',
      assignees: const ['Diego'],
      deadline: DateTime.now().add(const Duration(days: 1, hours: 12)),
      isMine: false,
      isPriority: false,
      needsHelp: false,
      notes: '',
    ),
    Task(
      id: 't-5',
      title: 'Learn how to align components',
      description: 'Practice alignment and spacing in Flutter widgets.',
      type: TaskType.coding,
      status: TaskStatus.pending,
      groupName: 'App Devs',
      assignees: const ['Manuela'],
      deadline: DateTime.now().add(const Duration(days: 1, hours: 12)),
      isMine: false,
      isPriority: false,
      needsHelp: false,
      notes: '',
    ),
  ];

  Future<List<Task>> getTasks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_tasks);
  }

  Future<Task> getTask(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _tasks.firstWhere((task) => task.id == id);
  }

  Future<void> createTask(Task task) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _tasks.add(task);
  }

  Future<String> getCurrentGroupName() async {
    return 'App Devs';
  }

  Future<List<String>> getGroupMembers() async {
    return const ['Cristian', 'Diego', 'Shaiel', 'Manuela'];
  }
}
