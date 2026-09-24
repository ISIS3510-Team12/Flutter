import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/core/app/service_locator.dart';
import 'package:team12_flutter_juggle/ui/core/network/api_interceptors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final dioProvider = Provider<Dio>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['API_URL']!,
      contentType: Headers.jsonContentType,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.add(UserTokenInterceptor(firebaseAuth: firebaseAuth));
  return dio;
});
