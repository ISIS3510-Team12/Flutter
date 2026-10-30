import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:team12_flutter_juggle/ui/core/utils/format_user.dart';
import 'package:team12_flutter_juggle/ui/core/utils/auth_exceptions.dart';

Future<void> postAppUser(
  Dio dio, {
  required String firstName,
  required String lastName,
}) async {
  try {
    await dio.post<void>(
      '/users/create_user',
      data: {'first_name': firstName, 'last_name': lastName},
    );
  } on DioException catch (e) {
    if (!isUserAlreadyExists(e)) {
      rethrow;
    }
  }
}

Future<void> postCurrentAppUser(Dio dio, FirebaseAuth firebaseAuth) {
  final name = splitDisplayName(firebaseAuth.currentUser?.displayName);
  return postAppUser(dio, firstName: name.firstName, lastName: name.lastName);
}
