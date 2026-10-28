import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_notification.dart';
import 'package:team12_flutter_juggle/ui/home/view_models/home_state.dart';

class OverviewTabs extends StatefulWidget {
  const OverviewTabs({
    super.key,
    required this.dueTodayTasks,
    required this.recentActivity,
  });

  final List<HomeTaskItem> dueTodayTasks;
  final List<AppNotification> recentActivity;
  @override
  State<OverviewTabs> createState() => _OverviewTabsState();
}

class _OverviewTabsState extends State<OverviewTabs> {
  int _selectedTab = 0;

  void _changeTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: _selectedTab,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: TabBar(
                onTap: _changeTab,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
                indicatorColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontFamily: GoogleFonts.rubik().fontFamily,
                ),
                dividerColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                tabs: [
                  Tab(text: 'Upcoming tasks'),
                  Tab(text: 'Recent activity'),
                ],
              ),
            ),
            if (_selectedTab == 0)
              OverviewList(
                emptyText: 'No upcoming tasks',
                items: [
                  for (final task in widget.dueTodayTasks)
                    CardItem(
                      title: task.title,
                      icon: task.isPriority
                          ? Icons.priority_high
                          : Icons.task_alt,
                      description: task.description,
                    ),
                ],
              )
            else
              OverviewList(
                emptyText: 'No recent activity',
                items: [
                  for (final activity in widget.recentActivity)
                    CardItem(
                      title: activity.title,
                      icon: _notificationIcon(activity.type),
                      description: _formatDateTime(activity.timestamp),
                      group: activity.groupName,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class CardItem extends StatelessWidget {
  const CardItem({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
    this.group,
  });

  final String title;
  final IconData icon;
  final String description;
  final String? group;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ListTile(
          visualDensity: const VisualDensity(vertical: -4),
          horizontalTitleGap: 16,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 0,
          ),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: group != null ? 4 : 0,
            children: [
              if (group != null)
                Text(
                  group!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              Text(
                title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          subtitle: Text(description, style: TextStyle(fontSize: 12)),
        ),
      ),
    );
  }
}

class OverviewList extends StatelessWidget {
  const OverviewList({super.key, required this.items, required this.emptyText});

  final List<CardItem> items;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          emptyText,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }
}

IconData _notificationIcon(NotificationType type) {
  switch (type) {
    case NotificationType.taskCreated:
      return Icons.add_circle_outline;
    case NotificationType.taskEdited:
      return Icons.edit;
    case NotificationType.taskFinished:
      return Icons.check_box_outlined;
  }
}

String _formatDateTime(DateTime dateTime) {
  return DateFormat('EEEE, MMMM d yyyy h:mma')
      .format(dateTime)
      .replaceAll('AM', 'am')
      .replaceAll('PM', 'pm');
}
