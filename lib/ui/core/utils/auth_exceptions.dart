import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthException implements Exception {
  const AuthException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class NetworkAuthException extends AuthException {
  const NetworkAuthException()
    : super(
        "Couldn't connect. Check your connection and try again.",
        code: 'network-unavailable',
      );
}

class AuthTimeoutException extends AuthException {
  const AuthTimeoutException()
    : super(
        'Sign in took too long. Check your connection and try again.',
        code: 'timeout',
      );
}

class AuthCancelledException extends AuthException {
  const AuthCancelledException()
    : super('Sign in was cancelled', code: 'cancelled');
}

bool isNetworkFailure(Object error) => switch (error) {
  FirebaseAuthException(code: 'network-request-failed') => true,
  SocketException() => true,
  DioException(
    type: DioExceptionType.connectionError ||
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout,
  ) =>
    true,
  _ => false,
};

bool isUserAlreadyExists(DioException error) =>
    error.response?.statusCode == HttpStatus.badRequest &&
    '${error.response?.data}'.contains('already exists');

const appUserCreatedKey = 'appUserCreated';

bool shouldCreateAppUser(DioException error) =>
    error.response?.statusCode == HttpStatus.forbidden &&
    '${error.response?.data}'.contains('Application user does not exist') &&
    error.requestOptions.extra[appUserCreatedKey] != true;
