import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/domain/models/auth/app_user.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(Ref ref, FutureProvider<AppUser?> currentUserProvider) {
    ref.listen<AsyncValue<AppUser?>>(
      currentUserProvider,
      (_, _) => notifyListeners(),
    );
  }
}
