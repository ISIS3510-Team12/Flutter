import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

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
    ),
    (
      id: 2,
      icon: Symbols.circle_notifications,
      title: "Today's Notifications",
      description: 'Notifications',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: cardsInfo.map((card) {
        return Expanded(
          child: cardItem(
            context,
            card.icon,
            card.title,
            card.description,
            numTasks ?? 0,
            numNotifications ?? 0,
          ),
        );
      }).toList(),
    );
  }

  Widget cardItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    int numTasks,
    int numNotifications,
  ) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                fontSize: 14,
                fontWeight: .bold,
                color: Colors.white,
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
    );
  }
}
