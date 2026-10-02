import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_notification.dart';

import 'notifications_viewmodel.dart';

final notificationsViewModelProvider =
    AsyncNotifierProvider.autoDispose<
      NotificationsViewModel,
      List<AppNotification>
    >(NotificationsViewModel.new);
