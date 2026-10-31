import 'package:dio/dio.dart';
import 'package:team12_flutter_juggle/ui/core/utils/auth_exceptions.dart';

class NetworkUnavailableException implements Exception {
  const NetworkUnavailableException();

  String get message => "You're offline. Check your connection and try again.";

  @override
  String toString() => message;
}

class ServiceUnavailableException implements Exception {
  const ServiceUnavailableException();

  String get message =>
      'The service is not responding right now. Please try again in a moment.';

  @override
  String toString() => message;
}

bool isOfflineFailure(Object error) =>
    error is NetworkUnavailableException ||
    error is ServiceUnavailableException;

String writeFailureMessage(
  Object? error, {
  required bool isOnline,
  required String fallback,
}) {
  if (!isOnline || error is NetworkUnavailableException) {
    return 'No internet connection. Please reconnect and try again.';
  }
  if (error is ServiceUnavailableException) {
    return 'The service is not responding right now. Try again in a moment.';
  }
  return fallback;
}

Exception repositoryError(String action, Object error) {
  if (error is NetworkUnavailableException ||
      error is ServiceUnavailableException) {
    return error as Exception;
  }
  if (error is DioException) {
    if (isNetworkFailure(error)) return const NetworkUnavailableException();
    final status = error.response?.statusCode;
    if (status != null && status >= 500) {
      return const ServiceUnavailableException();
    }
  }
  return Exception('Failed to $action: $error');
}

String offlineActionMessage(String action) =>
    'No connection. Reconnect to $action.';
