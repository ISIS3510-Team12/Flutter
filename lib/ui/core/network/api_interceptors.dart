import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserTokenInterceptor extends Interceptor {
  UserTokenInterceptor({required this.firebaseAuth});
  final FirebaseAuth firebaseAuth;

  @override
  void onRequest(RequestOptions options , RequestInterceptorHandler handler) async {
      final token = await firebaseAuth.currentUser?.getIdToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    return handler.next(options);
  }
}