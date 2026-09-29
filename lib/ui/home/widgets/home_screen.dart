import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_app_bar.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/home/widgets/custom_bottom_sheet.dart';
import 'package:team12_flutter_juggle/ui/home/widgets/overview_cards.dart';
import 'package:team12_flutter_juggle/ui/home/widgets/overview_tabs.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: SingleChildScrollView(
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              userSection(context, 'Victoria'),
              overviewSection(context, numTasks: 9, numNotifications: 5),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(),
      resizeToAvoidBottomInset: false,
    );
  }

  Widget userSection(BuildContext context, String firstName) {
    final now = DateTime.now();
    final month = DateFormat('MMMM').format(now);
    final day = DateFormat('EEEE').format(now);
    final year = DateFormat('y').format(now);
    final date = DateFormat('d').format(now);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hi $firstName!',
          style: TextStyle(
            fontSize: 45,
            fontFamily: GoogleFonts.spaceGrotesk(fontWeight: .w400).fontFamily,
          ),
        ),
        Row(
          children: [
            Text('$day, $month $date, $year', style: TextStyle(fontSize: 14)),
            Spacer(),
            OutlinedButton(
              onPressed: () => _showBottomSheet(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                'Quick Actions',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget overviewSection(
    BuildContext context, {
    numTasks = 9,
    numNotifications = 5,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 15,
      children: [
        Text(
          'Overview',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        OverviewCards(numTasks: numTasks, numNotifications: numNotifications),
        OverviewTabs(),
      ],
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return CustomBottomSheet();
      },
    );
  }
}
