import 'group_user.dart';

class Group {
  final int id;
  final String name;
  final String description;
  final List<GroupUser> users;

  const Group({
    required this.id,
    required this.name,
    required this.description,
    required this.users,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      users: (json['users'] as List<dynamic>)
          .map(
            (user) => GroupUser.fromJson(
              user as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}