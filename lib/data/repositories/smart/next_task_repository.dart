import 'package:dio/dio.dart';
import 'package:team12_flutter_juggle/domain/models/smart/next_task.dart';
import 'package:team12_flutter_juggle/ui/core/utils/network_exceptions.dart';

class NextTaskRepository {
  NextTaskRepository(this._dio);

  final Dio _dio;

  Future<NextTaskResult> getNextTask() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/smart/next-task');
      return NextTaskResult.fromJson(response.data!);
    } catch (e) {
      throw repositoryError('load next task', e);
    }
  }
}
