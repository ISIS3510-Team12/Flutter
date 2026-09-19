import 'package:flutter/foundation.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/notifications_repository.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_notification.dart';

class NotificationsViewModel extends ChangeNotifier {
  NotificationsViewModel({
    required NotificationsRepository notificationsRepository,
  }) : _notificationsRepository = notificationsRepository {
    _load();
  }

  final NotificationsRepository _notificationsRepository;

  bool isLoading = true;

  List<AppNotification> _notifications = const [];
  List<AppNotification> get notifications => _notifications;

  Future<void> _load() async {
    _notifications = await _notificationsRepository.getNotifications();
    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteNotification(String id) async {
    await _notificationsRepository.deleteNotification(id);
    _notifications = _notifications.where((n) => n.id != id).toList();
    notifyListeners();
  }
}
