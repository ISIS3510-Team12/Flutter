import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/calendar/view_models/calendar_view_model.dart';

final calendarViewModelProvider =
    AsyncNotifierProvider.autoDispose<CalendarViewModel, CalendarState>(
  CalendarViewModel.new,
);