import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';

class OverviewCards extends StatelessWidget {
  const OverviewCards({
    super.key,
    required this.numTasks,
    required this.numNotifications,
  });

  final int? numTasks;
  final int? numNotifications;

  final cardsInfo = const [
    (
      id: 1,
      icon: Symbols.list_alt,
      title: "Today's Tasks",
      description: 'Tasks',
      route: Routes.allTasks,
    ),
    (
      id: 2,
      icon: Symbols.circle_notifications,
      title: "Today's Notifications",
      description: 'Notifications',
      route: Routes.profileNotifications,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: cardsInfo.map((card) {
        return Expanded(
          child: CardItem(
            icon: card.icon,
            title: card.title,
            description: card.description,
            route: card.route,
            numTasks: numTasks ?? 0,
            numNotifications: numNotifications ?? 0,
          ),
        );
      }).toList(),
    );
  }
}

class CardItem extends StatelessWidget {
  const CardItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.route,
    required this.numTasks,
    required this.numNotifications,
  });

  final IconData icon;
  final String title;
  final String description;
  final String route;
  final int numTasks;
  final int numNotifications;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(route),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            spacing: 5,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 24,
                fill: 1,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: .bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              Row(
                spacing: 10,
                children: [
                  if (description == 'Tasks')
                    Text(
                      '$numTasks',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: .bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    )
                  else if (description == 'Notifications')
                    Text(
                      '$numNotifications',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: .bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: .bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
