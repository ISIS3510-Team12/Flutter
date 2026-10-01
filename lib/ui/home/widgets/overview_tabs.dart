import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OverviewTabs extends ConsumerWidget {
  const OverviewTabs({
    super.key,
    required this.upcomingTasks,
    required this.recentActivity,
    required this.selectedTab,
    required this.changeTab,
  });

  final List<Map<String, dynamic>> upcomingTasks;
  final List<Map<String, dynamic>> recentActivity;
  final int selectedTab;
  final Function(int) changeTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      initialIndex: selectedTab,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Color(0xFFF7F3F3),
              child: TabBar(
                onTap: changeTab,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
                indicatorColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontFamily: GoogleFonts.rubik().fontFamily,
                ),
                dividerColor: Colors.grey.shade300,
                tabs: [
                  Tab(text: 'Upcoming tasks'),
                  Tab(text: 'Recent activity'),
                ],
              ),
            ),
            if (selectedTab == 0)
              _buildListView(context, upcomingTasks)
            else
              _buildListView(context, recentActivity),
          ],
        ),
      ),
    );
  }

  Widget cardItem(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    String? group,
  ) {
    return Card(
      color: Color(0xFFF7F3F3),
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
                  group,
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

  Widget _buildListView(
    BuildContext context,
    List<Map<String, dynamic>> items,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return cardItem(
          context,
          item['title'] as String,
          item['icon'] as IconData,
          item['description'] as String,
          item['group'] as String?,
        );
      },
    );
  }
}
