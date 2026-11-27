import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/calendar/calendar_preferences_repository.dart';

final calendarPreferencesRepositoryProvider =
    Provider<CalendarPreferencesRepository>(
      (ref) => CalendarPreferencesRepository(),
    );
