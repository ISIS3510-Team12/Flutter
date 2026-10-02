import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:team12_flutter_juggle/ui/calendar/view_models/calendar_view_model_provider.dart';
import 'package:team12_flutter_juggle/ui/calendar/widgets/day_selector.dart';
import 'package:team12_flutter_juggle/ui/calendar/widgets/schedule_card.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_app_bar.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarViewModelProvider);

    return Scaffold(
      appBar: const CustomAppBar(),
      body: calendarState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
        data: (calendar) {
          final selectedDate = calendar.selectedDate;

          return Column(
            children: [
              const SizedBox(height: 16),

              Text(
                _getMonthTitle(selectedDate),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 16),

              DaySelector(
                selectedDate: selectedDate,
                dates: calendar.week,
                onDateSelected: (date) {
                  ref
                      .read(calendarViewModelProvider.notifier)
                      .selectDate(date);
                },
                onPreviousWeek: () {
                  ref
                      .read(calendarViewModelProvider.notifier)
                      .previousWeek();
                },
                onNextWeek: () {
                  ref
                      .read(calendarViewModelProvider.notifier)
                      .nextWeek();
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
                child: calendar.schedule.isEmpty
                    ? const Center(
                        child: Text(
                          'No tasks scheduled for this day.',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        itemCount: calendar.schedule.length,
                        itemBuilder: (context, index) {
                          final task = calendar.schedule[index];

                          return ScheduleCard(task: task);
                        },
                      ),
              ),

            ],
          );
        },
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }

  String _getMonthTitle(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]}, ${date.year}';
  }
}