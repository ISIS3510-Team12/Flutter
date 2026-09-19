import 'package:team12_flutter_juggle/data/services/profile/notifications_api_client.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_notification.dart';

class NotificationsRepository {
  NotificationsRepository(this._apiClient);

  final NotificationsApiClient _apiClient;

  Future<List<AppNotification>> getNotifications() {
    return _apiClient.fetchNotifications();
  }

  Future<void> deleteNotification(String id) {
    return _apiClient.deleteNotification(id);
  }
}
