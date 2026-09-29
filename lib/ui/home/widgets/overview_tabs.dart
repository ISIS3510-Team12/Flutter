import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OverviewTabs extends StatelessWidget {
  const OverviewTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Color(0xFFF7F3F3),
              child: TabBar(
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
            SizedBox(
              height: 100,
              child: TabBarView(
                children: [
                  Center(child: Text('Tasks Content')),
                  Center(child: Text('Notifications Content')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
