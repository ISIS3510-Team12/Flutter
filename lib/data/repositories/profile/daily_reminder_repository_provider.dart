import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/daily_reminder_repository.dart';

final dailyReminderRepositoryProvider = Provider(
  (ref) => DailyReminderRepository(FlutterLocalNotificationsPlugin()),
);
