import 'package:flutter/foundation.dart';
import 'package:team12_flutter_juggle/ui/core/utils/network_exceptions.dart';

typedef CacheRead<T> = ({T value, bool fromCache});

Future<CacheRead<T>> networkFirst<T>({
  required bool isOnline,
  required Future<T> Function() fetch,
  required Future<void> Function(T value) save,
  required Future<T?> Function() fallback,
}) async {
  Object failure = const NetworkUnavailableException();
  var trace = StackTrace.current;
  if (isOnline) {
    try {
      final value = await fetch();
      await saveQuietly(() => save(value));
      return (value: value, fromCache: false);
    } catch (error, stackTrace) {
      if (!isOfflineFailure(error)) rethrow;
      failure = error;
      trace = stackTrace;
    }
  }
  final cached = await fallback();
  if (cached == null) Error.throwWithStackTrace(failure, trace);
  return (value: cached, fromCache: true);
}

Future<void> saveQuietly(Future<void> Function() save) async {
  try {
    await save();
  } catch (error, stackTrace) {
    debugPrint('Offline cache write failed: $error\n$stackTrace');
  }
}
