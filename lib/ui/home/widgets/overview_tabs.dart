import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_notification.dart';

class OverviewTabs extends StatefulWidget {
  const OverviewTabs({
    super.key,
    required this.dueTodayTasks,
    required this.recentActivity,
  });

  final List<Map<String, dynamic>> dueTodayTasks;
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
              TabTaskViewBuilder(items: widget.dueTodayTasks)
            else
              TabActivityViewBuilder(items: widget.recentActivity),
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

class TabTaskViewBuilder extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const TabTaskViewBuilder({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No upcoming tasks',
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
      itemBuilder: (context, index) {
        final item = items[index];
        return CardItem(
          title: item['title'] as String,
          icon: item['icon'] as IconData,
          description: item['description'] as String,
        );
      },
    );
  }
}

class TabActivityViewBuilder extends StatelessWidget {
  const TabActivityViewBuilder({super.key, required this.items});

  final List<AppNotification> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No recent activity',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    IconData getIconForNotificationType(NotificationType type) {
      switch (type) {
        case NotificationType.taskCreated:
          return Icons.add_circle_outline;
        case NotificationType.taskEdited:
          return Icons.edit;
        case NotificationType.taskFinished:
          return Icons.check_box_outlined;
      }
    }

    String formatDateTime(DateTime dateTime) {
      return DateFormat('EEEE, MMMM d yyyy h:mma')
          .format(dateTime)
          .replaceAll('AM', 'am')
          .replaceAll('PM', 'pm');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return CardItem(
          title: item.title,
          icon: getIconForNotificationType(item.type),
          description: formatDateTime(item.timestamp),
          group: item.groupName,
        );
      },
    );
  }
}
