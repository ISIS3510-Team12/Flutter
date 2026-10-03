import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_app_bar.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/home/widgets/custom_bottom_sheet.dart';
import 'package:team12_flutter_juggle/ui/home/widgets/overview_cards.dart';
import 'package:team12_flutter_juggle/ui/home/widgets/overview_tabs.dart';
import 'package:team12_flutter_juggle/ui/home/view_models/home_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/home/view_models/home_viewmodel.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_load_tracker.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTab = 0;

  void _changeTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    return ScreenLoadTracker(
      screen: 'home_screen',
      isLoading: state.isLoading,
      child: Scaffold(
      appBar: CustomAppBar(),
      body: _buildHomeContent(context, ref, state),
      bottomNavigationBar: CustomNavigationBar(),
      resizeToAvoidBottomInset: false,
    ),
    );
  }

  Widget _buildHomeContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<HomeState> state,
  ) {
    return state.when(
      data: (data) => Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: SingleChildScrollView(
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              userSection(context, data.user.firstName),
              overviewSection(
                context,
                _selectedTab,
                _changeTab,
                data.dueTodayTasks,
                data.recentActivity,
                data.numTasks,
                numNotifications: data.numNotifications,
              ),
            ],
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
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
            Expanded(
              child: Text(
                '$day, $month $date, $year',
                style: TextStyle(fontSize: 14),
                softWrap: true,
              ),
            ),
            Spacer(),
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

  Widget overviewSection(
    BuildContext context,
    int selectedTab,
    Function(int) changeTab,
    List<Map<String, dynamic>> dueTodayTasks,
    List<Map<String, dynamic>> recentActivity,
    int numTasks, {
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
        OverviewTabs(
          dueTodayTasks: dueTodayTasks,
          recentActivity: recentActivity,
          selectedTab: selectedTab,
          changeTab: changeTab,
        ),
        SizedBox(height: 10),
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