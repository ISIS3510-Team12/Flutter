import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:team12_flutter_juggle/ui/core/network/app_user_request.dart';
import 'package:team12_flutter_juggle/ui/core/utils/auth_exceptions.dart';

class UserTokenInterceptor extends Interceptor {
  UserTokenInterceptor({required this.firebaseAuth});
  final FirebaseAuth firebaseAuth;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await firebaseAuth.currentUser?.getIdToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } on FirebaseAuthException catch (e, stackTrace) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: e,
          stackTrace: stackTrace,
        ),
      );
    }
    return handler.next(options);
  }
}

class AppUserInterceptor extends Interceptor {
  AppUserInterceptor({
    required Dio dio,
    required FirebaseAuth firebaseAuth,
  }) : _dio = dio,
       _firebaseAuth = firebaseAuth;

  final Dio _dio;
  final FirebaseAuth _firebaseAuth;

  Future<void>? _pendingCreate;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!shouldCreateAppUser(err)) {
      handler.next(err);
      return;
    }

    try {
      await _createAppUserOnce();
    } catch (error, stack) {
      debugPrint('App user creation failed: $error\n$stack');
      handler.next(err);
      return;
    }

    final options = err.requestOptions..extra[appUserCreatedKey] = true;
    try {
      handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    } catch (_) {
      handler.next(err);
    }
  }

  Future<void> _createAppUserOnce() {
    return _pendingCreate ??= postCurrentAppUser(_dio, _firebaseAuth)
        .whenComplete(() => _pendingCreate = null);
  }
}
