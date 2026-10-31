import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_notification.dart';

import 'package:team12_flutter_juggle/ui/core/network/network_first.dart';
import 'notifications_viewmodel.dart';

final notificationsViewModelProvider =
    AsyncNotifierProvider.autoDispose<
      NotificationsViewModel,
      CacheRead<List<AppNotification>>
    >(NotificationsViewModel.new);
