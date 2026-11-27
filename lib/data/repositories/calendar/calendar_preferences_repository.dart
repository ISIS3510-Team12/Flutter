import 'package:shared_preferences/shared_preferences.dart';
import 'package:team12_flutter_juggle/domain/models/calendar/calendar_view_mode.dart';

class CalendarPreferencesRepository {
  static const _viewModeKey = 'calendar_view_mode';

  Future<CalendarViewMode> getViewMode(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getString(_key(userId));
    return CalendarViewMode.values.asNameMap()[stored] ?? CalendarViewMode.week;
  }

  Future<void> saveViewMode(String userId, CalendarViewMode mode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key(userId), mode.name);
  }

  String _key(String userId) => '${_viewModeKey}_$userId';
}
