import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_app_bar.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/calendar/widgets/day_selector.dart';
import 'package:team12_flutter_juggle/ui/calendar/widgets/schedule_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {

  DateTime selectedDate = DateTime(2026, 9, 12);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
      children: [
        const SizedBox(height: 16),

        Text(
          'September, 2026',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        DaySelector(
          selectedDate: selectedDate,
          onDateSelected: (date) {
            setState(() {
              selectedDate = date;
            });
          },
        ),

        const SizedBox(height: 24),

        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Your schedule',
              
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          children: const [
            ScheduleCard(
              title: 'Needs Help.',
              task: 'Finish the figma',
              assignedTo: 'Diego',
              timeInfo: 'Tomorrow - 12 hours left',
            ),
            ScheduleCard(
              title: 'Needs Help.',
              task: 'Finish the figma',
              assignedTo: 'Diego',
              timeInfo: 'Tomorrow - 12 hours left',
            ),
          ],
        ),
      ),

        // Schedule cards después
      ],
    ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }
}