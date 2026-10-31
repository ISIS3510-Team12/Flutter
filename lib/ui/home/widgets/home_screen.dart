import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_notification.dart';
import 'package:team12_flutter_juggle/ui/core/app/service_locator.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_app_bar.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/core/ui/offline_banner.dart';
import 'package:team12_flutter_juggle/ui/core/ui/service_unavailable_banner.dart';
import 'package:team12_flutter_juggle/ui/home/view_models/home_state.dart';
import 'package:team12_flutter_juggle/ui/home/widgets/custom_bottom_sheet.dart';
import 'package:team12_flutter_juggle/ui/home/widgets/next_task_section.dart';
import 'package:team12_flutter_juggle/ui/home/widgets/overview_cards.dart';
import 'package:team12_flutter_juggle/ui/home/widgets/overview_tabs.dart';
import 'package:team12_flutter_juggle/ui/home/view_models/home_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_load_tracker.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_names.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    return ScreenLoadTracker(
      screen: ScreenNames.home,
      state: state,
      child: Scaffold(
        appBar: CustomAppBar(),
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: state.when(
                data: (data) => Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 20,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (data.serviceUnavailable)
                          ServiceUnavailableBanner(
                            onRetry: () =>
                                ref.invalidate(homeViewModelProvider),
                          ),
                        UserSection(firstName: data.user.firstName),
                        const NextTaskSection(),
                        OverviewSection(
                          dueTodayTasks: data.dueTodayTasks,
                          recentActivity: data.recentActivity,
                          numTasks: data.dataUnavailable
                              ? null
                              : data.numUrgentTasks,
                          numNotifications: data.dataUnavailable
                              ? null
                              : data.numNotifications,
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) =>
                    Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
        bottomNavigationBar: CustomNavigationBar(),
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}

class UserSection extends ConsumerWidget {
  final String firstName;

  const UserSection({super.key, required this.firstName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateFormat('EEEE, MMMM d, y')
        .format(ref.watch(clockProvider).now());
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
            Expanded(
              child: Text(
                today,
                style: TextStyle(fontSize: 14),
                softWrap: true,
              ),
            ),
            SizedBox(width: 10),
            OutlinedButton(
              onPressed: () => _showBottomSheet(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
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

class OverviewSection extends StatelessWidget {
  final List<HomeTaskItem> dueTodayTasks;
  final List<AppNotification> recentActivity;
  final int? numTasks;
  final int? numNotifications;

  const OverviewSection({
    super.key,
    required this.dueTodayTasks,
    required this.recentActivity,
    required this.numTasks,
    required this.numNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 15,
      children: [
        Text(
          'Overview',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        OverviewCards(numTasks: numTasks, numNotifications: numNotifications),
        OverviewTabs(
          dueTodayTasks: dueTodayTasks,
          recentActivity: recentActivity,
          dataUnavailable: numTasks == null,
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
